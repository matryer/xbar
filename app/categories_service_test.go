package main

import (
	"net/http"
	"testing"
	"time"

	"github.com/matryer/is"
)

func TestCategoryRepositoryGetCategories(t *testing.T) {
	is := is.New(t)

	cr := NewCategoriesService(&http.Client{Timeout: 1 * time.Second})
	cats, err := cr.GetCategories()
	is.NoErr(err)
	is.True(len(cats) > 0)

	cr.baseURL = "broken"
	cats, err = cr.GetCategories()
	is.True(err != nil)
	is.True(cats == nil)
}
