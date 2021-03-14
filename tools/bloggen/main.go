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
	"os"
	"path/filepath"
	"strings"
	"time"

	"github.com/gomarkdown/markdown"
	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
)

//go:embed .version
var version string

var (
	sourceArticlesFolder = filepath.Join("../", "../", "xbarapp.com", "articles")
	destFolder           = filepath.Join("../", "../", "xbarapp.com", "public", "docs")
	templatesFolder      = filepath.Join("../", "../", "xbarapp.com", "templates")

	// categoriesJSON is the categories.json file that is generated.
	// If it's not there, this tool will fail. So run sitegen first.
	categoriesJSON = filepath.Join("../", "../", "xbarapp.com", "public", "docs", "plugins", "categories.json")
)

func main() {
	if err := run(context.Background(), os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string) error {
	g, err := newGenerator()
	if err != nil {
		return errors.Wrap(err, "generator")
	}
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
			filename := filepath.Base(path)
			filename = strings.ToLower(filename[:len(filename)-2] + "html")
			dest = filepath.Join(destFolder, filepath.Dir(rel), filename)
			destFilename := filepath.Join(filepath.Dir(rel), filename)
			err := g.processMarkdownFile(ctx, destFilename, dest, path)
			if err != nil {
				return errors.Wrap(err, path)
			}
			return nil
		}
		_, err = copy(dest, path)
		if err != nil {
			return err
		}
		return nil
	})
	if err != nil {
		return err
	}
	return nil
}

type generator struct {
	template   *template.Template
	categories map[string]metadata.Category
}

func newGenerator() (*generator, error) {
	tpl, err := template.ParseFiles(
		filepath.Join(templatesFolder, "_layout.html"),
		filepath.Join(templatesFolder, "article.html"),
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
	g := &generator{
		template:   tpl,
		categories: categoriesMap,
	}
	return g, nil
}

func (g *generator) processMarkdownFile(ctx context.Context, path, dest, src string) error {
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
	f, err := os.Create(dest)
	if err != nil {
		return errors.Wrap(err, "create dest")
	}
	defer f.Close()
	title := filepath.Base(src)
	title = title[:len(title)-len(filepath.Ext(title))]
	title = strings.ReplaceAll(title, "-", " ")
	pagedata := struct {
		Version              string
		LastUpdatedFormatted string
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category

		Path     string
		Title    string
		Desc     string
		ImageURL string
		HTML     template.HTML
	}{
		Version:              version,
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
		Categories:           g.categories,

		Path:     path,
		Title:    title,
		Desc:     firstLine,
		ImageURL: imagePath,
		HTML:     template.HTML(html),
	}
	err = g.template.ExecuteTemplate(f, "_main", pagedata)
	if err != nil {
		return errors.Wrap(err, "render")
	}
	return nil
}

// copy copies a file.
// from https://opensource.com/article/18/6/copying-files-go
func copy(dst, src string) (int64, error) {
	sourceFileStat, err := os.Stat(src)
	if err != nil {
		return 0, err
	}
	if !sourceFileStat.Mode().IsRegular() {
		return 0, fmt.Errorf("%s is not a regular file", src)
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
