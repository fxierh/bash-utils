# shellcheck disable=SC2154
if [[ "$enabled_ssh_agent" != true ]]; then
    return 0
fi

eval "$(ssh-agent -s)"
while read -r -d '' file; do
    if grep -q "PRIVATE KEY" "$file"; then
        ssh-add "$file"
    fi
done < <(find "$default_ssh_dir" -type f \! -name "*.pub" \! -name "known_hosts*" -print0)
