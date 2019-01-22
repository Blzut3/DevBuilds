#!/bin/bash
# shellcheck disable=SC2155

ecwolf_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	cmake_vs_parallel CMakeArgs
	CMakeArgs+=(
		'-DINTERNAL_SDL_MIXER=ON'
		'-DINTERNAL_SDL_MIXER_CODECS=ON'
	)

	case "$Arch" in
	x64)
		CMakeArgs+=(
			'-GVisual Studio 15 2017 Win64'
			'-Tv141_xp'
			'-DINTERNAL_SDL=ON' '-DINTERNAL_SDL_NET=ON'
		)
		;;
	x86)
		CMakeArgs+=(
			'-GVisual Studio 15 2017'
			'-Tv141_xp'
			'-DINTERNAL_SDL=ON' '-DINTERNAL_SDL_NET=ON'
		)
		;;
	legacy)
		declare SDL12Dir=$(lookup_build_dir 'SDL-1.2')
		declare SDLnet12Dir=$(lookup_build_dir 'SDL_net-1.2')
		CMakeArgs+=(
			'-GVisual Studio 8 2005'
			'-DCMAKE_WARN_VS8=OFF'
			'-DINTERNAL_SDL=OFF'
			'-DINTERNAL_SDL_NET=OFF'
			'-DFORCE_SDL12=ON'
			"-DSDL_LIBRARY=$SDL12Dir/lib/x86/SDL.lib"
			"-DSDL_INCLUDE_DIR=$SDL12Dir/include"
			"-DSDL_NET_LIBRARY=$SDLnet12Dir/lib/x86/SDL_net.lib"
			"-DSDL_NET_INCLUDE_DIR=$SDLnet12Dir/include"
		)
		;;
	esac

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

ecwolf_package() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	declare Version=$1
	shift
	declare -n Artifacts=$1
	shift

	declare SDL12Dir=$(lookup_build_dir 'SDL-1.2')
	declare SDLnet12Dir=$(lookup_build_dir 'SDL_net-1.2')

	declare Arch
	for Arch in ${Config[multiarch]}; do
		(
			declare -a ExtraFiles=()
			if [[ $Arch == 'legacy' ]]; then
				ExtraFiles+=("$SDL12Dir/lib/x86/SDL.dll" "$SDLnet12Dir/lib/x86/SDL_net.dll")
			fi

			cd "$Arch/Release" &&
			7z a "../../ecwolf-$Arch-$Version.7z" \
				./*.exe ./*.pk3 "${ExtraFiles[@]}" \
				-mx=9
		) &&
		Artifacts+=("ecwolf-$Arch-$Version.7z")
	done
}

# shellcheck disable=SC2034
declare -A ECWolfWin=(
	[branch]='@'
	[build]=cmake_generic_build
	[configure]=ecwolf_configure
	[multiarch]='x64 x86'
	[outoftree]=1
	[package]=ecwolf_package
	[project]='ECWolf'
	[remote]='https://bitbucket.org/ecwolf/ecwolf'
	[uploaddir]=ecwolf
	[vcs]=MercurialVCS
)
register_build ECWolfWin
