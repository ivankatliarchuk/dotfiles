<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
**Table of Contents**

- [Go Module Upgrades](#go-module-upgrades)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Go Module Upgrades

Single dependency:

```sh
go get github.com/some/package@v1.2.3      # pin to a version
go get github.com/some/package@latest      # upgrade to latest
go get github.com/some/package@main        # upgrade to a branch
```

After updating, tidy the module graph:

```sh
go mod tidy
```

Upgrade all dependencies in a module path prefix:

```sh
go get $(go list -m -f '{{if not .Indirect}}{{.Path}}{{end}}' all | grep 'some/prefix')
```

Check what's outdated:

```sh
go list -m -u all                           # lists available upgrades
go list -m -u all 2>/dev/null | grep '\['   # only outdated ones
```

This repo also has a `go.tool.mod` for tool dependencies - bump those the same way but with:

```sh
GOWORK=off go get -modfile go.tool.mod github.com/some/tool@latest
```
