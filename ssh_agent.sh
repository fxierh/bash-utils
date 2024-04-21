source ssh_agent_cfgs

eval "$(ssh-agent -s)"

# shellcheck disable=SC2154
while read -r -d '' file; do
    if grep -q "PRIVATE KEY" "$file"; then
        ssh-add "$file"
    fi
done < <(find "$default_ssh_dir" -type f \! -name "*.pub" \! -name "known_hosts*" -print0)
