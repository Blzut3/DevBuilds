#!/bin/bash
# shellcheck disable=SC2155,SC2154

# Gets the build directory for a config (for looking up deps)
lookup_build_dir() {
	declare ProjectName=$1
	shift
	declare Arch=$1
	shift

	declare ConfigVar
	if [[ ${DepConfigs[$ProjectName]} ]]; then
		ConfigVar=${DepConfigs[$ProjectName]}
	elif [[ ${BuildConfigs[$ProjectName]} ]]; then
		ConfigVar=${BuildConfigs[$ProjectName]}
	else
		return 1
	fi

	declare -n Config=$ConfigVar
	if (( Config[outoftree] )); then
		if [[ $Arch ]]; then
			echo "$BaseWorkingDir/Builds/${Config[project]}/$Arch"
		else
			echo "$BaseWorkingDir/Builds/${Config[project]}"
		fi
	else
		echo "$BaseWorkingDir/${Config[project]}"
	fi
	return 0
}

run_build() {
	declare ConfigVar=$1
	shift

	declare -n Config=$ConfigVar
	declare -n VCS=${Config[vcs]}

	declare ProjectDir="$BaseWorkingDir/${Config[project]}"

	declare FreshClone=0
	if [[ ! -d "$ProjectDir" ]]; then
		if ! call "${VCS[clone]}" "${Config[remote]}" "${Config[branch]}" "${Config[project]}"; then
			printf 'ERROR: Failed to create project directory for "%s"!\n' "${Config[project]}" >&2
			return 1
		fi

		FreshClone=1
	fi

	(
		cd "$ProjectDir" || return

		if (( !ForceBuild && !FreshClone )) && ! call "${VCS[check]}" "${Config[remote]}" "${Config[branch]}"; then
			printf '%s: No change. Skipping.\n' "${Config[project]}"
			return 0
		fi

		declare Version
		if ! Version=$("${VCS[describe]}"); then
			printf '%s: Failed to describe version.\n' "${Config[project]}" >&2
			return 1
		fi
		printf '%s: Building %s...\n' "${Config[project]}" "$Version"

		# shellcheck disable=SC2206
		declare -a MultiArch=(${Config[multiarch]})
		if (( ${#MultiArch[@]} == 0 )); then
			MultiArch=("$(uname -m)")
		fi
		declare Arch
		declare Ret
		for Arch in "${MultiArch[@]}"; do
			if (( Config[outoftree] )); then
				cd "$BaseWorkingDir" || continue
				mkdir -p "Builds/${Config[project]}/$Arch"
				cd "Builds/${Config[project]}/$Arch" || continue
			fi

			if ! call "${Config[configure]}" "$ConfigVar" "$ProjectDir" "$Arch" 2>&1 | tee build.log; then
				printf '%s,%s: Failed to configure build.\n' "${Config[project]}" "$Arch" >&2
				Ret=1
				continue
			fi

			if ! call "${Config[build]}" "$ConfigVar" "$ProjectDir" "$Arch" 2>&1 | tee -a build.log; then
				printf '%s,%s: Failed to build.\n' "${Config[project]}" "$Arch" >&2
				Ret=1
				continue
			fi
		done

		if (( Config[outoftree] )); then
			cd "$BaseWorkingDir/Builds/${Config[project]}" || return
		fi

		# If any builds failed, do not package
		declare -a ArtifactsOut
		if (( Ret == 0 )); then
			if ! call "${Config[package]}" "$ConfigVar" "$ProjectDir" "$Version" ArtifactsOut; then
				printf '%s: Failed to package.\n' "${Config[project]}" >&2
				Ret=1
			fi
		fi

		if (( Config[outoftree] )); then
			cat ./*/build.log | xz -9 > "${Config[project],,}-$Version.log.xz"
		else
			< build.log xz -9 > "${Config[project],,}-$Version.log.xz"
		fi
		ArtifactsOut+=("${Config[project],,}-$Version.log.xz")

		if [[ ${Config[uploaddir]} ]]; then
			# Upload in reverse order so timestamps work out for reverse chronological
			reverse_array ArtifactsOut
			scp -i "$SSHIdentity" "${ArtifactsOut[@]}" "$SSHUsername@$SSHServer:$SSHBaseDirectory/${Config[uploaddir]}/"
		fi

		rm -rf "${ArtifactsOut[@]}"
	)
}

run_builds() {
	declare ConfigVar Ret=0
	for ConfigVar in "${DepConfigs[@]}" "${BuildConfigs[@]}"; do
		declare -n Config=$ConfigVar
		if [[ $BuildSelection && $BuildSelection != "${Config[project]}" ]]; then
			continue
		fi

		run_build "${ConfigVar}" || Ret=$?
	done
	return "$Ret"
}
