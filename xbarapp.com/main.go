package main

import (
	_ "embed"
	"fmt"
	"net/http"
	"os"
	"path/filepath"
)

//go:embed .version
var version string

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}

func run() error {
	port := os.Getenv("PORT")
	if port == "" {
		port = "9000"
	}
	port = ":" + port
	http.Handle("/docs/", http.StripPrefix("/docs/", http.FileServer(http.Dir(filepath.Join("public", "docs")))))
	http.Handle("/public/img/", http.StripPrefix("/public/img/", http.FileServer(http.Dir(filepath.Join("public", "img")))))
	http.Handle("/public/css/", http.StripPrefix("/public/css/", http.FileServer(http.Dir(filepath.Join("public", "css")))))
	http.Handle("/dl", http.RedirectHandler("https://github.com/matryer/xbar/releases/latest", http.StatusFound))
	http.Handle("/", serveFileHandler(filepath.Join("public", "docs", "plugins", "index.html")))
	fmt.Printf("listening on 0.0.0.0%s\n", port)
	return http.ListenAndServe("0.0.0.0"+port, nil)
}

func serveFileHandler(filename string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		http.ServeFile(w, r, filename)
	}
}
