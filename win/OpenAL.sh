#!/bin/bash

OpenAL_null() {
	:
}

OpenAL_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare Image=${Config[remote]##*/}
	extract_and_flatten "$Image"

	# Fixup filenames to be easier to manage
	mv bin/Win32 bin/x86
	mv bin/x86/soft_oal.dll bin/x86/openal32.dll
	mv bin/Win64 bin/x64
	mv bin/x64/soft_oal.dll bin/x64/openal32.dll
}

# shellcheck disable=SC2034
declare -A OpenALWin=(
	[branch]=''
	[build]=OpenAL_null
	[configure]=OpenAL_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=OpenAL_null
	[project]='OpenAL'
	[remote]='https://openal-soft.org/openal-binaries/openal-soft-1.21.1-bin.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep OpenALWin
