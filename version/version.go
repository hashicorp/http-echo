// Copyright (c) HashiCorp, Inc.
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
