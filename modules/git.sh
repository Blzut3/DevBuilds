#!/bin/bash

git_check() {
	#declare Remote=$1
	shift
	declare Branch=$1
	shift

	declare OldRev NewRev

	OldRev=$(git_describe) &&
	git fetch origin "$Branch" --recurse-submodules --tags &&
	git reset --hard "origin/$Branch" &&
	NewRev=$(git_describe) || return

	[[ "$OldRev" != "$NewRev" ]]
}

git_clone() {
	declare Remote=$1
	shift
	declare Branch=$1
	shift
	declare Dir=$1
	shift

	git clone --recurse-submodules -b "$Branch" "$Remote" "$Dir"
}

git_describe() {
	git describe --tags --always
}

readonly -A GitVCS=(
	[check]=git_check
	[clone]=git_clone
	[describe]=git_describe
)
