#!/usr/local/bin/bash-5.1

eternity_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	CMakeArgs+=(
		'-G' 'Xcode'
	)

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

eternity_package() {
	#declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	declare Version=$1
	shift
	declare -n Artifacts=$1
	shift

	sign_app "x86_64/macosx/launcher/Release/Eternity Engine.app" &&
	make_dmg 'Eternity Engine' "eternity-$Version.dmg" "x86_64/macosx/launcher/Release/Eternity Engine.app" || return

	Artifacts+=("eternity-$Version.dmg")
}

# shellcheck disable=SC2034
declare -A EternityMac=(
	[branch]='master'
	[build]=cmake_generic_build
	[configure]=eternity_configure
	[multiarch]='x86_64'
	[outoftree]=1
	[package]=eternity_package
	[project]='Eternity'
	[remote]='git@github.com:team-eternity/eternity.git'
	[uploaddir]=eternity-mac
	[vcs]=GitVCS
)
register_build EternityMac
