package metadata

import (
	"testing"

	"github.com/matryer/is"
)

func TestCategoryMapper(t *testing.T) {
	is := is.New(t)

	categories := make(map[string]Category)
	CategoryEnsurePath(categories, nil, []string{"parent1", "child1", "grandchild1"})
	CategoryEnsurePath(categories, nil, []string{"parent1", "child2", "grandchild1"})
	CategoryEnsurePath(categories, nil, []string{"parent2", "Child1", "Grandchild1"})
	CategoryEnsurePath(categories, nil, []string{"parent3", "child1"})

	is.Equal(len(categories), 3)                                                            // parents
	is.Equal(len(categories["parent1"].ChildrenCategories), 2)                              // parent1 children
	is.Equal(len(categories["parent2"].ChildrenCategories["Child1"].ChildrenCategories), 1) // parent2 child1 grandchildren

	// b, err := json.MarshalIndent(segments, "", "\t")
	// is.NoErr(err)
	// log.Println(string(b))

}
