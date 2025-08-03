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
		'-GVisual Studio 17 2022'
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
	[remote]='https://github.com/ZDoom/Raze.git'
	[uploaddir]=raze
	[vcs]=GitVCS
)
register_build RazeWin

# shellcheck disable=SC2034
declare -A RazeDepsWin64=(
        [branch]=''
        [build]=gzdoom_null
        [configure]=gzdoom_deps_configure
        [multiarch]='all'
        [outoftree]=0
        [package]=gzdoom_null
        [project]='Raze-Deps-x64'
        [remote]='https://github.com/ZDoom/Raze/releases/download/1.10.2/raze-1.10.2-windows.zip'
        [uploaddir]=''
        [vcs]=DownloadVCS
)
register_dep RazeDepsWin64
