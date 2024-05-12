# shellcheck disable=SC2034

function _beep() {
    echo -ne "\a"
}

function notify() {
    local broadcast=""
    local broadcast_msg=""
    local num_beeps=3

    # Parse options
    local opt=""
    local OPTIND=""
    while getopts "b:w:" opt; do
        case $opt in
        b)
            num_beeps="$OPTARG"
            ;;
        w)
            broadcast="true"
            broadcast_msg="$OPTARG"
            ;;
        \?)
            return 1
            ;;
        esac
    done
    shift $((OPTIND - 1))

    # Check if any command is provided
    if (( "$#" == 0 )); then
        _err "No command provided, exiting"
        return 1
    fi

    # Execute the command
    "$@"
    local exit_status=$?

    # Broad if requested
    if [[ "$broadcast" == "true" ]]; then
        wall <<< "${broadcast_msg:-"Command '$*' terminated with exit status $exit_status"}"
    fi

    # Make a number of beeps
    for i in $(seq 1 "$num_beeps"); do
        _beep
    done

    # Return the status of the command
    return $exit_status
}