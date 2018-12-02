#!/bin/bash

git_check() {
	#declare Remote=$1
	shift
	declare Branch=$1
	shift

	declare OldRev NewRev

	OldRev=$(git describe --tags) &&
	git pull origin "$Branch" &&
	NewRev=$(git describe --tags) || return

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
	git describe --tags
}

readonly -A GitVCS=(
	[check]=git_check
	[clone]=git_clone
	[describe]=git_describe
)
