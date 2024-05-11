function secenv() {
    # Set a secure path
    PATH='/usr/local/bin:/bin:/usr/bin'
    \export PATH

    # Clear all aliases
    \unalias -a

    # Clear the command path hash
    hash -r

    # Turn off core dumps
    ulimit -H -c 0 --

    # Set a secure IFS
    IFS=$' \t\n'

    # Set a secure umask variable. Result in 755 for directories and 644 for files
    umask 022
}
