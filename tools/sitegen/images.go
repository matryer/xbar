package main

import (
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path"
	"path/filepath"
	"sync"

	"github.com/matryer/xbar/pkg/metadata"
	"github.com/pkg/errors"
)

type imageDownloader struct {
	client    *http.Client
	outputDir string
}

func (d *imageDownloader) DownloadImages(plugins []metadata.Plugin) {
	// ten work slots
	sem := make(chan struct{}, 20)
	var wg sync.WaitGroup
	for i := range plugins {
		wg.Add(1)
		go func(plugin *metadata.Plugin) {
			defer wg.Done()
			// wait for a slot
			sem <- struct{}{}
			defer func() {
				// free up a slot
				<-sem
			}()
			if err := d.downloadImage(plugin); err != nil {
				log.Println("ERR:", errors.Wrap(err, "DownloadImages"))
			}
		}(&plugins[i])
	}
	wg.Wait()
}

func (d *imageDownloader) downloadImage(plugin *metadata.Plugin) error {
	ext := path.Ext(plugin.ImageURL)
	imagePath := plugin.Path + ext
	_, err := os.Stat(imagePath)
	if nil == err {
		// the image is already there, no work to do
		return nil
	}
	if plugin.ImageURL == "" {
		plugin.ProcessingNotes = append(plugin.ProcessingNotes, "missing image URL")
		return nil
	}
	resp, err := d.client.Get(plugin.ImageURL)
	if err != nil {
		plugin.ProcessingNotes = append(plugin.ProcessingNotes, fmt.Sprintf("unable to access image: %s", err))
		return nil
	}
	defer resp.Body.Close()
	if resp.StatusCode < 200 && resp.StatusCode >= 400 {
		plugin.ProcessingNotes = append(plugin.ProcessingNotes, fmt.Sprintf("unable to access image: got %d HTTP status code", resp.StatusCode))
		return nil
	}
	fullImagePath := filepath.Join(d.outputDir, "plugins", imagePath)
	if err := os.MkdirAll(filepath.Dir(fullImagePath), 0777); err != nil {
		return err
	}
	f, err := os.Create(fullImagePath)
	if err != nil {
		return errors.Wrap(err, "create")
	}
	defer f.Close()
	const mb = 1 << 20 // megabyte
	if resp.ContentLength > 5*mb {
		plugin.ProcessingNotes = append(plugin.ProcessingNotes, fmt.Sprintf("image too big, should be less than 5MB", resp.StatusCode))
		return nil
	}
	_, err = io.Copy(f, io.LimitReader(resp.Body, 5*mb))
	if err != nil {
		return errors.Wrap(err, "copy")
	}
	plugin.ImageURL = "https://xbarapp.com/docs/plugins/" + imagePath
	fmt.Print("🌆")
	return nil
}
