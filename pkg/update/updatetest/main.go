package main

import (
	"errors"
	"fmt"
	"log"
	"os"

	"github.com/matryer/xbar/pkg/update"
)

func main() {
	log.Println("Running...")
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%v\n", err)
		os.Exit(1)
	}
}

func run() error {
	if os.Getenv("XBAR_UPDATE_RESTART_COUNTER") != "" {
		return errors.New("skipping, already restarted")
	}
	u := update.Updater{}
	u.Restart()
	return nil
}
