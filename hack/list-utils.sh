#!/usr/bin/env bash

set -euo pipefail

function usage() {
    echo "Usage: ${0##*/} [-a] [-f] directory

Options:
-a: include internal functions (those starting with an underscore)
-f: print the filename before listing its functions"
}

function extract_function_names_from_file() {
    awk '
    /^[[:blank:]]*function[[:blank:]]+/ { sub(/\(\)/, "", $2); print $2 }
    /^[[:blank:]]*[a-zA-Z0-9_]+\(\)+/ { sub(/\(\)/, "", $1); print $1 }
    ' "$1"
}

function filter_internal_functions() {
    grep -v '^_' <<< "$1"
}

function get_function_names() {
    local directory="$1"
    local file
    local functions_names

    while read -r -d '' file; do
        # Print file name if requested
        if [[ "$print_file_names" == true ]]; then
            echo ">>>>> $(basename "$file")"
        fi

        # Get function names
        functions_names="$(extract_function_names_from_file "$file")"
        # Filter out internal functions unless requested otherwise
        if [[ "$include_internal_functions" != true ]]; then
            functions_names=$(filter_internal_functions "$functions_names")
        fi

        # Print function names
        if [[ -n "$functions_names" ]]; then
            echo "$functions_names"
        fi
    done < <(find "$directory" -depth 1 -name '*.sh' -print0)
}

# Default values
include_internal_functions=false
print_file_names=false

# Parse options
while getopts "af" opt; do
    case $opt in
    a)
        include_internal_functions=true
        ;;
    f)
        print_file_names=true
        ;;
    \?)
        usage
        exit 1
        ;;
    esac
done
shift $((OPTIND - 1))

# Main
get_function_names "$1"
