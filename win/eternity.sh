#!/bin/bash
# shellcheck disable=SC2155

eternity_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	cmake_vs_cflags CMakeArgs -d

	case "$Arch" in
	x64)
		CMakeArgs+=(
			'-GVisual Studio 16 2019'
			'-Ax64'
		)
		;;
	x86)
		CMakeArgs+=(
			'-GVisual Studio 15 2017'
			'-Tv141_xp'
		)
		;;
	esac

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

eternity_package() {
	declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Version=$1
	shift
	declare -n Artifacts=$1
	shift

	declare Arch
	for Arch in ${Config[multiarch]}; do
		(
			cd "$Arch" &&
			7z a "../Eternity-$Arch-$Version.7z" \
				"$(pwd)"/eternity/Release/*.* \
				"$ProjectDir/user" \
				"$ProjectDir/base" \
				-mx=9 '-xr!.gitignore' '-xr!delete.me' '-x!*.map' &&
			7z a "../Eternity-$Arch-$Version.map.xz" "$(pwd)/eternity/Release/eternity.map" -mx=9
		) &&
		Artifacts+=("Eternity-$Arch-$Version.7z" "Eternity-$Arch-$Version.map.xz")
	done
}

# shellcheck disable=SC2034
declare -A EternityWin=(
	[branch]='master'
	[build]=cmake_generic_build
	[configure]=eternity_configure
	[multiarch]='x64 x86'
	[outoftree]=1
	[package]=eternity_package
	[project]='Eternity'
	[remote]='https://github.com/team-eternity/eternity.git'
	[uploaddir]=eternity
	[vcs]=GitVCS
)
register_build EternityWin
