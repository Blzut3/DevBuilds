#!/bin/bash
# shellcheck disable=SC2155

raze_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	cmake_vs_cflags CMakeArgs
	CMakeArgs+=(
		'-DCOMPILE_GENERATE_MAPFILE=ON'
		'-GVisual Studio 16 2019'
		'-Ax64'
	)

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

raze_package() {
	gzdoom_package_generic raze "$@"
}

# shellcheck disable=SC2034
declare -A RazeWin=(
	[branch]='master'
	[build]=cmake_generic_build
	[configure]=raze_configure
	[multiarch]='x64'
	[outoftree]=1
	[package]=raze_package
	[project]='Raze'
	[remote]='https://github.com/coelckers/raze.git'
	[uploaddir]=raze
	[vcs]=GitVCS
)
register_build RazeWin
