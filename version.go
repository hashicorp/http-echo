package main

import "fmt"

var (
	Name      string = "http-echo"
	Version   string = "0.1.3"
	GitCommit string

	humanVersion = fmt.Sprintf("%s v%s (%s)", Name, Version, GitCommit)
)
