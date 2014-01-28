---
title: Packager Documentation
---

## Table of Contents

* [Getting Started](#getting-started)
* [Integration Filters](#integration-filters)
  * [Default](#integration-filters-default)
  * [Branch-based integration filtering](#integration-filters-branch)
  * [Tag-based integration filtering](#integration-filters-tag)
* [The .packager file](#packager-file)
  * [JSON](#packager-file-json)
    * [EXAMPLE](#packager-json-example)
    * [Target](#packager-target)
      * [Platform](#packager-target-platform)
      * [Version](#packager-target-version)
      * [Package](#packager-target-package)
      * [Architecture](#packager-target-arch)
    * [Package Description](#packager-package-description)
    * [Source](#packager-source)
      * [Type](#packager-source-type)
      * [Location](#packager-source-location)
      * [Reference](#packager-source-reference)
      * [Remote](#packager-source-remote)
  * [DSL](#packager-file-dsl)

## Getting Started {#getting-started}

To get started using the Packager service, the first thing you need to do is enable a repository to notify Packager when a commit is pushed. 

## Integration Filters

Rather than allow every commit on every branch of a repository to trigger package builds, Packager provides integration filters to control which commits should generate packages. These filters can be configured from the Packager dashboard, or directly from the GitHub repository (manually editing the ServiceHook URL). 

### Default {#integration-filters-default}

By default, Packager will act on commits made to the 'master' branch. 

    http://api.packager.co:9876/github-commit

### Branch-based integration filtering {#integration-filters-branch}

Packager can optionally filter on a specific branch (this is essentially how the default filtering works). 

    http://api.packager.co:9876/github-commit?filter=<branch name>

### Tag-based integration filtering {#integration-filters-tag}

Packager can optionally filter on tagged commits (regardless of which branch these are committed to). 

    http://api.packager.co:9876/github-commit?tags=true

NOTE: branch-based and tag-based filtering cannot be used together. 

## The .packager File {#packager-file}

Packager is controlled by instructions described in a `.packager` configuration file in the root directory of your source code repository. This configuration file can be written in JSON (i.e. a Ruby `Hash`) or using a simple DSL (which is used to generate a `Hash` / JSON). We'll describe the available configuration file contents first, then we'll explain how to use the DSL to simplify generating more complex configuration files. 

### JSON {#packager-file-json}

_NOTE: The `.packager` configuration file is made up of four (4) primary sections, each containing a variety of "directives". Section and directive names are [snake cased](http://en.wikipedia.org/wiki/Snake_case), and always case-sensitive (i.e. lower-case, as inferred by snake casing)._

#### Example {#json-example}

~~~ json
{
  "target": {
    "platform": "ubuntu",
    "version": "12.04",
    "package": "deb",
    "arch": "amd64"
  },
  "dependencies": {
    "build": ["libpq-dev"],
    "runtime": ["libpq5"]
  },
  "build": {
    "name": "myapp",
    "template": "rails",
    "install_prefix", "/var/www/myapp"
  }
}
~~~

#### Target (`target`) {#packager-target}

|| Type | section
|| Required | false
|| Default value(s) | {'platform': 'ubuntu', 'version': '12.04', 'package': 'deb', 'arch': 'amd64'}

The `target` section describes the platform (i.e. operating system) the package(s) is/are being built for.

##### Platform (`platform`) {#packager-target-platform}

|| Type | directive
|| Required | false
|| Default value | `ubuntu`

The `platform` directive describes the name of the linux-distribution. Available platform options are as follows: 

* `ubuntu` (default)
* `centos`
* `debian`

##### Version (`version`) {#packager-target-version}

|| Type | directive
|| Required | false
|| Default value | `12.04`

The `version` directive describes the `platform` (i.e. linux distribution) version number. Available version numbers are as follows: 

* `12.04` (default; ubuntu)
* `12.10` (ubuntu)
* `13.04` (ubuntu)
* `13.10` (ubuntu)
* `13.10` (ubuntu)
* `5` (centos)
* `6` (centos, debian)
* `7` (debian)

_NOTE: the default value of '12.04' is not dynamic. In other words, it is always the default regardless of what the `platform` directive is set to. If a platform other than `ubuntu` is selected, the `version` directive is required._ 

##### Package (`package`) {#packager-target-package}

|| Type | directive
|| Required | false
|| Default value | `deb`

The `package` directive describes the package format. Available package formats are as follows:

* `deb` (ubuntu, debian)
* `rpm` (centos)

_NOTE: this option is currently unused as the values are inferred by the `platform` directive; but the `package` directive is scheduled to be introduced to allow for generation of non-system package formats (e.g. jar, gem, etc)._

##### Architecture (`arch`) {#packager-target-arch}

|| Type | directive
|| Required | false
|| Default value | `amd64`

The `arch` directive describes the target system architecture (i.e. 64-bit or 32-bit). Available options are as follows:

* `amd64` (default)
* `i386`

_NOTE: this option is currently unsupported, but documented here for posterity as 32-bit platforms could be supported in the future._

#### Package Description (`source` + `dependencies` + `build` sections) {#package-description}

In the Packager configuration file, the `target` section is a little bit different than the remaining three (3) sections: `source`, `dependencies`, and `build`. These three sections are used collectively to describe a package, and will be referred to through the documentation as the "package description" (this will become more important when we begin to explain how to describe trees of dependent packages). 

#### Source (`source`) {#packager-source}

|| Type | section
|| Required | true/auto
|| Default value | n/a

The `source` section describes where the source code that will be used to create the packages is located. 

_NOTE: the source section is automatically provided for root/top-level packages via the GitHub commit payload._

##### Type (`type`)

|| Type | directive
|| Required | false
|| Default value | n/a

The `type` directive describes what type of source endpoint Packager needs to interact with. Available options are as follows: 

* `git`
* `remote`

##### Location (`location`)

|| Type | directive
|| Required | true (for `git` source types)
|| Default value | n/a

The `location` direcetive describes the URI for non-`remote` source types (e.g. `git`). Available options are any valid git endpoint (i.e. http/https, or git/ssh endpoints). 

##### Reference (`reference`)

|||
||---------------|----------|
|| Type | directive
|| Required | false
|| Default value | 'master'

The `reference` directive describes the source code repository (i.e. git) reference containing the desired changeset (e.g. a specific branch, etc). Available options are any valid git reference (e.g. SHA checksum, branch name, etc). 

##### Remote File (`remote_file`)

|| Type | directive
|| Required | true (for `remote` source types)
|| Default value | n/a

The `remote_file` directive describes a URL where source code can be located. Valid values are any URL pointing to a gzip tarball of source code.

### The Packager DSL

## Package Dependencies

## EXAMPLE: how to build a Rails app installer package (verbose)

## Packager Templates

## EXAMPLE: how to build a Rails app installer package (using the :rails template)

## EXAMPLE: how to build Redis

## Advanced Topics

### GitHub Prereleases
