#!/bin/bash
 
# Create a dir if not exist
projects_dir="$HOME/projects"
mkdir -p "$projects_dir"
 
# Repos
repos=(
    "https://github.com/A00N/SpotPriceWatch"
    "https://github.com/A00N/NumberRecognition"
    "https://github.com/A00N/ot-harjoitustyo"
)
 
# Function to update progress
update_progress() {
    local repo_index=$1
    local status=$2
    local repo_name=$(basename "${repos[$repo_index]}" .git)
    printf "\033[%sH\033[K%-30s %s" $((repo_index + 2)) "$repo_name" "$status"
}
 
# Function to show progress
show_progress() {
    local pid=$1
    local repo_index=$2
    local spin='/-\|'
    local i=0
 
    while kill -0 $pid 2>/dev/null; do
        update_progress $repo_index "${spin:i++%4:1}"
        sleep 0.1
    done
 
    wait $pid
    if [ $? -eq 0 ]; then
        update_progress $repo_index "Done"
    else
        update_progress $repo_index "Failed"
    fi
}
 
# Function to pull or clone the repository
pull_or_clone_repo() {
    local repo_index=$1
    local repo_url="${repos[$repo_index]}"
    local repo_name=$(basename "$repo_url" .git)
    local repo_path="$projects_dir/$repo_name"
 
    if [ -d "$repo_path" ]; then
        update_progress $repo_index "Updating"
        (cd "$repo_path" && git pull origin main > /dev/null 2>&1) &
    else
        update_progress $repo_index "Cloning"
        git clone "$repo_url" "$repo_path" > /dev/null 2>&1 &
    fi
 
    show_progress $! $repo_index
}
 
# Clear screen + print header
clear
echo "Processing repositories:"
 
# Init progress lines
for i in "${!repos[@]}"; do
    update_progress $i "Waiting"
done
 
# Pull or clone in parallel
for i in "${!repos[@]}"; do
    pull_or_clone_repo $i &
done
 
# Wait for all parallel tasks to finish
wait
 
# Move cursor to the bottom and print completion message
echo -e "\n\nAll repositories processed!"
