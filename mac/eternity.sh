#!/usr/local/bin/bash-5.1

eternity_build() {
	#declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	cd macosx || return
	xcodebuild -target eternity clean
	xcodebuild -target eternity DEVELOPMENT_TEAM="$MacDevelopmentTeam" || return

	mkdir -p builds
	cp build/Release/eternity builds/ || return

	cd launcher || return
	xcodebuild clean
	xcodebuild DEVELOPMENT_TEAM="$MacDevelopmentTeam" || return
}

eternity_configure() {
	:
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

	sign_app "macosx/launcher/build/Release/Eternity Engine.app" &&
	make_dmg 'Eternity Engine' "eternity-$Version.dmg" "macosx/launcher/build/Release/Eternity Engine.app" || return

	Artifacts+=("eternity-$Version.dmg")
}

# shellcheck disable=SC2034
declare -A EternityMac=(
	[branch]='master'
	[build]=eternity_build
	[configure]=eternity_configure
	[multiarch]='x86_64'
	[outoftree]=0
	[package]=eternity_package
	[project]='Eternity'
	[remote]='git@github.com:team-eternity/eternity.git'
	[uploaddir]=eternity-mac
	[vcs]=GitVCS
)
register_build EternityMac
