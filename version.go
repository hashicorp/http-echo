package main

import (
	"bytes"
	"fmt"
)

var (
	Name      string = "http-eacho"
	Version   string = "0.1.1"
	GitCommit string
)

func formattedVersion() string {
	var versionString bytes.Buffer
	fmt.Fprintf(&versionString, "%s v%s", Name, Version)

	if GitCommit != "" {
		fmt.Fprintf(&versionString, " (%s)", GitCommit)
	}

	return versionString.String()
}
