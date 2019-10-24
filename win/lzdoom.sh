#!/bin/bash
# shellcheck disable=SC2155

lzdoom_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	cmake_vs_cflags CMakeArgs
	CMakeArgs+=(
		'-DZDOOM_GENERATE_MAPFILE=ON'
	)

	case "$Arch" in
	x64)
		CMakeArgs+=(
			'-GVisual Studio 15 2017'
			'-Ax64'
		)
		;;
	x86)
		CMakeArgs+=(
			'-GVisual Studio 15 2017'
			'-AWin32'
			'-Tv141_xp'
		)
		;;
	esac

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

lzdoom_package() {
	gzdoom_package_generic lzdoom "$@"
}

# shellcheck disable=SC2034
declare -A LZDoomWin=(
	[branch]='g3.3mgw'
	[build]=cmake_generic_build
	[configure]=lzdoom_configure
	[multiarch]='x64 x86'
	[outoftree]=1
	[package]=lzdoom_package
	[project]='LZDoom'
	[remote]='https://github.com/drfrag666/gzdoom.git'
	[uploaddir]=lzdoom
	[vcs]=GitVCS
)
register_build LZDoomWin
