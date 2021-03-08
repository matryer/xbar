package metadata

import (
	"path"
	"time"
)

// Category is a path segment, like a category.
type Category struct {
	Path string `json:"path"`
	Text string `json:"text"`

	Children           []Category          `json:"children"`
	ChildrenCategories map[string]Category `json:"-"`

	CategoryPathSegments []PathItem `json:"categoryPathSegments"`
	LastUpdated          time.Time  `json:"lastUpdated"`
}

// LastUpdatedFormatted is a formatted string.
func (c Category) LastUpdatedFormatted() string {
	return c.LastUpdated.Format(time.RFC822)
}

// CategoryWalk walks all category objects in the tree calling
// fn for each.
func CategoryWalk(categories map[string]Category, fn func(Category)) {
	for _, category := range categories {
		fn(category)
		if len(category.ChildrenCategories) > 0 {
			CategoryWalk(category.ChildrenCategories, fn)
		}
	}
}

func CategoryEnsurePath(categories map[string]Category, parentPath []string, pathCategorySegments []string) {
	if len(pathCategorySegments) == 0 {
		// no work to do
		return
	}
	categoryName := pathCategorySegments[0]
	category, ok := categories[categoryName]
	if !ok {
		pathSegs := append(parentPath, categoryName)
		categoryPath := path.Join(pathSegs...)
		category = Category{
			Path:                 categoryPath,
			Text:                 categoryName,
			ChildrenCategories:   make(map[string]Category),
			LastUpdated:          time.Now(),
			CategoryPathSegments: CategoryPathSegments(categoryPath),
		}
		categories[categoryName] = category
	}
	if len(pathCategorySegments) > 1 {
		CategoryEnsurePath(category.ChildrenCategories, append(parentPath, pathCategorySegments[0]), pathCategorySegments[1:])
	}
}
