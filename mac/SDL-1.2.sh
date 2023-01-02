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

SDL12_build() {
	#declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	mac_target 10.4
	make -j$(nproc) && make install
}

SDL12_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare Sdk="$MacSdkPath/MacOSX10.6.sdk"
	declare Host=i386-apple-darwin10.8.0
	if [[ $Arch == 'ppc' ]]; then
		Sdk="$MacSdkPath/MacOSX10.5.sdk"
		Host=powerpc-apple-darwin10.8.0
	fi

	declare Flags="-isysroot $Sdk -mmacosx-version-min=10.4 -arch $Arch"

	mac_target 10.4
	CC=/usr/local/bin/gcc-4.2 CXX=/usr/local/bin/g++-4.2 CPP=/usr/bin/cpp \
		CFLAGS="$Flags" CXXFLAGS="$Flags" LDFLAGS="$Flags" \
		"$ProjectDir/configure" --prefix "$PWD/install" \
		--host="$Host" \
		--enable-shared --enable-static
}

# shellcheck disable=SC2034
declare -A SDL12Mac=(
	[branch]='main'
	[build]=SDL12_build
	[configure]=SDL12_configure
	[multiarch]='i386 ppc'
	[outoftree]=1
	[package]=SDL12_null
	[project]='SDL-1.2'
	[remote]='git@github.com:libsdl-org/SDL-1.2.git'
	[uploaddir]=''
	[vcs]=GitVCS
)
register_dep SDL12Mac

SDLnet12_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare SDL12Dir="$(lookup_build_dir 'SDL-1.2' "$Arch")"

	declare Sdk="$MacSdkPath/MacOSX10.6.sdk"
	declare Host=i386-apple-darwin10.8.0
	if [[ $Arch == 'ppc' ]]; then
		Sdk="$MacSdkPath/MacOSX10.5.sdk"
		Host=powerpc-apple-darwin10.8.0
	fi

	declare Flags="-isysroot $Sdk -mmacosx-version-min=10.4 -arch $Arch"

	mac_target 10.4
	CC=/usr/local/bin/gcc-4.2 CXX=/usr/local/bin/g++-4.2 CPP=/usr/bin/cpp \
		CFLAGS="$Flags" CXXFLAGS="$Flags" LDFLAGS="$Flags" \
		"$ProjectDir/configure" --prefix "$PWD/install" \
		--host="$Host" \
		--enable-shared --enable-static \
		--with-sdl-prefix="$SDL12Dir/install"
}

# shellcheck disable=SC2034
declare -A SDLnet12Mac=(
	[branch]='SDL-1.2'
	[build]=SDL12_build
	[configure]=SDLnet12_configure
	[multiarch]='i386 ppc'
	[outoftree]=1
	[package]=SDL12_null
	[project]='SDL_net-1.2'
	[remote]='git@github.com:libsdl-org/SDL_net.git'
	[uploaddir]=''
	[vcs]=GitVCS
)
register_dep SDLnet12Mac
