#!/bin/bash
# shellcheck disable=SC2155

cmake_config_init() {
	declare -n Args=$1
	shift

	Args+=('-DCMAKE_BUILD_TYPE=Release')

	if [[ $(uname -o 2> /dev/null) == 'Msys' ]]; then
		# Technically this is only for VS, but I think it would be harmless to
		# specify it for other compilers
		Args+=('-DCMAKE_CONFIGURATION_TYPES=Release')
	fi
}

cmake_generic_build() {
	#declare -n Config=$1
	shift
	#declare ProjectDir=$1
	shift
	#declare Arch=$1
	shift

	# On mac set the target environment build (required for legacy builds)
	declare MacOSVersion=$(cmake -L . | grep '^CMAKE_OSX_DEPLOYMENT_TARGET:STRING=')
	MacOSVersion=${MacOSVersion##*=}
	if [[ $MacOSVersion ]]; then
		mac_target "$MacOSVersion"
	fi

	declare -a ExtraArgs=(--clean-first)
	# Visual Studio generator won't work unless we specify Release explicitly
	if grep -q '^CMAKE_GENERATOR:INTERNAL=Visual Studio' CMakeCache.txt; then
		ExtraArgs+=(--config Release)
	fi

	# CMAKE_BUILD_PARALLEL_LEVEL is used instead of -j since -j is a quite new
	# cmake build tool feature.
	CMAKE_BUILD_PARALLEL_LEVEL=$(nproc) cmake --build . "${ExtraArgs[@]}"
}

# Sets up common flags for Visual Studio builds
# -d = Dynamic CRT
# -p = Generate PDB and map file
# -s = Disable parallel building
cmake_vs_cflags() {
	declare -n Args=$1
	shift

	# Have to use - instead of / for the first argument since git-bash will
	# interpret the slash at the start as a posix path and convert it when
	# passing to CMake.
	declare CFlags='-DWIN32 /D_WINDOWS /W3'
	declare CXXFlags='-DWIN32 /D_WINDOWS /W3 /GR /EHsc'
	declare CFlagsRelease='-DNDEBUG /O2 /Ob2'
	declare CXXFlagsRelease='-DNDEBUG /O2 /Ob2'
	declare LinkRelease='-INCREMENTAL:NO'

	declare GenerateDebugInfo=0
	declare Parallel=1
	declare StaticCRT=1

	declare Opt
	declare OPTIND=1
	while getopts ':dps' Opt; do
		case "$Opt" in
		d)
			StaticCRT=0
			;;
		p)
			GenerateDebugInfo=1
			;;
		s)
			Parallel=0
			;;
		esac
	done
	shift $((OPTIND-1))

	if (( GenerateDebugInfo )); then
		LinkRelease+=' /MAP /DEBUG'
	fi

	if (( Parallel )); then
		CFlags+=' /MP'
		CXXFlags+=' /MP'
	fi

	if (( StaticCRT )); then
		CFlagsRelease+=' /MT'
		CXXFlagsRelease+=' /MT'
	else
		CFlagsRelease+=' /MD'
		CXXFlagsRelease+=' /MD'
	fi

	Args+=(
		"-DCMAKE_C_FLAGS=$CFlags"
		"-DCMAKE_CXX_FLAGS=$CXXFlags"
		"-DCMAKE_C_FLAGS_RELEASE=$CFlagsRelease"
		"-DCMAKE_CXX_FLAGS_RELEASE=$CXXFlagsRelease"
		"-DCMAKE_EXE_LINKER_FLAGS_RELEASE=$LinkRelease"
	)
}
