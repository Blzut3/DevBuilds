#!/usr/local/bin/bash-5.1
# shellcheck disable=SC2155

ecwolf_configure() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Arch=$1
	shift

	declare -a CMakeArgs=()
	cmake_config_init CMakeArgs
	CMakeArgs+=(
		'-DINTERNAL_JPEG=ON' '-DINTERNAL_SDL_MIXER=ON'
		'-DINTERNAL_SDL_MIXER_CODECS=ON'
		-'DBUILD_BUNDLE=ON'
	)

	case "$Arch" in
	x86_64)
		mac_target 10.9
		CMakeArgs+=(
			'-DCMAKE_OSX_ARCHITECTURES=x86_64'
			"-DCMAKE_OSX_SYSROOT=$MacSdkPath/MacOSX10.11.sdk"
			'-DINTERNAL_SDL=ON' '-DINTERNAL_SDL_NET=ON'
		)
		;;
	arm64)
		mac_target 11.0
		declare NativeBuildDir=$(lookup_build_dir 'ECWolf' 'x86_64')
		CMakeArgs+=(
			'-DCMAKE_OSX_ARCHITECTURES=arm64'
			"-DCMAKE_OSX_SYSROOT=$MacSdkPath/MacOSX11.0.sdk"
			'-DINTERNAL_SDL=ON' '-DINTERNAL_SDL_NET=ON'
			'-DFORCE_CROSSCOMPILE=ON'
			"-DIMPORT_EXECUTABLES=$NativeBuildDir/ImportExecutables.cmake"
		)
		;;
	i386)
		mac_target 10.4
		declare NativeBuildDir=$(lookup_build_dir 'ECWolf' 'x86_64')
		declare SDL12Dir="$(lookup_build_dir 'SDL-1.2' i386)/install"
		declare SDLnet12Dir="$(lookup_build_dir 'SDL_net-1.2' i386)/install"
		CMakeArgs+=(
			'-DCMAKE_OSX_ARCHITECTURES=i386'
			"-DCMAKE_OSX_SYSROOT=$MacSdkPath/MacOSX10.6.sdk"
			'-DCMAKE_SKIP_RPATH=ON'
			'-DCMAKE_C_COMPILER=/usr/local/bin/gcc-4.2'
			'-DCMAKE_CXX_COMPILER=/usr/local/bin/g++-4.2'
			"-DIMPORT_EXECUTABLES=$NativeBuildDir/ImportExecutables.cmake"
			'-DFORCE_CROSSCOMPILE=ON'
			'-DINTERNAL_SDL=OFF'
			'-DINTERNAL_SDL_NET=OFF'
			'-DFORCE_SDL12=ON'
			'-DHAVE_SMMINTRIN_H=1'
			"-DSDL_LIBRARY=$SDL12Dir/lib/libSDL.a;-framework cocoa;-framework OpenGL;-framework ApplicationServices;-framework Carbon;-framework AudioToolbox;-framework AudioUnit;-framework IOKit"
			"-DSDL_INCLUDE_DIR=$SDL12Dir/include/SDL"
			"-DSDL_NET_LIBRARY=$SDLnet12Dir/lib/libSDL_net.a"
			"-DSDL_NET_INCLUDE_DIR=$SDLnet12Dir/include/SDL"
		)
		;;
	ppc)
		mac_target 10.4
		declare NativeBuildDir=$(lookup_build_dir 'ECWolf' 'x86_64')
		declare SDL12Dir="$(lookup_build_dir 'SDL-1.2' ppc)/install"
		declare SDLnet12Dir="$(lookup_build_dir 'SDL_net-1.2' ppc)/install"
		CMakeArgs+=(
			'-DCMAKE_OSX_ARCHITECTURES=ppc'
			"-DCMAKE_OSX_SYSROOT=$MacSdkPath/MacOSX10.5.sdk"
			'-DCMAKE_SKIP_RPATH=ON'
			'-DCMAKE_C_COMPILER=/usr/local/bin/gcc-4.2'
			'-DCMAKE_CXX_COMPILER=/usr/local/bin/g++-4.2'
			'-DFORCE_CROSSCOMPILE=ON'
			"-DIMPORT_EXECUTABLES=$NativeBuildDir/ImportExecutables.cmake"
			'-DINTERNAL_SDL=OFF'
			'-DINTERNAL_SDL_NET=OFF'
			'-DFORCE_SDL12=ON'
			"-DSDL_LIBRARY=$SDL12Dir/lib/libSDL.a;-framework cocoa;-framework OpenGL;-framework ApplicationServices;-framework Carbon;-framework AudioToolbox;-framework AudioUnit;-framework IOKit"
			"-DSDL_INCLUDE_DIR=$SDL12Dir/include/SDL"
			"-DSDL_NET_LIBRARY=$SDLnet12Dir/lib/libSDL_net.a"
			"-DSDL_NET_INCLUDE_DIR=$SDLnet12Dir/include/SDL"
		)
	esac

	cmake "$ProjectDir" "${CMakeArgs[@]}"
}

ecwolf_package() {
	#declare -n Config=$1
	shift
	declare ProjectDir=$1
	shift
	declare Version=$1
	shift
	declare -n Artifacts=$1
	shift

	rm -rf ECWolf.app &&
	cp -a x86_64/ecwolf.app ECWolf.app || return

	rm ECWolf.app/Contents/MacOS/ecwolf &&
	lipo \
		-arch arm64 arm64/ecwolf.app/Contents/MacOS/ecwolf \
		-arch i386 i386/ecwolf.app/Contents/MacOS/ecwolf \
		-arch x86_64 x86_64/ecwolf.app/Contents/MacOS/ecwolf \
		-arch ppc ppc/ecwolf.app/Contents/MacOS/ecwolf \
		-create -output ECWolf.app/Contents/MacOS/ecwolf &&

	/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $Version" ECWolf.app/Contents/Info.plist &&
	/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $Version" ECWolf.app/Contents/Info.plist &&

	sign_app ECWolf.app &&
	make_dmg ECWolf "ecwolf-$Version.dmg" ECWolf.app || return

	Artifacts+=("ecwolf-$Version.dmg")
}

# shellcheck disable=SC2034
declare -A ECWolfMac=(
	[branch]='master'
	[build]=cmake_generic_build
	[configure]=ecwolf_configure
	[multiarch]='x86_64 arm64 i386 ppc'
	[outoftree]=1
	[package]=ecwolf_package
	[project]='ECWolf'
	[remote]='ssh://git@bitbucket.org/ecwolf/ecwolf.git'
	[uploaddir]=ecwolf-mac
	[vcs]=GitVCS
)
register_build ECWolfMac
