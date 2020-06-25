#!/bin/bash
# shellcheck disable=SC2155

gzdoom_configure() {
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

gzdoom_package_generic() {
	declare PackageName=$1
	shift
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	declare Version=$1
	shift
	declare -n Artifacts=$1
	shift

	declare Arch
	for Arch in ${Config[multiarch]}; do
		(
			declare OpenALDir=$(lookup_build_dir "OpenAL")
			declare DepsDir
			if [[ $PackageName == 'gzdoom' || $PackageName == 'raze' ]]; then
				DepsDir="$(lookup_build_dir "ZMusic")/$Arch"
			else
				DepsDir=$(lookup_build_dir "GZDoom-Deps-$Arch")
			fi

			declare ExcludeZMusic
			if [[ $PackageName == 'raze' ]]; then
				ExcludeZMusic='zmusic.dll'
			else
				ExcludeZMusic='zmusiclite.dll'
			fi

			mapfile -t ExtraFiles < <(find "$DepsDir" -iname '*.dll' -and -not -iname 'openal32.dll' -and -not -iname "$ExcludeZMusic")

			cd "$Arch/Release" || return

			if [[ -d fm_banks ]]; then
				ExtraFiles+=(fm_banks/*)
			fi

			7z a "../../$PackageName-$Arch-$Version.7z" \
				./*.exe ./*.pk3 soundfonts/* \
				"${ExtraFiles[@]}" \
				"$OpenALDir/bin/$Arch/openal32.dll" \
				-mx=9 &&
			7z a "../../$PackageName-$Arch-$Version.map.bz2" "$PackageName.map" -mx=9
		) &&
		Artifacts+=("$PackageName-$Arch-$Version.7z" "$PackageName-$Arch-$Version.map.bz2")
	done
}

gzdoom_package() {
	gzdoom_package_generic gzdoom "$@"
}

# shellcheck disable=SC2034
declare -A GZDoomWin=(
	[branch]='master'
	[build]=cmake_generic_build
	[configure]=gzdoom_configure
	[multiarch]='x64 x86'
	[outoftree]=1
	[package]=gzdoom_package
	[project]='GZDoom'
	[remote]='https://github.com/coelckers/gzdoom.git'
	[uploaddir]=gzdoom
	[vcs]=GitVCS
)
register_build GZDoomWin

# libmpg123 isn't distributed with it's MinGW deps and libsndfile is distributed
# in an installer. Additionally we want to provide fluidsynth which isn't
# provided in binary form by upstream, so it's easiest to just pull a GZDoom
# release as the source for dependencies.
gzdoom_null() {
	:
}

gzdoom_deps_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare Image=${Config[remote]##*/}
	7z x "$Image" '*.dll'
}

# shellcheck disable=SC2034
declare -A GZDoomDepsWin32=(
	[branch]=''
	[build]=gzdoom_null
	[configure]=gzdoom_deps_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=gzdoom_null
	[project]='GZDoom-Deps-x86'
	[remote]='https://zdoom.org/files/gzdoom/bin/gzdoom-bin-3-7-2.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep GZDoomDepsWin32

# shellcheck disable=SC2034
declare -A GZDoomDepsWin64=(
	[branch]=''
	[build]=gzdoom_null
	[configure]=gzdoom_deps_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=gzdoom_null
	[project]='GZDoom-Deps-x64'
	[remote]='https://zdoom.org/files/gzdoom/bin/gzdoom-bin-3-7-2-x64.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep GZDoomDepsWin64
