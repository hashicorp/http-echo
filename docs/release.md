# Releasing `http-echo`

This repository uses HashiCorp's internal CRT process for releasing. 
IYKYK.

## Prepartion
1. You have the the `bob` CLI installed
1. You have all of the necessary rights that you would need to perform a Consul core release.
See those docs for more information.
1. The commit you intend to release from `main` has passed the CRT `build` and `prepare` workflows.

## Promote to staging

```bash
bob trigger-promotion \
  --product-name=http-echo \
  --repo=http-echo \
  --product-version="<version from version/VERSION>" \
  --sha="<commit you want to release>" \
  --environment="http-echo-oss" \
  --slack-channel="C0253EQ5B40" \
  --org="hashicorp" \
  --branch "main" \
  staging
```

## Promote to production
```bash
bob trigger-promotion \
  --product-name=http-echo \
  --repo=http-echo \
  --product-version="<version from version/VERSION>" \
  --sha="<commit you want to release>" \
  --environment="http-echo-oss" \
  --slack-channel="C0253EQ5B40" \
  --org="hashicorp" \
  --branch "main" \
  production
  ```

## Edit the GH Release

Manually edit the [new release page in GitHub](https://github.com/hashicorp/http-echo/releases/latest) to point to the release artifacts:

```
[Binaries can be downloaded here](https://releases.hashicorp.com/http-echo/${insert your version here}/).
```
