#!/bin/bash

zmusic_null() {
	:
}

zmusic_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	7z x "${Config[remote]##*/}" || return

	# Fixup architecture names so they fit standard patterns
	mv 32bit x86
	mv 64bit x64
}

# shellcheck disable=SC2034
declare -A ZMusicWin=(
	[branch]=''
	[build]=zmusic_null
	[configure]=zmusic_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=zmusic_null
	[project]='ZMusic'
	[remote]='https://github.com/coelckers/ZMusic/releases/download/1.1.3/zmusic_1.1.3.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep ZMusicWin
