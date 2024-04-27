# shellcheck disable=SC2154

function ssh_agent_init() {
    eval "$(ssh-agent -s)"
    while read -r -d '' file; do
        if grep -q "PRIVATE KEY" "$file"; then
            ssh-add "$file"
        fi
    done < <(find "$default_ssh_dir" -type f \! -name "*.pub" \! -name "known_hosts*" -print0)
}

function fssh() {
    local hostname
    for arg in "$@"; do
        if [[ "$arg" == *@* ]]; then
            # Extract the hostname part after @
            hostname="${arg#*@}"
            break
        fi
    done

    # If a hostname was found, remove it from known_hosts
    if [[ -n "$hostname" ]]; then
        echo "Removing $hostname from known_hosts..."
        ssh-keygen -R "$hostname"
    else
        echo "Hostname not found in arguments. Proceeding without modifying known_hosts."
    fi

    # Execute ssh with the original arguments
    ssh "$@"
}
