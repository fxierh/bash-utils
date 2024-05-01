#!/usr/bin/env bash

set -euo pipefail

function extract_function_names_from_file() {
    awk '
    /^[[:blank:]]*function[[:blank:]]+/ { sub(/\(\)/, "", $2); print $2 }
    /^[[:blank:]]*[a-zA-Z0-9_]+\(\)+/ { sub(/\(\)/, "", $1); print $1 }
    ' "$1"
}

function filter_internal_functions() {
    grep -v '^_'
}

function get_function_names() {
    while read -r -d '' file; do \
        extract_function_names_from_file "$file" | filter_internal_functions || :
    done < <(find "$1" -depth 1 -name '*.sh' -print0)
}

get_function_names "$1"
