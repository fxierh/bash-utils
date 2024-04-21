function flat() {
    commands=':a
N
$!ba
s/[[:space:]]+/ /g'

    if (( "$#" == 1 )); then
        echo -e "$1" | sed -E "$commands"
    else
        sed -E "$commands"
    fi
}
