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
	cmake_vs_parallel CMakeArgs

	declare SDL20Dir=$(lookup_build_dir 'SDL-2.0')
	declare SDLmixer20Dir=$(lookup_build_dir 'SDL_mixer-2.0')
	declare SDLnet20Dir=$(lookup_build_dir 'SDL_net-2.0')

	CMakeArgs+=(
		"-DSDL2_INCLUDE_DIR=$SDL20Dir/include"
		"-DSDL2_LIBRARY=$SDL20Dir/lib/$Arch/SDL2.lib"
		"-DSDL2_MIXER_INCLUDE_DIR=$SDLmixer20Dir/include"
		"-DSDL2_MIXER_LIBRARY=$SDLmixer20Dir/lib/$Arch/SDL2_mixer.lib"
		"-DSDL2_NET_INCLUDE_DIR=$SDLnet20Dir/include"
		"-DSDL2_NET_LIBRARY=$SDLnet20Dir/lib/$Arch/SDL2_net.lib"
	)

	case "$Arch" in
	x64)
		CMakeArgs+=(
			'-GVisual Studio 15 2017 Win64'
			'-Tv141_xp'
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

	declare SDL20Dir=$(lookup_build_dir 'SDL-2.0')
	declare SDLmixer20Dir=$(lookup_build_dir 'SDL_mixer-2.0')
	declare SDLnet20Dir=$(lookup_build_dir 'SDL_net-2.0')

	declare Arch
	for Arch in ${Config[multiarch]}; do
		(
			cd "$Arch" &&
			7z a "../Eternity-$Arch-$Version.7z" \
				"$(pwd)"/source/Release/*.exe \
				"$(pwd)"/eecrashreport/Release/*.exe \
				"$ProjectDir/user" \
				"$ProjectDir/base" \
				"$SDL20Dir/lib/$Arch"/*.dll \
				"$SDLmixer20Dir/lib/$Arch"/*.dll \
				"$SDLnet20Dir/lib/$Arch"/*.dll \
				-mx=9 '-xr!.gitignore' '-xr!delete.me'
		) &&
		Artifacts+=("Eternity-$Arch-$Version.7z")
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
