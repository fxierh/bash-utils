# shellcheck disable=SC2154
function ssh_agent_init() {
    eval "$(ssh-agent -s)"
    while read -r -d '' file; do
        if grep -q "PRIVATE KEY" "$file"; then
            ssh-add "$file"
        fi
    done < <(find "$default_ssh_dir" -type f \! -name "*.pub" \! -name "known_hosts*" -print0)
}
