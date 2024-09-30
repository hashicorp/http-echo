# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

schema = "1"

project "http-echo" {
  // the team key is not used by CRT currently
  team = "team-consul"
  slack {
    notification_channel = "C0253EQ5B40"
  }
  github {
    organization = "hashicorp"
    repository = "http-echo"
    // An allow-list of branch names where artifacts are built. Note that wildcards are accepted! 
    // Artifacts built from these branches will be processed through CRT and get into a
    // "release ready" state.
    release_branches = [
      "main",
      "release/**" 
    ]
  }
}

event "merge" {
  // "entrypoint" to use if build is not run automatically
  // i.e. send "merge" complete signal to orchestrator to trigger build
}

event "build" {
  depends = ["merge"]
  action "build" {
    organization = "hashicorp"
    repository = "http-echo"
    workflow = "build"
  }
}

// Read more about what the `prepare` workflow does here:
// https://hashicorp.atlassian.net/wiki/spaces/RELENG/pages/2489712686/Dec+7th+2022+-+Introducing+the+new+Prepare+workflow
event "prepare" {
  depends = ["build"]

  action "prepare" {
    organization = "hashicorp"
    repository   = "crt-workflows-common"
    workflow     = "prepare"
    depends      = ["build"]
  }

  notification {
    on = "fail"
  }
}

## These are promotion and post-publish events
## they should be added to the end of the file after the verify event stanza.

event "trigger-staging" {
// This event is dispatched by the bob trigger-promotion command
// and is required - do not delete.
}

event "promote-staging" {
  depends = ["trigger-staging"]
  action "promote-staging" {
    organization = "hashicorp"
    repository = "crt-workflows-common"
    workflow = "promote-staging"
    config = "release.metadata.hcl"
  }

  notification {
    on = "always"
  }
}

event "promote-staging-docker" {
  depends = ["promote-staging"]
  action "promote-staging-docker" {
    organization = "hashicorp"
    repository = "crt-workflows-common"
    workflow = "promote-staging-docker"
  }

  notification {
    on = "always"
  }
}

event "trigger-production" {
// This event is dispatched by the bob trigger-promotion command
// and is required - do not delete.
}

event "promote-production" {
  depends = ["trigger-production"]
  action "promote-production" {
    organization = "hashicorp"
    repository = "crt-workflows-common"
    workflow = "promote-production"
  }

  notification {
    on = "always"
  }
}

event "promote-production-docker" {
  depends = ["promote-production"]
  action "promote-production-docker" {
    organization = "hashicorp"
    repository = "crt-workflows-common"
    workflow = "promote-production-docker"
  }

  notification {
    on = "always"
  }
}


event "bump-version-patch" {
  depends = ["promote-production-docker"]
  action "bump-version" {
    organization = "HashiCorp-RelEng-Dev"
    repository = "crt-workflows-common"
    workflow = "bump-version"
  }

  notification {
    on = "fail"
  }
}
