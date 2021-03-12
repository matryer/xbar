package main

import "net/http"

// downloadHandler gets an http.HandlerFunc that provides that
// latest release, and counts the download.
func downloadHandler() http.HandlerFunc {
	const url = "https://github.com/matryer/xbar/releases/latest"
	return func(w http.ResponseWriter, r *http.Request) {
		// todo: log this download
		http.Redirect(w, r, url, http.StatusFound)
	}
}
