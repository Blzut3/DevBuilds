#!/bin/bash
# shellcheck disable=SC2155

uzdoom_package() {
	gzdoom_package_generic uzdoom "$@"
}

# shellcheck disable=SC2034
declare -A UZDoomWin=(
	[branch]='trunk'
	[build]=cmake_generic_build
	[configure]=gzdoom_configure
	[multiarch]='x64'
	[outoftree]=1
	[package]=uzdoom_package
	[project]='UZDoom'
	[remote]='https://github.com/UZDoom/uzdoom.git'
	[uploaddir]=uzdoom
	[vcs]=GitVCS
)
register_build UZDoomWin

# Pull the deps from the UZDoom release to make things easier.
uzdoom_null() {
	:
}

uzdoom_deps_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare Image=${Config[remote]##*/}
	7z x -aoa "$Image" '*.dll' || return

	rm -f zmusic.dll || return
	return 0
}

# shellcheck disable=SC2034
declare -A UZDoomDepsWin64=(
	[branch]=''
	[build]=uzdoom_null
	[configure]=uzdoom_deps_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=uzdoom_null
	[project]='UZDoom-Deps-x64'
	[remote]='https://github.com/UZDoom/UZDoom/releases/download/4.14.3/Windows-UZDoom-4.14.3.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep UZDoomDepsWin64
