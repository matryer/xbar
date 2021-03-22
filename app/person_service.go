package main

import (
	"context"
	"encoding/json"
	"io/ioutil"
	"net/http"

	"github.com/matryer/xbar/pkg/metadata"
)

// PersonService provides people related functionality.
type PersonService struct {
	baseURL string
	Client  *http.Client
}

// NewPersonService makes a new PersonService.
func NewPersonService(client *http.Client) *PersonService {
	return &PersonService{
		Client:  client,
		baseURL: "https://xbarapp.com/docs",
	}
}

// PersonDetails are details relating to a human.
type PersonDetails struct {
	Person  *metadata.Person  `json:"person"`
	Plugins []metadata.Plugin `json:"plugins"`
}

// GetPersonDetails gets details about a human by their GitHub username.
func (p *PersonService) GetPersonDetails(githubUsername string) (*PersonDetails, error) {
	req, err := http.NewRequest("GET", p.baseURL+"/contributors/"+githubUsername+".json", nil)
	if err != nil {
		return nil, err
	}
	ctx, cancel := context.WithTimeout(req.Context(), apiRequestTimeout)
	defer cancel()
	req = req.WithContext(ctx)
	res, err := p.Client.Do(req)
	if err != nil {
		return nil, err
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		return nil, err
	}
	var payload *PersonDetails
	err = json.Unmarshal(body, &payload)
	if err != nil {
		return nil, err
	}
	return payload, nil
}
