#!/bin/bash
# shellcheck disable=SC2155

cmake_config_init() {
	declare -n Args=$1
	shift

	Args+=('-DCMAKE_BUILD_TYPE=Release')

	if [[ $(uname -o) == 'Msys' ]]; then
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

# Adds /MP to C and CXX flags for parallel Visual Studio builds
cmake_vs_parallel() {
	declare -n Args=$1
	shift

	Args+=(
		'-DCMAKE_C_FLAGS=-DWIN32 /D_WINDOWS /W3 /MP'
		'-DCMAKE_CXX_FLAGS=-DWIN32 /D_WINDOWS /W3 /GR /EHsc /MP'
	)
}
