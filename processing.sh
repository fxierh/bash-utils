function flat() {
    local input

    # Get input
    if (( "$#" == 1 )); then
        input="$1"
    else
        input="$(cat)"
    fi

    # Set the record separator to one or more empty lines surrounded by other whitespace,
    # effectively treating paragraphs or separated blocks as single records.
    awk -v RS='([[:blank:]]*\n){2,}[[:blank:]]*' '$1=$1' <<< "$input"
}
