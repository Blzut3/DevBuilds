#!/bin/bash

SDL12_null() {
	:
}

SDL12_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	declare Image=${Config[remote]##*/}
	extract_and_flatten "$Image"
}

# shellcheck disable=SC2034
declare -A SDL12Win=(
	[branch]=''
	[build]=SDL12_null
	[configure]=SDL12_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL12_null
	[project]='SDL-1.2'
	[remote]='https://maniacsvault.net/ecwolf/files/tools/dev/SDL-1.2-20230101.7z'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDL12Win
