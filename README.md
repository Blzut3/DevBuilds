# DRD Team devbuilds scripts

This repository contains the scripts that are used to produce the nightly
[DRD Team development builds](https://devbuilds.drdteam.org/).

While the scripts here are largely complete save for upload credentials, they
do assume most of the build system is already setup. See the expected
environment sections for details on what should be installed.

What the scripts do capture are the build steps as well as any library
dependencies with the goal of demystifying what is or isn't being done.

# Code overview

The primary module is build.sh which processes all build configurations and
uploads all artifacts from the build. Each build is a structure defined in an
associative array (for which the schema is provided below) which is then
registered with the build process via register_build or register_dep (from
common.sh). The only difference between the two functions is all deps will be
processed before builds.

```
{
	branch: string
	build: fn(&Config, ProjectDir, Arch)
	configure: fn(&Config, ProjectDir, Arch)
	[multiarch: string] # Space separated
	outoftree: bool
	package: fn(&Config, ProjectDir, Version, &Artifacts)
	project: string
	remote: url
	uploaddir: string
	vcs: &{
		check: fn(Branch)
		clone: fn(Remote, Branch, Dir)
		describe: fn()
	}
}
```

The "vcs" property should be the name of a VCS variable defined in one of the
modules. The VCS object is driven by the build process and specifies how to
determine if there's anything new to build.

VCS objects only need to provide the specified interface and don't necessarily
need to be a version control system. For example dependencies will typically
use `DownloadVCS` which simply downloads a specified file.

All scripts are written in Bash using relatively modern features. Bash 4.4 is
required!

## Configuration

The following variables must be set in a config file. The location of this file
is `~/Library/Preferences/BuildServer/config.sh` on macOS and
`%LOCALAPPDATA%\BuildServer\config.sh` on Windows.

* **SSHBaseDirectory**
* **SSHIdentity** (id_rsa)
* **SSHServer**
* **SSHUsername**

On macOS the following are also required for app signing.

* **MacDeveloperID**
* **MacDevelopmentTeam**
* **KeychainPassword**

The config file, being a bash script, may of course contain other statements
such as setting the PATH.

## Execution

There is a platform specific entry point, but the interface for them is the
same.

```
start-<platform>.sh [-p <ProjectName>] [-f]
```

Normally the script is run with no arguments which will iterate over all the
build configurations and build any that changed. If desired a specific config
can be run by passing it's `project` name to `-p`. If no changes have occurred
`-f` can be used to override the revision check.

## macOS

The version of Bash that macOS provides is horribly outdated. Besides the
complexity of setting up the legacy compiler tool chains, it is required that
Bash 5.1 be compiled.

Signing keys are expected to be in a keychain called BuildServer under the
building user's account.

### Expected environment

* macOS 11
* Xcode 12
* [XcodeLegacy](https://github.com/devernay/xcodelegacy)
* [PowerPC cross compilers](http://maniacsvault.net/articles/powerpccross)
* Bash 5.1 (as /usr/local/bin/bash-5.1)
* CMake
* Git
* Mercurial
* xz

## Windows

For Windows the expected interpreter is git-bash. This results in some odd
behavior due to the automatic POSIX to Windows path conversion, but allows all
common code to be shared across platforms.

### Expected environment

* Windows 10 1809 or Windows Server 2019
* Visual Studio 2017
* Visual Studio 2005
* 7-Zip
* CMake > 3.11
* CMake 3.11 at C:\Program Files\CMake-3.11 (Final version for VS2005)
* Git (provides Bash)
* Mercurial
