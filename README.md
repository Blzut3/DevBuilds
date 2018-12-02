# DRD Team devbuilds scripts

This repository contains the scripts that are used to produce the nightly
[DRD Team development builds](https://devbuilds.drdteam.org/).

While the scripts here are largely complete save for upload credentials, they
do assume most of the build system is already setup. In other words if you
wanted to for example run the Mac scripts you would be on your own as far as
setting up [XcodeLegacy](https://github.com/devernay/xcodelegacy), Bash 4.4,
and [cross compilers](http://maniacsvault.net/articles/powerpccross).

What the scripts do capture are the build steps as well as any library
dependencies with the goal of demystifying what is or isn't being done.

# Code overview

## Mac

In the mac directory are the build configuration modules. At the bottom of each
module there is an associative array that provides details about the project and
registers the code in the module with the build system.

The modules directory contains code that would be common with a hypothetical
Linux build system.  This includes how to work with version control as well as
the build process itself (build.sh).

start-mac.sh is the entry point.  It provides some library functions that are
Mac specific, as well as handling loading modules and kicking off the run_builds
function.

Scripts are written in Bash, heavily using modern Bash features. As a result
bash 4.4 or later must be installed to run.
