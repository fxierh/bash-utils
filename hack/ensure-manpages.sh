#!/usr/bin/env bash

# shellcheck disable=SC2034

set -euo pipefail

function usage() {
    echo "Usage: ${0##*/} project-root-directory"
}

# Read commands from list-utils.sh into an indexed array
function get_cmds() {
    readarray -t cmds <<< "$("${project_root_dir}/hack/list-utils.sh" "${project_root_dir}")"
}

# Populate associative array with commands that have a manpage
function get_cmds_with_manpage() {
    local cmd
    local file
    while IFS= read -r -d '' file; do
        # Extract the command name by removing directory path and any numeric suffix
        cmd="$(basename "$file" | sed 's/\.[0-9]$//')"

        # Add the command name to the associative array with a dummy value
        cmds_with_manpage["$cmd"]=1
    done < <(find "${project_root_dir}/man" -mindepth 2 -name '*.[0-9]' -type f -print0)
}

# Determine which commands lack a manpage
function get_cmds_without_manpage() {
    local cmd
    for cmd in "${cmds[@]}"; do
        if [[ ! -v cmds_with_manpage["$cmd"] ]]; then
            cmds_without_manpage+=("$cmd")
        fi
    done
}

# Main
project_root_dir="$1"
if [[ -z "$project_root_dir" ]]; then
    echo "Error: No project root directory provided." >&2
    usage
    exit 1
fi

declare -a cmds
declare -a cmds_wihout_manpage
declare -A cmds_with_manpage

get_cmds
get_cmds_with_manpage
get_cmds_without_manpage

if (( ${#cmds_without_manpage[@]} > 0 )); then
    echo "The following (external) commands does not have a man page: ${cmds_without_manpage[*]}" >&2
    exit 1
fi
