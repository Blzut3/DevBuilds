#!/usr/bin/bash
# shellcheck disable=SC1090,SC2155

# Run with git-bash

set -o pipefail

# Removes the parent directory from archives. Probably not Windows specific,
# but this is a good place to put it until the need arises elsewhere.
extract_and_flatten() {
	declare Image=$1
	shift

	declare BaseDir

	find . -maxdepth 1 -mindepth 1 -type d -exec rm -r {} \; &&
	7z x "$Image" &&
	BaseDir=$(find . -maxdepth 1 -mindepth 1 -type d -printf '%P\n' -quit) &&
	mv "$BaseDir"/* . &&
	rmdir "$BaseDir"
}

# Windows ftp doesn't like reading from stdin
ftp() {
	declare ScriptFile
	# Need to specify LOCALAPPDATA/Temp since git-bash won't convert -s:/tmp
	# into Windows path.
	ScriptFile=$(mktemp -p "$LOCALAPPDATA/Temp") || return 1

	cat > "$ScriptFile" &&
	command ftp -s:"$ScriptFile" "$@"
	declare Ret=$?

	rm -f "$ScriptFile"
	return "$Ret"
}

main() {
	# Need to use realpath to convert Windows path (i.e. one explorer gives) to one git-bash can use
	declare ScriptPath=$(realpath "$0")
	cd "${ScriptPath%/*}" || return

	# Load modules and configuration
	. "$LOCALAPPDATA/BuildServer/config.sh"

	declare Module
	for Module in modules/*.sh win/*.sh; do
		. "$Module"
	done

	cd ..
	# shellcheck disable=SC2034
	declare -g BaseWorkingDir=$(pwd)

	# Start building
	parse_args "$@"
	shift $((OPTIND-1))

	run_builds
}

main "$@" || exit
