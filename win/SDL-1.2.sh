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
	[remote]='https://www.libsdl.org/release/SDL-devel-1.2.15-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDL12Win

# shellcheck disable=SC2034
declare -A SDLmixer12Win=(
	[branch]=''
	[build]=SDL12_null
	[configure]=SDL12_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL12_null
	[project]='SDL_mixer-1.2'
	[remote]='https://www.libsdl.org/projects/SDL_mixer/release/SDL_mixer-devel-1.2.12-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDLmixer12Win

# shellcheck disable=SC2034
declare -A SDLnet12Win=(
	[branch]=''
	[build]=SDL12_null
	[configure]=SDL12_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL12_null
	[project]='SDL_net-1.2'
	[remote]='https://www.libsdl.org/projects/SDL_net/release/SDL_net-devel-1.2.8-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDLnet12Win
