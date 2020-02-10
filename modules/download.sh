#!/bin/bash

download_check() {
	declare Remote=$1
	shift
	declare Branch=$1
	shift

	if [[ ! -f "${Remote##*/}" ]]; then
		download_clone "$Remote" "$Branch" "$(pwd)"
		return 0
	fi
	return 1
}

download_clone() {
	declare Remote=$1
	shift
	#declare Branch=$1
	shift
	declare Dir=$1
	shift

	mkdir -p "$Dir"
	cd "$Dir" &&
	curl -LfgO "$Remote"
}


download_describe() {
	echo 'unversioned'
}

readonly -A DownloadVCS=(
	[check]=download_check
	[clone]=download_clone
	[describe]=download_describe
)
