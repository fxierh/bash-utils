# Entrypoint of the entire library.
# To be sourced by absolute path within .bash_profile.
# shellcheck source=/dev/null

# Get project directory
project_dir="$(dirname "${BASH_SOURCE[0]}")"

# Apply the configurations
source "$project_dir/configurations"

# Source all other utility scripts
while IFS= read -r -d '' file; do
    source "$file"
done < <(find "$project_dir" -depth 1 -name '*.sh' ! -name 'bootstrap.sh' -print0)

# Make the custom man pages discoverable
export PATH="$project_dir:$PATH"
