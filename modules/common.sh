#!/bin/bash

# Call a function (or really any command) while preserving the working directory.
call() {
	pushd . &>/dev/null || return
	"$@"
	declare Ret=$?
	popd &>/dev/null || return

	return "$Ret"
}

declare -g ForceBuild=0
declare -g BuildSelection
parse_args() {
	declare Opt
	while getopts ':fp:' Opt; do
		case "$Opt" in
		f)
			# shellcheck disable=SC2034
			ForceBuild=1
			;;
		p)
			# shellcheck disable=SC2034
			BuildSelection=$OPTARG
			;;
		*)
			;;
		esac
	done
}

declare -gA BuildConfigs
register_build() {
	declare ConfigVar=$1
	shift

	declare -n Config=$ConfigVar

	# shellcheck disable=SC2034
	BuildConfigs[${Config[project]}]=$ConfigVar
}

declare -gA DepConfigs
register_dep() {
	declare ConfigVar=$1
	shift

	declare -n Config=$ConfigVar

	# shellcheck disable=SC2034
	DepConfigs[${Config[project]}]=$ConfigVar
}
