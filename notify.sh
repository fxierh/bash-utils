# shellcheck disable=SC2034

function beep() {
    echo -ne "\a"
}

function notify() {
    local num_notifications=3

    # Parse options
    local OPTIND
    while getopts "n:" opt; do
        case $opt in
        n)
            num_notifications=$OPTARG
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Execute the command
    "$@"
    local exit_status=$?

    # Make a number of noises
    for i in $(seq 1 "$num_notifications"); do
        beep
    done

    # Return the status of the command
    return $exit_status
}
