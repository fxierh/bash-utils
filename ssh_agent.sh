# shellcheck disable=SC2154
function ssh_agent_init() {
    eval "$(ssh-agent -s)"
    while read -r -d '' file; do
        if grep -q "PRIVATE KEY" "$file"; then
            ssh-add "$file"
        fi
    done < <(find "$default_ssh_dir" -type f \! -name "*.pub" \! -name "known_hosts*" -print0)
}


function fssh()
{

# Story:Beaker physical machine alway have same hostname even it got OS re-installed.
#       When you ssh the sanme machine with another os, it will said: different  fingerprint.
#       This function is to remote the fingerprint in the ~/.ssh/know_hosts.
#
# Useage: fssh root@<remote_host_name>

    remote_hostname=$(echo $1 | awk -F "@" '{print $2}')
    if (grep "$remote_hostname" ~/.ssh/known_hosts); then
        sed -i "/^$remote_hostname/d" ~/.ssh/known_hosts
    fi

    ssh $1

}
