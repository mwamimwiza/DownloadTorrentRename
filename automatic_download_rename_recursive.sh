#!/bin/bash

# Define the directory where you want to download the files
download_dir="/home/kagabo/downloads"

# Create the download directory if it doesn't exist
mkdir -p "$download_dir"

# List all torrent files in the /home/kagabo/torrents directory
torrent_dir="/home/kagabo/torrents"

# Function to download a torrent and show progress
download_torrent() {
  local torrent_file="$1"
  echo "Downloading: $torrent_file"
  aria2c -d "$download_dir" --seed-time=0 "$torrent_file"
  echo "Download completed: $torrent_file"
}

# Function to rename files inside subdirectories (including second-level subdirectories)
rename_subdirectory_files() {
  local dir="$1"
  for subdirectory in "$dir"/*; do
    if [ -d "$subdirectory" ]; then
      # First, rename files within the current subdirectory
      for video_file in "$subdirectory"/*; do
        if [[ $video_file =~ .*[sS]([0-9]{2})[eE]([0-9]{2}).*\.(.*) ]]; then
          season="${BASH_REMATCH[1]}"
          episode="${BASH_REMATCH[2]}"
          extension="${BASH_REMATCH[3]}"
          new_name="S${season}E${episode}.$extension"
          mv "$video_file" "$subdirectory/$new_name"
        fi
      done
      # Then, recursively call the function to handle subdirectories within this subdirectory
      rename_subdirectory_files "$subdirectory"
    fi
  done
}

# Download torrents one by one, show progress, and then rename files inside subdirectories
for torrent_file in "$torrent_dir"/*.torrent; do
  if [ -e "$torrent_file" ]; then
    download_torrent "$torrent_file"
    rename_subdirectory_files "$download_dir"
  fi
done
