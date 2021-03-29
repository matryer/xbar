package main

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"
)

// Category represents a group of plugins.
type Category struct {
	Path                 string     `json:"path"`
	Text                 string     `json:"text"`
	Children             []Category `json:"children"`
	CategoryPathSegments []PathItem `json:"categoryPathSegments"`
}

// PathItem is a path segment.
type PathItem struct {
	Path   string `json:"path"`
	Text   string `json:"text"`
	IsLast bool   `json:"isLast"`
}

// CategoriesService access category information.
type CategoriesService struct {
	baseURL string
	client  *http.Client
}

// NewCategoriesService makes a new CategoriesService.
func NewCategoriesService(client *http.Client) *CategoriesService {
	return &CategoriesService{
		baseURL: "https://xbarapp.com/docs",
		client:  client,
	}
}

// GetCategories gets the categories from the remote server.
func (c *CategoriesService) GetCategories() ([]Category, error) {
	req, err := http.NewRequest("GET", c.baseURL+"/plugins/categories.json", nil)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(req.Context(), apiRequestTimeout)
	defer cancel()
	req = req.WithContext(ctx)
	res, err := c.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var payload struct {
		Categories []Category `json:"categories"`
	}
	err = json.Unmarshal(body, &payload)
	if err != nil {
		return nil, err
	}
	return payload.Categories, nil
}
