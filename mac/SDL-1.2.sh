#!/usr/local/bin/bash-5.1

SDL12_null() {
	:
}

SDL12_extract_framework() {
	declare DestDir=$1
	shift
	declare Framework=$1
	shift

	cp -a "$Framework" "$DestDir"
}

SDL12_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	rm -rf SDL.framework

	declare Image=${Config[remote]##*/}
	mount_dmg "$Image" SDL12_extract_framework SDL.framework
}

# shellcheck disable=SC2034
declare -A SDL12Mac=(
	[branch]=''
	[build]=SDL12_null
	[configure]=SDL12_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL12_null
	[project]='SDL-1.2'
	[remote]='https://www.libsdl.org/release/SDL-1.2.15-OSX10.4.dmg'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDL12Mac

SDLnet12_configure() {
	declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	rm -rf SDL_net.framework

	declare Image=${Config[remote]##*/}
	mount_dmg "$Image" SDL12_extract_framework SDL_net.framework || return

	# Change to @rpath to avoid the link time error
	install_name_tool -change {@executable_path/../Frameworks,@rpath}/SDL.framework/Versions/A/SDL SDL_net.framework/Versions/A/SDL_net &&
	install_name_tool -id @rpath/SDL_net.framework/Versions/A/SDL_net SDL_net.framework/Versions/A/SDL_net
}

# shellcheck disable=SC2034
declare -A SDLnet12Mac=(
	[branch]=''
	[build]=SDL12_null
	[configure]=SDLnet12_configure
	[multiarch]='all'
	[outoftree]=0
	[package]=SDL12_null
	[project]='SDL_net-1.2'
	[remote]='https://www.libsdl.org/projects/SDL_net/release/SDL_net-1.2.7.dmg'
	[uploaddir]=''
	[vcs]=DownloadVCS
)
register_dep SDLnet12Mac
