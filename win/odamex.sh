#!/bin/bash
# shellcheck disable=SC2155

odamex_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	cmake_vs_cflags CMakeArgs

	declare SDL20Dir=$(lookup_build_dir 'SDL-2.0')
	declare SDLmixer20Dir=$(lookup_build_dir 'SDL_mixer-2.0')

	CMakeArgs+=(
		"-DSDL2_INCLUDE_DIR=$SDL20Dir/include"
		"-DSDL2_LIBRARY=$SDL20Dir/lib/$Arch/SDL2.lib"
		"-DSDL2_MIXER_INCLUDE_DIR=$SDLmixer20Dir/include"
		"-DSDL2_MIXER_LIBRARY=$SDLmixer20Dir/lib/$Arch/SDL2_mixer.lib"
		"-DWINSOCK2_LIBRARY=/c/Program Files (x86)/Windows Kits/10/Lib/10.0.17763.0/um/$Arch/WS2_32.Lib"
		"-DIPHLPAPI_LIBRARY=/c/Program Files (x86)/Windows Kits/10/Lib/10.0.17763.0/um/$Arch/iphlpapi.lib"
	)

	case "$Arch" in
	x64)
		CMakeArgs+=(
			'-GVisual Studio 16 2019'
			'-Ax64'
		)
		;;
	x86)
		CMakeArgs+=(
			'-GVisual Studio 16 2019'
			'-AWin32'
		)
		;;
	esac

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

odamex_package() {
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

	declare Arch
	for Arch in ${Config[multiarch]}; do
		(
			cd "$Arch" &&
			7z a "../odamex-$Arch-$Version.7z" \
				"$(pwd)/client/Release/odamex.exe" \
				"$(pwd)/server/Release/odasrv.exe" \
				"$ProjectDir/odamex.wad" \
				"$SDL20Dir/lib/$Arch"/*.dll \
				"$SDLmixer20Dir/lib/$Arch"/*.dll \
				-mx=9
		) &&
		Artifacts+=("odamex-$Arch-$Version.7z")
	done
}

# shellcheck disable=SC2034
declare -A OdamexWin=(
	[branch]='stable'
	[build]=cmake_generic_build
	[configure]=odamex_configure
	[multiarch]='x64 x86'
	[outoftree]=1
	[package]=odamex_package
	[project]='Odamex'
	[remote]='https://github.com/odamex/odamex.git'
	[uploaddir]=odamex
	[vcs]=GitVCS
)
register_build OdamexWin
