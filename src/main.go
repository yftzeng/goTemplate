package main

import (
	"flag"
	"fmt"
	"os"
)

var version = "unset"

func main() {
	versionPtr := flag.Bool("version", false, "show version.")
	flag.Parse()

	if *versionPtr != false {
		fmt.Printf("%s\n", version)
		os.Exit(0)
	}

	fmt.Printf("Start.\n")
}
