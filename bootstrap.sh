# Entry point for the bash-utils library. Idempotent.
#
# For login shells: source this script in your .bash_profile
# For non-login shells: source this script at the start of your scripts
#
# shellcheck disable=SC2163
# shellcheck source=/dev/null

# Check if the script has already been sourced
if [[ -n "$_BASH_UTILS_SOURCED" ]]; then
    echo "The bootstrapping script has already been sourced, doing nothing. "
    return 0
fi

# Get project directory
project_dir="$(dirname "${BASH_SOURCE[0]}")"
if [[ ! -d "$project_dir" ]]; then
    echo "Error: Unable to locate the project directory $project_dir." >&2
    return 1
fi

# Apply the configurations
source "$project_dir/configurations"

# Source all other utility scripts
while IFS= read -r -d '' file; do
    source "$file"
done < <(find "$project_dir" ! -path "*/hack/*" -name '*.sh' ! -name 'bootstrap.sh' -print0)

# Export all utilities
while read -r funcname; do
    export -f "$funcname"
done < <("$project_dir/hack/list-utils.sh" -a "$project_dir")

# Make the custom man pages discoverable
export PATH="$PATH:$project_dir"

# Mark the script as sourced
export _BASH_UTILS_SOURCED=1
