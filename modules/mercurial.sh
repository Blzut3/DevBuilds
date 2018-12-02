#!/bin/bash

mercurial_check() {
	#declare Remote=$1
	shift
	declare Branch=$1
	shift

	declare OldRev NewRev

	OldRev=$(hg log -r. --template '{node}') &&
	hg pull -r "$Branch" &&
	hg up -r "$Branch" --clean &&
	NewRev=$(hg log -r. --template '{node}') || return 0 # Return 0 (no change if something goes wrong)

	[[ "$OldRev" != "$NewRev" ]]
}

mercurial_clone() {
	declare Remote=$1
	shift
	declare Branch=$1
	shift
	declare Dir=$1
	shift

	hg clone -r "$Branch" "$Remote" "$Dir"
}

#mercurial_describe() {
#	hg log -r. --template '{latesttag}-{latesttagdistance}-{node|short}'
#}

mercurial_describe_date() {
	hg log -r. --template '{date(date, "%y%m%d-%H%M")}'
}

readonly -A MercurialVCS=(
	[check]=mercurial_check
	[clone]=mercurial_clone
	[describe]=mercurial_describe_date
)
