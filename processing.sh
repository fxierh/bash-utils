function flat() {
    local input
    local normalize
    local result
    local save_to_clipboard

    # Parse options
    local opt
    local OPTIND
    while getopts "ns" opt; do
        case $opt in
        n)
            normalize="true"
            ;;
        s)
            save_to_clipboard="true"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Get input
    input="$(_get_input -n "$@")"

    # Set the record separator to one or more empty lines surrounded by other whitespace,
    # effectively treating paragraphs or separated blocks as single records.
    result="$(awk -v RS='([[:blank:]]*\n){2,}[[:blank:]]*' '$1=$1' <<< "$input")" || return 1

    # Normalize line breaks if requested
    if [[ "$normalize" = "true" ]]; then
        result="${result//- /}"
    fi

    # Save to clipboard if requested
    if [[ "$save_to_clipboard" == "true" ]]; then
        save2clipboard "$result"
    fi

    # Print out result
    echo "$result"
}
