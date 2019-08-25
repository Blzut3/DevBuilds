#!/bin/bash

SDL20_null() {
	:
}

SDL20_configure() {
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
declare -A SDL20Win=(
	[branch]=''
	[build]=SDL20_null
	[configure]=SDL20_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL20_null
	[project]='SDL-2.0'
	[remote]='https://www.libsdl.org/release/SDL2-devel-2.0.10-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDL20Win

# shellcheck disable=SC2034
declare -A SDLmixer20Win=(
	[branch]=''
	[build]=SDL20_null
	[configure]=SDL20_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL20_null
	[project]='SDL_mixer-2.0'
	[remote]='https://www.libsdl.org/projects/SDL_mixer/release/SDL2_mixer-devel-2.0.4-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDLmixer20Win

# shellcheck disable=SC2034
declare -A SDLnet20Win=(
	[branch]=''
	[build]=SDL20_null
	[configure]=SDL20_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL20_null
	[project]='SDL_net-2.0'
	[remote]='https://www.libsdl.org/projects/SDL_net/release/SDL2_net-devel-2.0.1-VC.zip'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDLnet20Win
