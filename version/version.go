// Copyright IBM Corp. 2016, 2024
// SPDX-License-Identifier: MPL-2.0

package version

import "fmt"

const Name = "http-echo"

var (
	GitCommit string
	Version   string
	Timestamp string

	HumanVersion = fmt.Sprintf("%s v%s (%s)\nBuilt: %s", Name, Version, GitCommit, Timestamp)
)
