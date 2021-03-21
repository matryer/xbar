package metadata

import (
	"fmt"
	"math/rand"
	"os"
	"path"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/pkg/errors"
)

// Plugin is the plugin metadata payload returned by Parse.
type Plugin struct {
	// Files are the files that make up this Plugin.
	Files []File `json:"files"`
	// Path is the unique path to this plugin.
	Path string `json:"path"`
	// Filename is the filename for this plugin.
	Filename string `json:"filename"`
	// Dir is the virtual directory of this plugin.
	Dir string `json:"dir"`
	// DocsPath is the path to the documentation for this
	// plugin.
	DocsPlugin string `json:"docsPlugin"`
	// CategoryPath is the path of the category this plugin is in.
	CategoryPath string `json:"-"`
	// DocsCategory is the path to the documentation for this
	// plugin.
	DocsCategory string `json:"docsCategory"`
	// PathSegments are the segments that describe the path
	// of this plugin. Each subsequent item is a child of the previous segment.
	PathSegments []string `json:"pathSegments"`
	// PathSegments are the segments that describe the path
	// of this plugin. Each subsequent item is a child of the previous segment.
	CategoryPathSegments []PathItem `json:"categoryPathSegments"`
	// Title is the plugin title.
	Title string `json:"title"`
	// Version is the latest version number.
	Version string `json:"version"`
	// Author is the list of authors. Use Authors for structured data.
	Author string `json:"author"`
	// Authors contains information about the people who contributed to this plugin.
	Authors []Person `json:"authors"`
	// Desc is a short description of this plugin.
	Desc string `json:"desc"`
	// ImageURL is a public URL containing the preview image for this plugin.
	ImageURL string `json:"imageURL"`
	// Dependencies are a list of explicit dependencies this plugin requires to run.
	Dependencies []string `json:"dependencies"`
	// AboutURL is the public URL to learn more about the plugin, including
	// to contact the author.
	AboutURL string `json:"aboutURL"`
	// LastUpdated is when this data was last updated.
	LastUpdated time.Time `json:"lastUpdated"`
	// Vars are the configurable values for this Plugin.
	Vars []PluginVar `json:"vars"`

	// ProcessingNotes is a list of errors/warnings/notes that are set during
	// the processing of this plugin.
	ProcessingNotes []string `json:"processingNotes"`
}

// Validate checks the plugin data.
func (p Plugin) Validate() error {
	if p.Title == "" {
		return errors.New("missing xbar.title")
	}
	if p.Desc == "" {
		return errors.New("missing xbar.desc")
	}
	if !HasImage(p.ImageURL) {
		return errors.New("missing xbar.image")
	}
	if len(p.Authors) == 0 {
		return errors.New("missing xbar.author")
	}
	return nil // ok
}

// NiceDesc gets a nice description.
func (p Plugin) NiceDesc() string {
	if p.Desc == "" {
		return p.Title
	}
	return truncate(p.Desc, 75)
}

// File is a single file.
type File struct {
	// Path is the path of the File.
	Path string `json:"path"`
	// Filename is the file name of this File.
	Filename string `json:"filename"`
	// Content is the content of the File.
	Content string `json:"content"`
}

// PluginVar describes a configurable value for a Plugin.
type PluginVar struct {
	// Type is the type of the value. One of "string", "number", "boolean", or "select".
	Type string `json:"type"`
	// Name is the name of the variable.
	Name string `json:"name"`
	// Label is the display text for this variable (derived from Name).
	Label string `json:"label"`
	// Default is the default value.
	Default string `json:"default"`
	// Desc is a description of the variable.
	Desc string `json:"desc"`
	// Options are the available options for "select" types.
	Options []string `json:"options"`
}

// DefaultValue gets the Default value in the correct type.
func (p PluginVar) DefaultValue() interface{} {
	switch p.Type {
	case "select":
		return p.Default
	case "string":
		return p.Default
	case "number":
		f, err := strconv.ParseFloat(p.Default, 64)
		if err != nil {
			return 0.0
		}
		return f
	case "boolean":
		if p.Default == "true" {
			return true
		}
		return false
	}
	return p.Default
}

// LastUpdatedFormatted is a formatted string.
func (p Plugin) LastUpdatedFormatted() string {
	return p.LastUpdated.Format(time.RFC822)
}

// Person represents a human.
type Person struct {
	Name           string `json:"name"`
	GitHubUsername string `json:"githubUsername"`
	ImageURL       string `json:"imageURL"`
	Bio            string `json:"bio"`
	Primary        bool   `json:"primary"`
}

// Desc gets a nice description of this person.
func (p Person) Desc() string {
	desc := p.Name
	if desc == "" {
		desc = "@" + p.GitHubUsername
	} else {
		desc += " (@" + p.GitHubUsername + ")"
	}
	if p.Bio != "" {
		desc += " - " + p.Bio
	}
	return strings.TrimSpace(desc)
}

// NiceBio gets a nice bio for this Person.
func (p Person) NiceBio() string {
	if p.Bio == "" {
		name := p.Name
		if name == "" {
			name = p.GitHubUsername
		}
		if name == "" {
			name = "This person"
		}
		return name + " is an xbar plugin contributor."
	}
	return p.Bio
}

// Complete checks the metadata to see if it is complete.
// If not, it will return an error that would be associated with
// the plugin, until it is next checked.
func (p Plugin) Complete() error {
	if p.Title == "" {
		return errMissingMetadata("xbar.title")
	}
	return nil
}

// Parse parses the s input extracting bitbar or xbar metadata.
func Parse(debugf DebugFunc, filename, s string) (Plugin, error) {
	var p Plugin
	p.LastUpdated = time.Now()
	p.Files = []File{
		{
			Path:     filename,
			Filename: path.Base(filename),
			Content:  s,
		},
	}
	p.Filename = path.Base(filename)
	p.Dir = path.Dir(filename)
	p.PathSegments = strings.Split(path.Dir(filename), string(os.PathSeparator))
	p.CategoryPathSegments = CategoryPathSegments(path.Dir(filename))
	bitbarMatches, err := regexp.Compile(`<([bitbar].*?)>(.*)</[bitbar].*?>`)
	if err != nil {
		return p, err
	}
	xbarMatches, err := regexp.Compile(`<([xbar].*?)>(.*)</[xbar].*?>`)
	if err != nil {
		return p, err
	}
	submatchall := append(bitbarMatches.FindAllStringSubmatch(s, -1), xbarMatches.FindAllStringSubmatch(s, -1)...)
	for _, element := range submatchall {
		debugf("%s: %s ", element[1], element[2])
		switch strings.ToLower(element[1]) {
		case "bitbar.title", "xbar.title":
			p.Title = element[2]
			debugf("✓\n")
		case "bitbar.version", "xbar.version":
			p.Version = element[2]
			debugf("✓\n")
		case "bitbar.author", "xbar.author":
			authorNames := strings.Split(element[2], ",")
			p.Author = strings.Join(authorNames, ", ")
			for i, authorName := range authorNames {
				authorName = strings.TrimSpace(authorName)
				if len(p.Authors) < i+1 {
					p.Authors = append(p.Authors, Person{})
				}
				p.Authors[i].Name = authorName
			}
			debugf("✓\n")
		case "bitbar.author.github", "xbar.author.github":
			authorUsernames := strings.Split(element[2], ",")
			for i, authorUsername := range authorUsernames {
				authorUsername = strings.TrimSpace(authorUsername)
				if len(p.Authors) < i+1 {
					p.Authors = append(p.Authors, Person{})
				}
				p.Authors[i].GitHubUsername = authorUsername
			}
			debugf("✓\n")
		case "bitbar.desc", "xbar.desc":
			p.Desc = element[2]
			debugf("✓\n")
		case "bitbar.image", "xbar.image":
			p.ImageURL = element[2]
			debugf("✓\n")
		case "bitbar.abouturl", "xbar.abouturl":
			p.AboutURL = element[2]
			debugf("✓\n")
		case "bitbar.dependencies", "xbar.dependencies":
			p.Dependencies = splitList(element[2])
			debugf("✓\n")
		case "xbar.var":
			v, err := parsePluginVar(element[2])
			if err != nil {
				return p, err
			}
			p.Vars = append(p.Vars, v)
			debugf("✓\n")
		default:
			debugf("(skipping) unknown parameter %s\n", element[1])
		}
	}
	if len(p.Authors) > 0 {
		// the first author is the "primary" one
		p.Authors[0].Primary = true
	}
	return p, nil
}

// PathItem is a path segment.
type PathItem struct {
	Path   string `json:"path"`
	Text   string `json:"text"`
	IsLast bool   `json:"isLast"`
}

// CategoryPathSegments splits a category path string into segments to
// help making navigation breadcrumbs.
func CategoryPathSegments(categoryPath string) []PathItem {
	segs := strings.Split(categoryPath, "/")
	var path string
	items := make([]PathItem, len(segs))
	for i, seg := range segs {
		if path != "" {
			path += "/"
		}
		path += seg
		items[i].Path = path
		items[i].Text = seg
	}
	items[len(items)-1].IsLast = true
	return items
}

func splitList(s string) []string {
	segs := strings.Split(s, ",")
	cleanSegs := make([]string, 0, len(segs))
	for i := range segs {
		segs[i] = strings.TrimSpace(segs[i])
		if segs[i] != "" {
			cleanSegs = append(cleanSegs, segs[i])
		}
	}
	return cleanSegs
}

// DebugFunc is a function that writes debug information.
// Use DebugfNoop for silence.
type DebugFunc func(format string, v ...interface{})

// DebugfNoop is a silent DebugFunc.
func DebugfNoop(format string, v ...interface{}) {}

// DebugfLog uses log.Print to write debug information.
func DebugfLog(format string, v ...interface{}) {
	fmt.Printf(format, v...)
}

// DefaultPluginImage is the image to use when none is set.
const DefaultPluginImage = "https://xbarapp.com/public/img/xbar-2048.png"

// HasImage tests whether the plugin's ImageURL is a specific
// image or not.
func HasImage(imageURL string) bool {
	if imageURL == "" {
		return false
	}
	if imageURL == DefaultPluginImage {
		return false
	}
	return true
}

// RandomPlugins selects n random plugins from the
func RandomPlugins(pluginsByPath map[string][]Plugin, pathPrefix string, n int) []Plugin {
	var pluginsWithImages []Plugin
	for _, plugins := range pluginsByPath {
		for _, plugin := range plugins {
			if !HasImage(plugin.ImageURL) {
				continue
			}
			if plugin.Author == "" {
				continue
			}
			if !strings.HasPrefix(plugin.Path, pathPrefix) {
				continue
			}
			pluginsWithImages = append(pluginsWithImages, plugin)
		}
	}
	if len(pluginsWithImages) <= n {
		return pluginsWithImages
	}
	rand.Seed(time.Now().UnixNano())
	rand.Shuffle(len(pluginsWithImages), func(i, j int) {
		pluginsWithImages[i], pluginsWithImages[j] = pluginsWithImages[j], pluginsWithImages[i]
	})
	return pluginsWithImages[:n]
}

func parsePluginVar(s string) (PluginVar, error) {
	var v PluginVar
	varLineRegexp, err := regexp.Compile(`(.+)\((.+)\):\s(.+)`)
	if err != nil {
		return v, errors.Wrap(err, "var line regexp")
	}
	segments := varLineRegexp.FindAllStringSubmatch(s, -1)
	if len(segments) != 1 {
		return v, errParse{
			src: s,
			err: errors.New("malformed xbar.var format"),
		}
	}
	if len(segments[0]) != 4 {
		return v, errParse{
			src: s,
			err: errors.New("malformed xbar.var format"),
		}
	}
	segs := segments[0]
	v.Type = segs[1]
	v.Desc = segs[3]
	v.Name = segs[2]
	if strings.Contains(v.Name, "=") {
		nameSegs := strings.Split(v.Name, "=")
		v.Name = nameSegs[0]
		v.Default = strings.Trim(nameSegs[1], `"'`)
	}
	v.Label = v.Name
	if strings.HasPrefix(v.Name, "VAR_") {
		v.Label = strings.ToLower(strings.TrimPrefix(v.Name, "VAR_"))
		v.Label = strings.ToUpper(v.Label[0:1]) + v.Label[1:]
		v.Label = strings.ReplaceAll(v.Label, "_", " ")
	}
	switch v.Type {
	case "string", "number", "boolean":
		// valid types - but no work to do
	case "select":
		// extract options from description
		listSegs := strings.Split(v.Desc, `[`)
		if len(listSegs) < 2 {
			return v, errParse{
				src: s,
				err: errors.New("malformed xbar.var format (missing select options)"),
			}
		}
		v.Desc = strings.TrimSpace(listSegs[0])
		optionsStr := strings.TrimSuffix(listSegs[1], `]`)
		for _, option := range strings.Split(optionsStr, ",") {
			cleanStr := strings.TrimSpace(option)
			if cleanStr == "" {
				continue // skip empty lines
			}
			v.Options = append(v.Options, cleanStr)
		}
		if len(v.Options) == 0 {
			return v, errParse{
				src: s,
				err: errors.New("malformed xbar.var format (empty select options)"),
			}
		}
		defaultFound := false
		for _, val := range v.Options {
			if val == v.Default {
				defaultFound = true
				break
			}
		}
		if !defaultFound {
			return v, errParse{
				src: s,
				err: errors.New("malformed xbar.var format (default not in select options)"),
			}
		}
	default: // invalid type
		return v, errors.Errorf("unknown xbar.var type: %s", v.Type)
	}
	return v, nil
}

type errMissingMetadata string

func (e errMissingMetadata) Error() string {
	return fmt.Sprintf("missing <%[1]s></%[1]s>", string(e))
}

type errParse struct {
	src string
	err error
}

func (e errParse) Error() string {
	if e.src != "" {
		return fmt.Sprintf("%s: %q", e.err, e.src)
	}
	return e.err.Error()
}

// truncate shrinks a string if it's too long.
func truncate(s string, max int) string {
	runes := []rune(s)
	if max > 0 && len(runes) > max {
		s = string(runes[:max-1]) + "…"
		return s
	}
	return s
}
