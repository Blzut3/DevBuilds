#!/bin/bash
# shellcheck disable=SC2155

qzdoom_package() {
	gzdoom_package_generic qzdoom "$@"
}

# shellcheck disable=SC2034
declare -A QZDoomWin=(
	[branch]='qz-master-2022-05-10'
	[build]=cmake_generic_build
	[configure]=gzdoom_configure
	[multiarch]='x64'
	[outoftree]=1
	[package]=qzdoom_package
	[project]='QZDoom'
	[remote]='https://github.com/ZDoom/qzdoom.git'
	[uploaddir]=qzdoom
	[vcs]=GitVCS
)
register_build QZDoomWin
