#!/bin/bash
# shellcheck disable=SC2155

uzdoom_package() {
	gzdoom_package_generic uzdoom "$@"
}

# shellcheck disable=SC2034
declare -A UZDoomWin=(
	[branch]='trunk'
	[build]=cmake_generic_build
	[configure]=gzdoom_configure
	[multiarch]='x64'
	[outoftree]=1
	[package]=uzdoom_package
	[project]='UZDoom'
	[remote]='https://github.com/UZDoom/uzdoom.git'
	[uploaddir]=uzdoom
	[vcs]=GitVCS
)
register_build UZDoomWin
