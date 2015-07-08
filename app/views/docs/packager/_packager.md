# Getting Started {#getting-started}

To get started using the Packager service, the first thing you need to do is
enable a repository to notify Packager when a commit is pushed.

To enable a repository, visit the Packager dashboard at
<%= link_to('/pipeline/packager/repositories',
'https://packager.co/pipeline/packager/repositories') %>,
input the name of the repository you wish to enable, then select "Enable".

Once enabled, a new Packager job will be created for every tag created in the
repository and packages will be published to the originating GitHub repository
via <%= link_to('GitHub Releases',
'https://help.github.com/articles/creating-releases/') %>.

# The .packager File {#packager-file}

Packager is controlled by instructions described in a `.packager` configuration
file in the root directory of your source code repository. This configuration
file can be written in JSON or using a simple DSL, both of which are used to
compile a ruby Hash (at runtime). We'll describe the available configuration
file contents first, then we'll explain how to use the DSL to simplify
generating more complex configuration files.

## JSON {#packager-file-json}

_NOTE: The `.packager` configuration file is made up of four (4) primary
sections, each containing a variety of "directives". Section and directive names
are [snake_cased](http://en.wikipedia.org/wiki/Snake_case), and always
case-sensitive (i.e. lower-case, as inferred by snake casing)._

### EXAMPLE {#json-example}

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
    "install_prefix": "/var/www/myapp"
  }
}
~~~

### Target (`target`) {#packager-target}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value(s) | `{"platform": "ubuntu", "version": "14.04", "package": "deb", "arch": "amd64"}` |

The `target` section describes the platform (i.e. operating system) the
package(s) is/are being built for.

#### Platform (`platform`) {#packager-target-platform}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"ubuntu"`|

The `platform` directive describes the name of the linux-distribution. Available
platform options are as follows:

* `ubuntu` (default)
* `centos`
* `debian`

#### Version (`version`) {#packager-target-version}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"14.04"` |

The `version` directive describes the `platform` (i.e. linux distribution)
version number. Available version numbers are as follows:

* `12.04` (ubuntu)
* `14.04` (default; ubuntu)
* `6` (centos, debian)
* `7` (centos, debian)
* `8` (debian)

_NOTE: the default value of '14.04' is not dynamic. In other words, it is always
the default regardless of what the `platform` directive is set to. If a platform
other than `ubuntu` is selected, the `version` directive is required (e.g. if
`platform` is set to `centos`, and the default `version` of `14.04` is not
changed, the job will fail because 'centos 14.04' does not exist)._

#### Package (`package`) {#packager-target-package}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"deb"`   |

The `package` directive describes the package format. Available package formats
are as follows:

* `deb` (ubuntu, debian)
* `rpm` (centos)

_NOTE: this option is currently unused as the values are inferred by the
`platform` directive; but the `package` directive is scheduled to be introduced
to allow for generation of non-system package formats (e.g. jar, gem, msi,
etc)._

#### Architecture (`arch`) {#packager-target-arch}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"amd64"` |

The `arch` directive describes the target system architecture (i.e. 64-bit or
32-bit). Available options are as follows:

* `amd64` (default)
* `i386`

_NOTE: this option is currently unsupported, but documented here for posterity
as 32-bit platforms could be supported in the future._

### Package Description (`source` + `dependencies` + `build` sections) {#package-description}

In the Packager configuration file, the `target` section is a little bit
different than the remaining three (3) sections: `source`, `dependencies`, and
`build`. These three sections are used collectively to describe a package, and
will be referred to throughout the documentation as the "package description"
(this will become more important when we begin to explain how to describe trees
of dependent packages).

### Source (`source`) {#packager-source}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | `Hash`    |
| Required         | true/auto |
| Default value    | n/a       |

The `source` section describes where the source code is located that will be
used to create the packages.

_NOTE: the source section is automatically provided for root/top-level packages
via the webhook generated from the Packager-enabled source code repository. If
a `source` configuration is provided for root/top-level packages, it will be
ignored._

#### Type (`type`) {#packager-source-type}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | true      |
| Default value    | `"git"`   |

The `type` directive describes what type of source endpoint Packager needs to
interact with. Available options are as follows:

* `git`
* `remote`

#### Location (`location`) {#packager-source-location}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | true (for `git` source types) |
| Default value    | n/a       |

The `location` directive describes the URI for non-`remote` source types (e.g.
`git`). Available options are any valid git endpoint (i.e. http/https, or
git/ssh endpoints).

#### Reference (`reference`) {#packager-source-reference}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"master"`|

The `reference` directive describes the source code repository reference (e.g.
a "git ref") containing the desired changeset (e.g. a specific branch, etc).
Available options are any valid git reference (e.g. SHA checksum, branch name,
etc).

#### Remote File (`remote_file`) {#packager-source-remote_file}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | true (for `remote` source types) |
| Default value    | n/a       |

The `remote_file` directive describes a URL where source code can be located.
Valid values are any URL pointing to a gzip tarball of source code.

### Dependencies (`dependencies`) {#packager-dependencies}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value    | `{}`      |

The `dependencies` section describes packages that are required to build or run
the in-scope package, including any custom dependency packages that Packager
should create.

#### Build Dependencies (`build`) {#packager-dependencies-build}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Array`   |
| Required         | false     |
| Default value    | `[]`      |

The `build` directive describes a list (Array) of package names required to
build the in-scope package. Valid values are any valid package name available on
the `target`:`platform`; valid packages can be provided by the system.

#### Runtime Dependencies (`runtime`) {#packager-dependencies-runtime}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Array`   |
| Required         | false     |
| Default value    | `[]`      |

The `runtime` directive describes a list (Array) of package names required to
run the in-scope package. Valid values are any valid package name available on
the `target`:`platform`; valid packages can be provided by the system, or
generated by Packager as custom dependency packages.

#### Package Dependencies (`package`) {#packager-dependencies-package}

_NOTE: this is an advanced concept; please proceed with caution!_

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value    | `{}`      |

The `package` directive describes a list (Hash) of dependency packages that
Packager should generate as runtime dependencies of the in-scope package. Each
dependent package requires a complete
["package description"](#package-description) (combination of `source` +
`dependencies` + `build` sections), and should be keyed by package name.

##### EXAMPLE

~~~ json
{
  "target": {
    ...
  },
  "source": {
    ...
  },
  "dependencies": {
    "runtime": ["mydependency"],
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
| Data Type        | `Hash`    |
| Required         | true      |
| Default value    | `{}`      |

The `build` section provides instructions on how to generate the package, and
includes optional directives for package installation configuration parameters
(e.g. 'install_prefix').

#### Name (`name`) {#packager-build-name}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | repository name or [`dependencies`][`package`][<key>] name |

The `name` directive provides the package name.

#### Version (`version`) {#packager-build-version}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | tag name (if available) or timestamp-based |

The `version` directive provides the package version.

#### Template (`template`) {#packager-build-template}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `String`  |
| Required         | false     |
| Default value    | `"generic"` |

The `template` directive provides Packager with instructions on which Packager
template to use. Packager templates provide `build` commands (specifically,
`commands`:`build` commands; see <a href=#packager-build-commands>Commands</a>
section, below).

Available options are as follows:

* `generic` (default)
* `rails`

_NOTE: templates provide default behaviors for building common application
packages (e.g. building install packages from Ruby on Rails applications).
Additional templates will become available over time. Please contact support for
the latest set of available templates._

#### Commands (`commands`) {#packager-build-commands}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Hash`    |
| Required         | true      |
| Default value    | n/a       |

The `commands` directive describes which commands should be run to build both
the in-scope package.

##### EXAMPLE

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
    }
  },
  "packaging": {
    ...
  }
}
~~~

There are up to five (5) available arrays of commands described within this
directive, which are executed in the following order:

1. `commands:before:dependencies`
2. `commands:after:dependencies`
3. `commands:before:build`
4. `commands:build` (required)
5. `commands:after:build`

##### Before (`before`) {#packager-build-commands-before}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value    | `{}`      |

List of commands to run before `depenedencies` are installed (if any), and/or
before running `build` commands (including build commands provided by a
Packager `template`).

##### After (`after`) {#packager-build-commands-after}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value    | `{}`      |

List of commands to run after `depenedencies` are installed (if any), and/or
after running `build` commands (including build commands provided by a
Packager `template`).

##### Build (`build`) {#packager-build-commands-build}

|                  |           |
|------------------|-----------|
| Type             | directive |
| Data Type        | `Array`   |
| Required         | true      |
| Default value    | `[]`      |

List of commands to run to generate the contents of the in-scope package. These
commands are only valid for the `generic` template (default behavior).
Alternatively, these commands may be provided by Packager templates, in which
case any values provided here will be ignored.

### Packaging (`packaging`) {#packager-packaging}

|                  |           |
|------------------|-----------|
| Type             | section   |
| Data Type        | `Hash`    |
| Required         | false     |
| Default value    | `{}`      |

The `packaging` section provides access to the underlying <%= link_to('fpm',
'https://github.com/jordansissel/fpm') %> options. All options available via
`fpm --help` (see: <%= link_to('https://github.com/jordansissel/fpm/wiki#usage',
'https://github.com/jordansissel/fpm/wiki#usage') %>) are available as
configuration directives within the the `packaging` section. Dashes are simply
replaced with underscores. For example, the `fpm` option `--after-install` would
be accessible at `after_install`.

#### EXAMPLE {#packager-packaging-example}

~~~ json
"packaging": {
  "maintainer": "Heavy Water",
  "vendor": "Heavy Water Operations, LLC",
  "description": "Heavy Water Website",
  "url": "http://heavywater.io",
  "prefix": "/usr/share/nginx/www"
}
~~~

### Environment Variables {#packager-environment-variables}

All Packager jobs run inside of lxc containers, and are run from the root
directory in an unpacked clone of the originating source code repository. The
following environment variables are available to leverage in the `.packager`
configuration file:

#### Package Directory (`$PKG_DIR`) {#packager-environment-variables-package-directory}

|                  |                      |
|------------------|----------------------|
| Type             | environment variable |
| Data Type        | `String`             |
| Required         | false                |
| Default value    | `/`                  |

The `$PKG_DIR` environment variable provides a reference to the root directory
of the target package. When used without providing a install `prefix` (via the
`fpm` passthrough options; see: <%= link_to('Packaging', '#packager-packaging')
%> above, and <%= link_to('https://github.com/jordansissel/fpm/wiki#usage',
'https://github.com/jordansissel/fpm/wiki#usage') %>), `$PKG_DIR` is also the
equivalent of the root directory (e.g. `/`) of the target system.

For example, outputting contents of `build` commands to `$PKG_DIR/usr/local/`
would result in those contents being installed on the target system in the
`/usr/local/` directory (including any subdirectories created during the build).

Using `$PKG_DIR` to indicate where package contents should be installed has some
advantages over the `"packaging": { "prefix": "/path/to/install/dir/"}`
directive, including providing the ability to install package contents to
multiple branching locations on the target system.

_NOTE: setting the `packaging:prefix` directive modifies the default value of
`$PKG_DIR`. For example, outputting contents of `build` commands to
`$PKG_DIR/usr/local/` **-AND-** setting the `packaging:prefix` directive to
`/path/to/install/dir` would result in the package contents getting install on
the target system at `/path/to/install/dir/usr/local/*` instead of
`/usr/local/*`._
