function placeholder() {
    local placeholders=(foo bar baz qux quux corge grault garply waldo fred plugh xyzzy thud)
    local index=$(( ${1:-0} % ${#placeholders[@]} ))
    echo "${placeholders[$index]}"
}
