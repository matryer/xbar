package main

import (
	"bufio"
	"bytes"
	"context"
	_ "embed"
	"encoding/json"
	"fmt"
	"html/template"
	"io"
	"io/fs"
	"log"
	"math/rand"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"time"

	"github.com/gomarkdown/markdown"
	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
)

var (
	sourceArticlesFolder = filepath.Join("../", "../", "xbarapp.com", "articles")
	destFolder           = filepath.Join("../", "../", "xbarapp.com", "public", "docs")
	templatesFolder      = filepath.Join("../", "../", "xbarapp.com", "templates")

	// categoriesJSON is the categories.json file that is generated.
	// If it's not there, this tool will fail. So run sitegen first.
	categoriesJSON = filepath.Join("../", "../", "xbarapp.com", "public", "docs", "plugins", "categories.json")
)

func generateDocs(ctx context.Context) ([]Article, error) {
	rand.Seed(time.Now().Unix())
	g, err := newDocsGenerator()
	if err != nil {
		return nil, errors.Wrap(err, "newDocsGenerator")
	}
	docs := make(map[string]string)
	err = filepath.Walk(sourceArticlesFolder, func(path string, info fs.FileInfo, err error) error {
		if err != nil {
			return err
		}
		if info.IsDir() {
			return nil // ignore directories
		}
		if strings.HasPrefix(info.Name(), ".") {
			return nil // skip dotfiles
		}
		rel, err := filepath.Rel(sourceArticlesFolder, path)
		if err != nil {
			return err
		}
		dest := filepath.Join(destFolder, rel)
		ext := filepath.Ext(path)
		if ext == ".md" {
			docs[path] = rel
			return nil // don't copy the file
		}
		_, err = copyFile(dest, path)
		if err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return nil, err
	}
	for path, rel := range docs {
		dest := filepath.Join(destFolder, rel)
		filename := filepath.Base(path)
		filename = strings.ToLower(filename[:len(filename)-2] + "html")
		dest = filepath.Join(destFolder, filepath.Dir(rel), filename)
		destFilename := filepath.Join(filepath.Dir(rel), filename)
		err := g.parseArticleSource(ctx, destFilename, dest, path)
		if err != nil {
			log.Printf("%s: %s", path, err)
		}
	}
	// sort articles by time
	sort.Slice(g.articles, func(i, j int) bool {
		return g.articles[i].PublishTime.Before(g.articles[j].PublishTime)
	})
	err = g.generateArticlePages()
	if err != nil {
		return nil, errors.Wrap(err, "generateArticlePages")
	}
	err = g.generateArticlesIndexPage()
	if err != nil {
		return nil, errors.Wrap(err, "generateArticlesIndexPage")
	}
	return g.articles, nil
}

type Article struct {
	Path         string
	DestFilepath string

	Title          string
	Desc           string
	ImageURL       string
	PublishTime    time.Time
	PublishTimeStr string
	HTML           template.HTML
}

type docsGenerator struct {
	articleTemplate       *template.Template
	articlesIndexTemplate *template.Template
	categories            map[string]metadata.Category
	articles              []Article
}

func newDocsGenerator() (*docsGenerator, error) {
	articleTemplate, err := template.ParseFiles(
		filepath.Join(templatesFolder, "_layout.html"),
		filepath.Join(templatesFolder, "article.html"),
	)
	if err != nil {
		return nil, err
	}
	articlesIndexTemplate, err := template.ParseFiles(
		filepath.Join(templatesFolder, "_layout.html"),
		filepath.Join(templatesFolder, "articles-index.html"),
	)
	if err != nil {
		return nil, err
	}
	// load the categories
	b, err := os.ReadFile(categoriesJSON)
	if err != nil {
		return nil, errors.Wrap(err, "read categories.json")
	}
	var payload struct {
		Categories []metadata.Category
	}
	err = json.Unmarshal(b, &payload)
	if err != nil {
		return nil, errors.Wrap(err, "json marshal")
	}
	categoriesMap := make(map[string]metadata.Category)
	for _, category := range payload.Categories {
		categoriesMap[category.Path] = category
	}
	g := &docsGenerator{
		articleTemplate:       articleTemplate,
		articlesIndexTemplate: articlesIndexTemplate,
		categories:            categoriesMap,
	}
	return g, nil
}

func (g *docsGenerator) parseArticleSource(ctx context.Context, path, dest, src string) error {
	fmt.Printf("parsing: %s\n", path)
	pathSegs := strings.Split(path, string(filepath.Separator))
	yearStr := pathSegs[0]
	monthStr := pathSegs[1]
	dayStr := pathSegs[1]
	publishTime, err := time.Parse("02/01/2006", fmt.Sprintf("%s/%s/%s", dayStr, monthStr, yearStr))
	if err != nil {
		return errors.Wrap(err, "parse time from path")
	}
	publishTimeStr := publishTime.Format("January 2006")
	b, err := os.ReadFile(src)
	if err != nil {
		return err
	}
	firstLine := string(bytes.Split(b, []byte("\n"))[0])
	// find the first image
	var imagePath string
	s := bufio.NewScanner(bytes.NewReader(b))
	for s.Scan() {
		line := strings.TrimSpace(s.Text())
		if strings.HasPrefix(line, "![") {
			imagePath = strings.Split(line, "](")[1]
			imagePath = strings.TrimSuffix(imagePath, ")")
			imagePath = filepath.Join(filepath.Dir(path), imagePath)
			imagePath = "https://xbarapp.com/docs/" + imagePath
			break
		}
	}
	html := markdown.ToHTML(b, nil, nil)
	err = os.MkdirAll(filepath.Dir(dest), 0777)
	if err != nil {
		return err
	}
	title := filepath.Base(src)
	title = title[:len(title)-len(filepath.Ext(title))]
	title = strings.ReplaceAll(title, "-", " ")
	a := Article{
		Path:           path,
		DestFilepath:   dest,
		PublishTime:    publishTime,
		PublishTimeStr: publishTimeStr,
		Title:          title,
		Desc:           firstLine,
		ImageURL:       imagePath,
		HTML:           template.HTML(html),
	}
	g.articles = append(g.articles, a)
	return nil
}

func (g *docsGenerator) generateArticlePages() error {
	for _, article := range g.articles {
		fmt.Printf("creating: %s\n", article.DestFilepath)
		f, err := os.Create(article.DestFilepath)
		if err != nil {
			return errors.Wrap(err, "create dest")
		}
		defer f.Close()
		pagedata := struct {
			Version              string
			LastUpdatedFormatted string
			CurrentCategoryPath  string
			Categories           map[string]metadata.Category
			AllArticles          []Article
			RandomArticles       []Article
			Article              Article
		}{
			Version:              version,
			LastUpdatedFormatted: time.Now().Format(time.RFC822),
			Categories:           g.categories,
			AllArticles:          g.articles,
			RandomArticles:       g.randomArticles(article.Path, 5),
			Article:              article,
		}
		err = g.articleTemplate.ExecuteTemplate(f, "_main", pagedata)
		if err != nil {
			return errors.Wrap(err, "render")
		}
	}
	return nil
}

func (g *docsGenerator) generateArticlesIndexPage() error {
	f, err := os.Create(filepath.Join(destFolder, "index.html"))
	if err != nil {
		return errors.Wrap(err, "create index.html")
	}
	defer f.Close()

	pagedata := struct {
		Version              string
		LastUpdatedFormatted string
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		AllArticles          []Article
	}{
		Version:              version,
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
		Categories:           g.categories,
		AllArticles:          g.articles,
	}
	err = g.articlesIndexTemplate.ExecuteTemplate(f, "_main", pagedata)
	if err != nil {
		return errors.Wrap(err, "render")
	}
	return nil
}

// randomArticles gets a selection of random articles.
// excluding is the path of an article to exclude, empty string
// will include them all.
func (g *docsGenerator) randomArticles(excluding string, n int) []Article {
	skips := make(map[string]bool)
	if n > len(g.articles) {
		// not enough articles, we'll just return fewer.
		n = len(g.articles)
	}
	if excluding != "" {
		skips[excluding] = true
		if n == len(g.articles) {
			// expect one less
			n--
		}
	}
	selectedArticles := make([]Article, 0, n)
	for len(selectedArticles) < n {
		randomArticle := g.articles[rand.Intn(len(g.articles))]
		if _, shouldSkip := skips[randomArticle.Path]; shouldSkip {
			continue
		}
		selectedArticles = append(selectedArticles, randomArticle)
	}
	return selectedArticles
}

// copyFile copies a file.
// from https://opensource.com/article/18/6/copying-files-go
func copyFile(dst, src string) (int64, error) {
	sourceFileStat, err := os.Stat(src)
	if err != nil {
		return 0, err
	}
	if !sourceFileStat.Mode().IsRegular() {
		return 0, fmt.Errorf("%s is not a regular file", src)
	}
	if err := os.MkdirAll(filepath.Dir(dst), 0777); err != nil {
		return 0, err
	}
	source, err := os.Open(src)
	if err != nil {
		return 0, err
	}
	defer source.Close()
	destination, err := os.Create(dst)
	if err != nil {
		return 0, err
	}
	defer destination.Close()
	nBytes, err := io.Copy(destination, source)
	return nBytes, err
}
