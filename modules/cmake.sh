#!/bin/bash
# shellcheck disable=SC2155

cmake_config_init() {
	declare -n Args=$1
	shift

	Args+=('-DCMAKE_BUILD_TYPE=Release')
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

	cmake --build . --clean-first -j "$(nproc)"
}
