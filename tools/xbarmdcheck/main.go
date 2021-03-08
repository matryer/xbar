package main

import (
	"encoding/json"
	"fmt"
	"io"
	"os"

	"github.com/matryer/xbar/pkg/metadata"
)

func main() {
	if err := run(); err != nil {
		fmt.Fprintf(os.Stderr, "%s\n", err)
		os.Exit(1)
	}
}

func run() error {
	input, err := io.ReadAll(os.Stdin)
	if err != nil {
		return err
	}
	md, err := metadata.Parse(metadata.DebugfLog, "stdin", string(input))
	if err != nil {
		return err
	}
	b, err := json.MarshalIndent(md, "", "\t")
	if err != nil {
		return err
	}
	fmt.Println(string(b))
	if err := md.Validate(); err != nil {
		return err
	}
	return nil
}
