# Getting Started {#getting-started}

To get started using the Packager service, the first thing you need to do is enable a repository to notify Packager when a commit is pushed.

To enable a repository, visit the Packager dashboard at https://packager.co/dashboard, select **"Enable Repository"** and input the name of the repository you wish to enable, then select "Enable".

# Integration Filters

Rather than allow every commit on every branch of a repository to trigger package builds, Packager provides integration filters to control which commits should generate packages. These filters can be configured from the Packager dashboard, or directly from the GitHub repository (manually editing the ServiceHook URL).

## Default {#integration-filters-default}

By default, Packager will act on commits made to the 'master' branch.

    http://api.packager.co:9876/github-commit

## Branch-based integration filtering {#integration-filters-branch}

Packager can optionally filter on a specific branch (this is essentially how the default filtering works).

    http://api.packager.co:9876/github-commit?filter=<branch name>

## Tag-based integration filtering {#integration-filters-tag}

Packager can optionally filter on tagged commits (regardless of which branch these are committed to).

    http://api.packager.co:9876/github-commit?tags=true

# The .packager File {#packager-file}

Packager is controlled by instructions described in a `.packager` configuration file in the root directory of your source code repository. This configuration file can be written in JSON or using a simple DSL, both of which are used to compile a ruby Hash (at runtime). We'll describe the available configuration file contents first, then we'll explain how to use the DSL to simplify generating more complex configuration files.

## JSON {#packager-file-json}

_NOTE: The `.packager` configuration file is made up of four (4) primary sections, each containing a variety of "directives". Section and directive names are [snake_cased](http://en.wikipedia.org/wiki/Snake_case), and always case-sensitive (i.e. lower-case, as inferred by snake casing)._

### Example {#json-example}

~~~ json
{
  "target": {
    "platform": "ubuntu",
    "version": "12.04",
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

### Target (`target`) {#packager-target}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | Hash      |
| Required         | false     |
| Default value(s) | {'platform': 'ubuntu', 'version': '12.04', 'package': 'deb', 'arch': 'amd64'} |

The `target` section describes the platform (i.e. operating system) the package(s) is/are being built for.

#### Platform (`platform`) {#packager-target-platform}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | `ubuntu`  |

The `platform` directive describes the name of the linux-distribution. Available platform options are as follows:

* `ubuntu` (default)
* `centos`
* `debian`

#### Version (`version`) {#packager-target-version}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | `12.04`   |

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

#### Package (`package`) {#packager-target-package}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | `deb`     |

The `package` directive describes the package format. Available package formats are as follows:

* `deb` (ubuntu, debian)
* `rpm` (centos)

_NOTE: this option is currently unused as the values are inferred by the `platform` directive; but the `package` directive is scheduled to be introduced to allow for generation of non-system package formats (e.g. jar, gem, etc)._

#### Architecture (`arch`) {#packager-target-arch}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | `amd64`   |

The `arch` directive describes the target system architecture (i.e. 64-bit or 32-bit). Available options are as follows:

* `amd64` (default)
* `i386`

_NOTE: this option is currently unsupported, but documented here for posterity as 32-bit platforms could be supported in the future._

### Package Description (`source` + `dependencies` + `build` sections) {#package-description}

In the Packager configuration file, the `target` section is a little bit different than the remaining three (3) sections: `source`, `dependencies`, and `build`. These three sections are used collectively to describe a package, and will be referred to through the documentation as the "package description" (this will become more important when we begin to explain how to describe trees of dependent packages).

### Source (`source`) {#packager-source}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | Hash      |
| Required         | true/auto |
| Default value    | n/a       |

The `source` section describes where the source code that will be used to create the packages is located.

_NOTE: the source section is automatically provided for root/top-level packages via the GitHub commit payload._

#### Type (`type`) {#packager-source-type}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | true      |
| Default value    | git       |

The `type` directive describes what type of source endpoint Packager needs to interact with. Available options are as follows:

* `git`
* `remote`

#### Location (`location`) {#packager-source-location}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | true (for `git` source types) |
| Default value    | n/a       |

The `location` direcetive describes the URI for non-`remote` source types (e.g. `git`). Available options are any valid git endpoint (i.e. http/https, or git/ssh endpoints).

#### Reference (`reference`) {#packager-source-reference}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | 'master'  |

The `reference` directive describes the source code repository (i.e. git) reference containing the desired changeset (e.g. a specific branch, etc). Available options are any valid git reference (e.g. SHA checksum, branch name, etc).

#### Remote File (`remote_file`) {#packager-source-remote_file}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | true (for `remote` source types) |
| Default value    | n/a       |

The `remote_file` directive describes a URL where source code can be located. Valid values are any URL pointing to a gzip tarball of source code.

### Dependencies (`dependencies`) {#packager-dependencies}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | Hash      |
| Required         | false     |
| Default value    | {}        |

The `dependencies` section describes packages that should be generated by Packager that are required to build or run the in-scope package.

#### Build Dependencies (`build`) {#packager-dependencies-build}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Array     |
| Required         | false     |
| Default value    | []        |

The `build` directive describes a list (Array) of package names required to build the in-scope package. Valid values are any valid package name; valid packages can be provided by the system, or generated by Packager as dependent packages.

#### Runtime Dependencies (`runtime`) {#packager-dependencies-runtime}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Array     |
| Required         | false     |
| Default value    | []        |

The `runtime` directive describes a list (Array) of package names required to run the in-scope package. Valid values are any valid package name; valid packages can be provided by the system, or generated by Packager as dependent packages.

#### Package Dependencies (`package`) {#packager-dependencies-package}

_NOTE: this is an advanced concept; please proceed with caution._

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Hash      |
| Required         | false     |
| Default value    | {}        |

The `package` directive describes a list (Hash) of dependent packages Packager should generate (and make available in your repository) as either build or runtime dependencies of the in-scope package. Each dependent package requires a complete ["package description"](#package-description) (combination of `source` + `dependencies` + `build` sections), and should be keyed by package name.

EXAMPLE:

~~~ json
{
  "target": {
    ...
  },
  "source": {
    ...
  },
  "depdencies": {
    "build": ["mydependency"],
    "runtime": [],
    "package": {
      "mydependency": {
        "source": {
          ...
        },
        "dependencies": {
          ...
        },
        "build": {
          ...
        }
      }
    }
  },
  "build": {
    ...
  }
}
~~~

### Build (`build`) {#packager-build}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | Hash      |
| Required         | true      |
| Default value    | {}        |

The `build` section provides instructions on how to generate the package, and includes optional directives for package installation configuration parameters (e.g. 'install_prefix').

#### Name (`name`) {#packager-build-name}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | repository name or [`source`][`package`][<key>] name |

The `name` directive provides the package name.

#### Version (`version`) {#packager-build-version}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | tag name (if available) or timestamp-based |

The `version` directive provides the package version.

#### Template (`template`) {#packager-build-template}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | 'generic' |

The `template` directive provides Packager with instructions on which template to use. Available options are as follows:

* `generic` (default)
* `erlang`
* `rails`

#### Commands (`commands`) {#packager-build-commands}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Hash      |
| Required         | true      |
| Default value    | n/a       |

The `commands` directive describes which commands should be run to build both the in-scope package, as well as its dependent packages.

EXAMPLE:

~~~ json
{
  "target": {
    ...
  },
  "source": {
    ...
  },
  "depdencies": {
    ...
  },
  "build": {
    "name": ...,
    "version": ...,
    "template": ...,
    "commands": {
      "before": {
        "dependencies": [],
        "build": []
      },
      "after": {
        "dependencies": [],
        "build": []
      },
      "build": [
        "command 1",
        "command 2"
      ]
    },
    "configure": {
      ...
    }
  }
}
~~~

There are up to five (5) available arrays of commands described within this directive, which are executed in the following order:

1. `commands:before:dependencies`
2. `commands:after:dependencies`
3. `commands:before:build`
4. `commands:build`
5. `commands:after:build`

##### Before (`before`) {#packager-build-commands-before}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Hash      |
| Required         | false     |
| Default value    | {}        |

##### After (`after`) {#packager-build-commands-after}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Hash      |
| Required         | false     |
| Default value    | {}        |

##### Build (`build`) {#packager-build-commands-build}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Array     |
| Required         | true      |
| Default value    | []        |

#### Configure (`configure`) {#packager-build-configure}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | Hash      |
| Required         | false     |
| Default value    | {}        |

The `configure` directive describes package installation configuration instructions that will be passed along to the package manager at install time.

##### Install Prefix (`install_prefix`) {#packager-build-configure-install_prefix}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | String    |
| Required         | false     |
| Default value    | n/a       |

The `install_prefix` directive describes where the in-scope package should be installed (if other than the system and/or package manager default location). Valid values are any unix-style path (e.g. "/opt/myapp" ).

## The Packager DSL

# Package Dependencies

## EXAMPLE: how to build a Rails app installer package (verbose)

# Packager Templates

## EXAMPLE: how to build a Rails app installer package (using the :rails template)

## EXAMPLE: how to build Redis

# Advanced Topics

## GitHub Prereleases
