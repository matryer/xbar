package metadata

import (
	"strings"
	"testing"

	"github.com/matryer/is"
)

func TestParse(t *testing.T) {
	is := is.New(t)

	debugf := DebugfNoop
	md, err := Parse(debugf, "test.txt", `

# <xbar.title>Title goes here</xbar.title>
# <xbar.version>v1.0</xbar.version>
# <xbar.author>Your Name,Another name</xbar.author>
# <xbar.author.github>your-github-username,another-github-author</xbar.author.github>
# <xbar.desc>Short description of what your plugin does.</xbar.desc>
# <xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>
# <xbar.dependencies>python,ruby,node</xbar.dependencies>
# <xbar.abouturl>http://url-to-about.com/</xbar.abouturl>

	`)
	is.NoErr(err)
	is.Equal(md.Title, "Title goes here")
	is.Equal(md.Version, "v1.0")
	is.Equal(len(md.Authors), 2)
	is.Equal(md.Author, "Your Name, Another name")
	is.Equal(md.Authors[0].Primary, true)
	is.Equal(md.Authors[0].Name, "Your Name")
	is.Equal(md.Authors[0].GitHubUsername, "your-github-username")
	is.Equal(md.Authors[1].Primary, false)
	is.Equal(md.Authors[1].Name, "Another name")
	is.Equal(md.Authors[1].GitHubUsername, "another-github-author")
	is.Equal(md.Desc, "Short description of what your plugin does.")
	is.Equal(len(md.Dependencies), 3)
	is.Equal(md.Dependencies[0], "python")
	is.Equal(md.Dependencies[1], "ruby")
	is.Equal(md.Dependencies[2], "node")
	is.Equal(md.AboutURL, "http://url-to-about.com/")

	md, err = Parse(debugf, "test.txt", `

# <bitbar.title>Title goes here</bitbar.title>
# <bitbar.version>v1.0</bitbar.version>
# <bitbar.author>Your Name</bitbar.author>
# <bitbar.author.github>your-github-username</bitbar.author.github>
# <bitbar.desc>Short description of what your plugin does.</bitbar.desc>
# <bitbar.image>http://www.hosted-somewhere/pluginimage</bitbar.image>
# <bitbar.dependencies>python,ruby,node</bitbar.dependencies>
# <bitbar.abouturl>https://url-to-about.com/</bitbar.abouturl>

	`)
	is.NoErr(err)
	is.Equal(md.Title, "Title goes here")
	is.Equal(md.Version, "v1.0")
	is.Equal(len(md.Authors), 1)
	is.Equal(md.Authors[0].Name, "Your Name")
	is.Equal(md.Authors[0].GitHubUsername, "your-github-username")
	is.Equal(md.Desc, "Short description of what your plugin does.")
	is.Equal(len(md.Dependencies), 3)
	is.Equal(md.Dependencies[0], "python")
	is.Equal(md.Dependencies[1], "ruby")
	is.Equal(md.Dependencies[2], "node")
	is.Equal(md.AboutURL, "https://url-to-about.com/")

	md, err = Parse(DebugfNoop, "test.txt", `

	/*
		Amother other kinds of comments:

		<xbar.title>Title goes here</xbar.title>
		<xbar.version>v1.0</xbar.version>
		<xbar.author>Your Name</xbar.author>
		<xbar.author.github>your-github-username</xbar.author.github>
		<xbar.desc>Short description of what your plugin does.</xbar.desc>
		<xbar.image>http://www.hosted-somewhere/pluginimage</xbar.image>
		<xbar.dependencies>python,ruby,node</xbar.dependencies>
		<xbar.abouturl>http://url-to-about.com/</xbar.abouturl>
	*/
		`)
	is.NoErr(err)
	is.Equal(md.Title, "Title goes here")
	is.Equal(md.Version, "v1.0")
	is.Equal(len(md.Authors), 1)
	is.Equal(md.Authors[0].Name, "Your Name")
	is.Equal(md.Authors[0].GitHubUsername, "your-github-username")
	is.Equal(md.Desc, "Short description of what your plugin does.")
	is.Equal(len(md.Dependencies), 3)
	is.Equal(md.Dependencies[0], "python")
	is.Equal(md.Dependencies[1], "ruby")
	is.Equal(md.Dependencies[2], "node")
	is.Equal(md.AboutURL, "http://url-to-about.com/")
	is.Equal(md.DocsCategory, "")
}

func TestPluginCategoryPathSegments(t *testing.T) {
	is := is.New(t)

	p := &Plugin{}
	p.CategoryPath = "Parent/Child/Grandchild/You"

	items := CategoryPathSegments(p.CategoryPath)
	is.Equal(4, len(items))

	is.Equal(items[0].Path, "Parent")
	is.Equal(items[0].Text, "Parent")
	is.Equal(items[1].Path, "Parent/Child")
	is.Equal(items[1].Text, "Child")
	is.Equal(items[2].Path, "Parent/Child/Grandchild")
	is.Equal(items[2].Text, "Grandchild")
	is.Equal(items[3].Path, "Parent/Child/Grandchild/You")
	is.Equal(items[3].Text, "You")

}

func TestVariables(t *testing.T) {
	is := is.New(t)

	md, err := Parse(DebugfNoop, "test.txt", `

	/*
		Variables can be specified and will become configurable
		via the xbar app.

		<xbar.var>string(VAR_NAME="Mat Ryer"): Your name.</xbar.var>
		<xbar.var>number(VAR_COUNTER=1): A counter.</xbar.var>
		<xbar.var>boolean(VAR_VERBOSE=true): Whether to be verbose or not.</xbar.var>
		<xbar.var>select(VAR_DISPLAY_STYLE="normal"): Which style to use. [small, normal, big]</xbar.var>
	*/
		`)
	is.NoErr(err)

	is.Equal(len(md.Vars), 4) // len(md.Vars)

	is.Equal(md.Vars[0].Name, "VAR_NAME")    // Name
	is.Equal(md.Vars[0].Label, "Name")       // Label
	is.Equal(md.Vars[0].Type, "string")      // Type
	is.Equal(md.Vars[0].Desc, "Your name.")  // Desc
	is.Equal(md.Vars[0].Default, "Mat Ryer") // Default

	is.Equal(md.Vars[1].Name, "VAR_COUNTER") // Name
	is.Equal(md.Vars[1].Label, "Counter")    // Label
	is.Equal(md.Vars[1].Type, "number")      // Type
	is.Equal(md.Vars[1].Desc, "A counter.")  // Desc
	is.Equal(md.Vars[1].Default, "1")        // Default

	is.Equal(md.Vars[2].Name, "VAR_VERBOSE")                   // Name
	is.Equal(md.Vars[2].Label, "Verbose")                      // Label
	is.Equal(md.Vars[2].Type, "boolean")                       // Type
	is.Equal(md.Vars[2].Desc, "Whether to be verbose or not.") // Desc
	is.Equal(md.Vars[2].Default, "true")                       // Default

	is.Equal(md.Vars[3].Name, "VAR_DISPLAY_STYLE")   // Name
	is.Equal(md.Vars[3].Label, "Display style")      // Label
	is.Equal(md.Vars[3].Type, "select")              // Type
	is.Equal(md.Vars[3].Desc, "Which style to use.") // Desc
	is.Equal(md.Vars[3].Default, "normal")           // Default
	is.Equal(len(md.Vars[3].Options), 3)             // Options
	is.Equal(md.Vars[3].Options[0], "small")         // Options
	is.Equal(md.Vars[3].Options[1], "normal")        // Options
	is.Equal(md.Vars[3].Options[2], "big")           // Options

}

func TestErrors(t *testing.T) {
	is := is.New(t)

	errs := map[string]string{
		"missing select options": `
			<xbar.var>select(VAR_STYLE="normal"): Missing options.</xbar.var>
		`,
		"empty select options": `
			<xbar.var>select(VAR_STYLE="normal"): Empty options. []</xbar.var>
		`,
		"default not in select options": `
			<xbar.var>select(VAR_STYLE="not-in-select"): Default not in the select of options. [one,two,three]</xbar.var>
		`,
		"malformed": `
			<xbar.var>select(VAR_STYLE="): Missing options.</xbar.var>
		`,
		"name needs VAR_ prefix": `
			<xbar.var>select(ABadName="): Names should begin with VAR_.</xbar.var>
		`,
	}
	for expected, src := range errs {
		t.Run(expected, func(t *testing.T) {
			is := is.New(t)
			_, err := Parse(DebugfNoop, "test.script", src)
			is.True(err != nil) // expected to error
			is.True(strings.Contains(err.Error(), expected))
		})
	}
}
