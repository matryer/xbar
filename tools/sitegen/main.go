package main

import (
	"archive/zip"
	"context"
	"encoding/json"
	"flag"
	"fmt"
	"html/template"
	"io"
	"log"
	"math/rand"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"sync"
	"time"

	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
	"github.com/snabb/sitemap"
)

func main() {
	if err := run(context.Background(), os.Args); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}

func run(ctx context.Context, args []string) error {
	rand.Seed(time.Now().UnixNano())
	flags := flag.NewFlagSet(args[0], flag.ContinueOnError)
	var (
		out      = flags.String("out", "../../xbarapp.com/public/docs", "output folder")
		small    = flags.Bool("small", false, "run only a small sample (default is to process all)")
		skipdata = flags.Bool("skipdata", false, "skip the data - just render the index template")
		errs     = flags.Bool("errs", false, "print out error details")
	)
	if err := flags.Parse(args[1:]); err != nil {
		return err
	}
	if err := os.RemoveAll(*out); err != nil {
		return err
	}
	g, err := newGenerator(*out)
	if err != nil {
		return err
	}
	var categoriesLock sync.Mutex // protects categories
	categories := make(map[string]metadata.Category)
	var plugins []metadata.Plugin
	pluginsByPath := make(map[string][]metadata.Plugin)
	var allPlugins []metadata.Plugin
	moonCycleIndex := 0
	eachPlugin := EachFunc(func(plugin metadata.Plugin) {
		categoriesLock.Lock()
		if plugin.ImageURL == "" {
			plugin.ImageURL = metadata.DefaultPluginImage
		}
		plugins = append(plugins, plugin)
		metadata.CategoryEnsurePath(categories, nil, plugin.PathSegments)
		pluginsByPath[plugin.Dir] = append(pluginsByPath[plugin.Dir], plugin)
		allPlugins = append(allPlugins, plugin)
		categoriesLock.Unlock()
		moonCycleIndex, err = moonCycle.Print(os.Stdout, moonCycleIndex)
		if err != nil {
			log.Println(err)
		}
	})
	reader := &RepoReader{
		RepoOwner:         "matryer",
		RepoName:          "xbar-plugins",
		EachPluginFn:      eachPlugin,
		GitHubAccessToken: os.Getenv("XBAR_GITHUB_ACCESS_TOKEN"),
		SmallSample:       *small,
		PrintErrors:       *errs,
	}
	if !*skipdata {
		if err := reader.All(ctx); err != nil {
			return err
		}
	} else {
		metadata.CategoryEnsurePath(categories, nil, []string{"One"})
		metadata.CategoryEnsurePath(categories, nil, []string{"Two"})
		metadata.CategoryEnsurePath(categories, nil, []string{"Three"})
		plugins = []metadata.Plugin{
			{
				Title: "Plugin 1",
				Authors: []metadata.Person{
					{
						GitHubUsername: "matryer",
						Name:           "Mat Ryer",
						ImageURL:       "https://avatars.githubusercontent.com/u/101659?s=400&u=1d1b31bbb68719f4514834440b6ea53e99f91be1&v=4",
						Bio:            "Something about Mat goes here",
						Primary:        true,
					},
				},
			},
			{
				Title: "Plugin 2",
				Authors: []metadata.Person{
					{
						GitHubUsername: "leaanthony",
						Name:           "Lea Anthony",
						ImageURL:       "https://avatars.githubusercontent.com/u/1943904?s=460&v=4",
						Bio:            "Something about Lea goes here",
						Primary:        true,
					},
				},
			},
		}
	}
	if err := g.mkdirall(); err != nil {
		return errors.Wrap(err, "mkDirAll")
	}
	featuredPlugins := metadata.RandomPlugins(pluginsByPath, "", 6)
	var wg sync.WaitGroup
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generatePluginsIndexPage(categories, pluginsByPath, featuredPlugins); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generatePluginsIndexPage"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateCategoriesJSON(categories); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateCategoriesJSON"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateCategoryPluginsJSONFiles(categories, pluginsByPath); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateCategoryPluginsJSONFiles"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateCategoryPages(categories, categories, pluginsByPath); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateCategoryPages"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generatePluginPages(categories, plugins); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generatePluginPages"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateSitemap(categories, pluginsByPath, *out); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateSitemap"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateContributorPages(categories, pluginsByPath); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateContributorPages"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateFeaturedPluginsJSON(featuredPlugins); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateFeaturedPluginsJSON"))
			}
		}
	}()
	wg.Add(1)
	go func() {
		defer wg.Done()
		if err := g.generateContributorsPage(categories, plugins); err != nil {
			if *errs == true {
				log.Println(errors.Wrap(err, "generateContributorsPage"))
			}
		}
	}()
	wg.Wait()
	fmt.Println()
	log.Printf("processed %d plugins\n", len(allPlugins))
	// log.Printf("categories: %+v\n", categories)
	// log.Printf("//pluginsByPath: %+v\n", //pluginsByPath)
	return nil
}

type generator struct {
	outputDir string

	pluginsDir string
	authorsDir string

	peopleCycleIndex int

	categoryTemplate     *template.Template
	pluginTemplate       *template.Template
	indexTemplate        *template.Template
	contributorTemplate  *template.Template
	contributorsTemplate *template.Template
}

func newGenerator(outputDir string) (*generator, error) {
	categoryTemplate, err := template.ParseFiles(
		filepath.Join("templates", "_layout.html"),
		filepath.Join("templates", "category.html"),
	)
	if err != nil {
		return nil, err
	}
	pluginTemplate, err := template.ParseFiles(
		filepath.Join("templates", "_layout.html"),
		filepath.Join("templates", "plugin.html"),
	)
	if err != nil {
		return nil, err
	}
	indexTemplate, err := template.ParseFiles(
		filepath.Join("templates", "_layout.html"),
		filepath.Join("templates", "index.html"),
	)
	if err != nil {
		return nil, err
	}
	contributorTemplate, err := template.ParseFiles(
		filepath.Join("templates", "_layout.html"),
		filepath.Join("templates", "contributor.html"),
	)
	if err != nil {
		return nil, err
	}
	contributorsTemplate, err := template.ParseFiles(
		filepath.Join("templates", "_layout.html"),
		filepath.Join("templates", "contributors.html"),
	)
	if err != nil {
		return nil, err
	}
	g := &generator{
		outputDir:  outputDir,
		pluginsDir: filepath.Join(outputDir, "plugins"),
		authorsDir: filepath.Join(outputDir, "contributors"),

		categoryTemplate:     categoryTemplate,
		pluginTemplate:       pluginTemplate,
		indexTemplate:        indexTemplate,
		contributorTemplate:  contributorTemplate,
		contributorsTemplate: contributorsTemplate,
	}
	return g, nil
}

func (g *generator) mkdirall() error {
	if err := os.MkdirAll(g.outputDir, 0777); err != nil {
		return err
	}
	if err := os.MkdirAll(g.authorsDir, 0777); err != nil {
		return err
	}
	if err := os.MkdirAll(g.pluginsDir, 0777); err != nil {
		return err
	}
	return nil
}

func (g *generator) generateContributorPages(categories map[string]metadata.Category, pluginsByPath map[string][]metadata.Plugin) error {
	authors := make(map[string]metadata.Person)
	for _, plugins := range pluginsByPath {
		for _, plugin := range plugins {
			for _, author := range plugin.Authors {
				if author.Name == "" {
					continue
				}
				if author.GitHubUsername == "" {
					continue
				}
				authors[author.GitHubUsername] = author
			}
		}
	}
	for _, author := range authors {
		if err := g.generateContributorPage(categories, pluginsByPath, author); err != nil {
			return err
		}
		if err := g.generateAuthorJSON(pluginsByPath, author); err != nil {
			return err
		}
	}
	return nil
}

func (g *generator) generateAuthorJSON(pluginsByPath map[string][]metadata.Plugin, author metadata.Person) error {
	var thisUsersPlugins []metadata.Plugin
	for _, plugins := range pluginsByPath {
		for _, plugin := range plugins {
			for _, person := range plugin.Authors {
				if person.GitHubUsername == author.GitHubUsername {
					thisUsersPlugins = append(thisUsersPlugins, plugin)
				}
			}
		}
	}
	f, err := os.Create(filepath.Join(g.authorsDir, author.GitHubUsername+".json"))
	if err != nil {
		return err
	}
	defer f.Close()
	var payload = struct {
		Person  metadata.Person   `json:"person"`
		Plugins []metadata.Plugin `json:"plugins"`
	}{
		Person:  author,
		Plugins: thisUsersPlugins,
	}
	b, err := json.MarshalIndent(payload, "", "\t")
	if err != nil {
		return err
	}
	_, err = f.Write(b)
	if err != nil {
		return err
	}
	return nil
}

func (g *generator) generateContributorPage(categories map[string]metadata.Category, pluginsByPath map[string][]metadata.Plugin, author metadata.Person) error {
	var thisUsersPlugins []metadata.Plugin
	for _, plugins := range pluginsByPath {
		for _, plugin := range plugins {
			for _, pluginAuthor := range plugin.Authors {
				if pluginAuthor.GitHubUsername == author.GitHubUsername {
					thisUsersPlugins = append(thisUsersPlugins, plugin)
				}
			}
		}
	}
	f, err := os.Create(filepath.Join(g.authorsDir, author.GitHubUsername+".html"))
	if err != nil {
		return err
	}
	defer f.Close()
	j, err := json.Marshal(categories)
	if err != nil {
		return err
	}
	pageData := struct {
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		Author               metadata.Person
		Plugins              []metadata.Plugin
		CategoriesJSON       template.JS
		LastUpdatedFormatted string
	}{
		CurrentCategoryPath:  firstSegment(""),
		Categories:           categories,
		Author:               author,
		Plugins:              thisUsersPlugins,
		CategoriesJSON:       template.JS(j),
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
	}
	if err := g.contributorTemplate.ExecuteTemplate(f, "_main", pageData); err != nil {
		return err
	}
	g.peopleCycleIndex, err = peopleCycle.Print(os.Stdout, g.peopleCycleIndex)
	fmt.Print()
	return nil
}

func (g *generator) generateContributorsPage(categories map[string]metadata.Category, plugins []metadata.Plugin) error {
	people := make(map[string]metadata.Person)
	for _, plugin := range plugins {
		for _, person := range plugin.Authors {
			if person.GitHubUsername == "" {
				continue
			}
			if person.ImageURL == "" {
				continue
			}
			if person.Name == "" {
				continue
			}
			people[person.GitHubUsername] = person
		}
	}
	f, err := os.Create(filepath.Join(g.authorsDir, "index.html"))
	if err != nil {
		return err
	}
	defer f.Close()
	pageData := struct {
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		People               map[string]metadata.Person
		CategoriesJSON       template.JS
		LastUpdatedFormatted string
		PeopleLen            int
	}{
		CurrentCategoryPath:  firstSegment(""),
		Categories:           categories,
		People:               people,
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
		PeopleLen:            len(people),
	}
	if err := g.contributorsTemplate.ExecuteTemplate(f, "_main", pageData); err != nil {
		return err
	}
	return nil
}

func (g *generator) generatePluginsIndexPage(
	categories map[string]metadata.Category,
	pluginsByPath map[string][]metadata.Plugin,
	featuredPlugins []metadata.Plugin,
) error {
	f, err := os.Create(filepath.Join(g.pluginsDir, "index.html"))
	if err != nil {
		return err
	}
	defer f.Close()
	j, err := json.Marshal(categories)
	if err != nil {
		return err
	}
	pageData := struct {
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		PluginsByPath        map[string][]metadata.Plugin
		GetPlugins           func(string) ([]metadata.Plugin, error)
		CategoriesJSON       template.JS
		FeaturedPlugins      []metadata.Plugin
		LastUpdatedFormatted string
	}{
		CurrentCategoryPath:  firstSegment(""),
		Categories:           categories,
		PluginsByPath:        pluginsByPath,
		CategoriesJSON:       template.JS(j),
		FeaturedPlugins:      featuredPlugins,
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
	}
	pageData.GetPlugins = func(pathPrefix string) ([]metadata.Plugin, error) {
		var matchingPlugins []metadata.Plugin
		for path, plugins := range pluginsByPath {
			if strings.HasPrefix(path, pathPrefix) {
				matchingPlugins = append(matchingPlugins, plugins...)
			}
		}
		return matchingPlugins, nil
	}
	if err := g.indexTemplate.ExecuteTemplate(f, "_main", pageData); err != nil {
		return err
	}
	return nil
}

func (g *generator) generateCategoriesJSON(categories map[string]metadata.Category) error {
	categoryList := g.categoriesToCategory(categories)
	f, err := os.Create(filepath.Join(g.pluginsDir, "categories.json"))
	if err != nil {
		return err
	}
	defer f.Close()
	payload := struct {
		Categories []metadata.Category `json:"categories"`
	}{
		Categories: categoryList,
	}
	b, err := json.MarshalIndent(payload, "", "\t")
	if err != nil {
		return err
	}
	if _, err := io.WriteString(f, string(b)); err != nil {
		return err
	}
	return nil
}

func (g *generator) generateCategoryPluginsJSONFiles(categories map[string]metadata.Category, pluginsByPath map[string][]metadata.Plugin) error {
	for _, category := range categories {
		// collect all plugins that are children to this category.
		var plugins []metadata.Plugin
		for path, thesePlugins := range pluginsByPath {
			if strings.HasPrefix(path, category.Path) {
				plugins = append(plugins, thesePlugins...)
			}
		}
		if err := g.generateCategoryPluginsJSON(category.Path, plugins); err != nil {
			return err
		}
		if err := g.generateCategoryPluginsJSONFiles(category.ChildrenCategories, pluginsByPath); err != nil {
			return err
		}
	}
	return nil
}

func (g *generator) generateFeaturedPluginsJSON(featuredPlugins []metadata.Plugin) error {
	filename := filepath.Join(g.pluginsDir, "featured-plugins.json")
	payload := struct {
		Plugins []metadata.Plugin `json:"plugins"`
	}{
		Plugins: featuredPlugins,
	}
	b, err := json.MarshalIndent(payload, "", "\t")
	if err != nil {
		return err
	}
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer f.Close()
	if _, err := io.WriteString(f, string(b)); err != nil {
		return err
	}
	return nil
}

func (g *generator) generateCategoryPluginsJSON(categoryPath string, plugins []metadata.Plugin) error {
	dir := filepath.Join(g.pluginsDir, categoryPath)
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	filename := filepath.Join(dir, "plugins.json")
	payload := struct {
		Plugins []metadata.Plugin `json:"plugins"`
	}{
		Plugins: plugins,
	}
	// sort the plugins by title
	sort.Slice(payload.Plugins, func(i, j int) bool {
		return payload.Plugins[i].Title < payload.Plugins[j].Title
	})
	b, err := json.MarshalIndent(payload, "", "\t")
	if err != nil {
		return err
	}
	f, err := os.Create(filename)
	if err != nil {
		return err
	}
	defer f.Close()
	if _, err := io.WriteString(f, string(b)); err != nil {
		return err
	}
	return nil
}

func (g *generator) generatePluginPages(categories map[string]metadata.Category, plugins []metadata.Plugin) error {
	for _, plugin := range plugins {
		if err := g.generatePluginPage(categories, plugin); err != nil {
			return err
		}
		if err := g.generatePluginJSONPayload(plugin); err != nil {
			return err
		}
	}
	return nil
}

func (g generator) generatePluginJSONPayload(plugin metadata.Plugin) error {
	dir := filepath.Dir(filepath.Join(g.pluginsDir, plugin.Path))
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	jsonFilePath := filepath.Join(g.pluginsDir, plugin.Path+".json")
	f, err := os.Create(jsonFilePath)
	if err != nil {
		return err
	}
	defer f.Close()
	var payload struct {
		Plugin metadata.Plugin `json:"plugin"`
	}
	payload.Plugin = plugin
	b, err := json.MarshalIndent(payload, "", "\t")
	if err != nil {
		return err
	}
	if _, err := f.Write(b); err != nil {
		return err
	}
	return nil
}

func (g *generator) generatePluginPage(categories map[string]metadata.Category, plugin metadata.Plugin) error {
	dir := filepath.Dir(filepath.Join(g.pluginsDir, plugin.Path))
	if err := os.MkdirAll(dir, 0700); err != nil {
		return err
	}
	pagePath := filepath.Join(g.pluginsDir, plugin.Path+".html")
	f, err := os.Create(pagePath)
	if err != nil {
		return err
	}
	defer f.Close()
	j, err := json.Marshal(categories)
	if err != nil {
		return err
	}
	pageData := struct {
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		Plugin               metadata.Plugin
		CategoriesJSON       template.JS
		LastUpdatedFormatted string
	}{
		CurrentCategoryPath:  firstSegment(plugin.CategoryPath),
		Categories:           categories,
		Plugin:               plugin,
		CategoriesJSON:       template.JS(j),
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
	}
	if err := g.pluginTemplate.ExecuteTemplate(f, "_main", pageData); err != nil {
		return err
	}
	fmt.Print("🔌")
	return nil
}

func (g *generator) generateCategoryPages(allcategories, categories map[string]metadata.Category, pluginsByPath map[string][]metadata.Plugin) error {
	for _, category := range categories {
		if err := g.generateCategoryPage(allcategories, category, pluginsByPath, g.pluginsDir); err != nil {
			return err
		}
		if err := g.generateCategoryPages(allcategories, category.ChildrenCategories, pluginsByPath); err != nil {
			return err
		}
	}
	return nil
}

func (g *generator) generateCategoryPage(categories map[string]metadata.Category, category metadata.Category, pluginsByPath map[string][]metadata.Plugin, outputDir string) error {
	pagePath := filepath.Join(outputDir, category.Path+".html")
	pathDir := filepath.Dir(pagePath)
	if err := os.MkdirAll(pathDir, 0777); err != nil {
		return err
	}
	f, err := os.Create(pagePath)
	if err != nil {
		return err
	}
	defer f.Close()
	var plugins []metadata.Plugin
	for _, ps := range pluginsByPath {
		for _, p := range ps {
			if strings.HasPrefix(p.Path, category.Path) {
				plugins = append(plugins, p)
			}
		}
	}
	j, err := json.Marshal(categories)
	if err != nil {
		return err
	}
	pageData := struct {
		CurrentCategoryPath  string
		Categories           map[string]metadata.Category
		Category             metadata.Category
		Plugins              []metadata.Plugin
		FeaturedPlugins      []metadata.Plugin
		CategoriesJSON       template.JS
		LastUpdatedFormatted string
	}{
		CurrentCategoryPath:  firstSegment(category.Path),
		Categories:           categories,
		Category:             category,
		Plugins:              plugins,
		FeaturedPlugins:      metadata.RandomPlugins(pluginsByPath, category.Path, 3),
		CategoriesJSON:       template.JS(j),
		LastUpdatedFormatted: time.Now().Format(time.RFC822),
	}
	if err := g.categoryTemplate.ExecuteTemplate(f, "_main", pageData); err != nil {
		return err
	}
	return nil
}

func (g *generator) generateSitemap(categories map[string]metadata.Category, pluginsByPath map[string][]metadata.Plugin, outputDir string) error {
	now := time.Now()
	sm := sitemap.New()
	sm.Add(&sitemap.URL{
		Loc:        "https://xbarapp.com/",
		LastMod:    &now,
		ChangeFreq: sitemap.Weekly,
	})
	var addCategory func(categories map[string]metadata.Category)
	addCategory = func(categories map[string]metadata.Category) {
		for _, category := range categories {
			sm.Add(&sitemap.URL{
				Loc:        "https://xbarapp.com/docs/plugins/" + category.Path + ".html",
				LastMod:    &now,
				ChangeFreq: sitemap.Weekly,
			})
			addCategory(category.ChildrenCategories)
		}
	}
	addCategory(categories)
	for _, plugins := range pluginsByPath {
		for _, plugin := range plugins {
			sm.Add(&sitemap.URL{
				Loc:        "https://xbarapp.com/docs/plugins/" + plugin.Path + ".html",
				LastMod:    &now,
				ChangeFreq: sitemap.Monthly,
			})
		}
	}
	f, err := os.Create(filepath.Join(outputDir, "sitemap.xml"))
	if err != nil {
		return err
	}
	defer f.Close()
	zf, err := os.Create(filepath.Join(outputDir, "sitemap.xml.gz"))
	if err != nil {
		return err
	}
	defer zf.Close()
	w := zip.NewWriter(zf)
	defer w.Close()
	zippedFile, err := w.Create("sitemap.xml")
	if err != nil {
		return err
	}
	if _, err := sm.WriteTo(io.MultiWriter(f, zippedFile)); err != nil {
		return err
	}
	return nil
}

func (g *generator) categoriesToCategory(categories map[string]metadata.Category) []metadata.Category {
	cats := make([]metadata.Category, 0, len(categories))
	for _, cat := range categories {
		c := metadata.Category{
			Path:                 cat.Path,
			Text:                 cat.Text,
			CategoryPathSegments: cat.CategoryPathSegments,
			LastUpdated:          cat.LastUpdated,
		}
		c.Children = g.categoriesToCategory(cat.ChildrenCategories)
		cats = append(cats, c)
	}
	sort.Slice(cats, func(i, j int) bool {
		return cats[i].Text < cats[j].Text
	})
	return cats
}

func firstSegment(path string) string {
	return strings.Split(path, "/")[0]
}

var (
	moonCycle   = cycleString{"\r🌕", "\r🌖", "\r🌗", "\r🌘", "\r🌑", "\r🌒", "\r🌓", "\r🌔"}
	peopleCycle = cycleString{"👧 ", "🧑🏾‍🦱 ", "🧑‍🦰 ", "👩‍🦳 ", "👩🏽‍🦱 ", "🧔🏿 ", "👨🏽‍🦲 ", "👱‍♂️ "}
)

// cycleString cycles through strings.
// Make a counter and use Print to write the strings and keep count.
//   moonCycle = cycleString{"🌕", "🌖", "🌗", "🌘", "🌑", "🌒", "🌓", "🌔"}
//   var moonIndex int
//   var err error
//   for {
//	 	moonIndex, err = moonCycle.Print(os.Stdout, moonIndex)
//      if err != nil {
//        return errors.Wrap(err, "write error")
//      }
//   }
type cycleString []string

// Next gets the index of the next string.
func (c cycleString) Print(w io.Writer, i int) (int, error) {
	if _, err := io.WriteString(w, c[i]); err != nil {
		return i, err
	}
	i++
	if i >= len(c) {
		i = 0
	}
	return i, nil
}
