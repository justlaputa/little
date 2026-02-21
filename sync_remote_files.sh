#!/bin/bash

# Script to continuously sync files and folders from remote server using rclone
# Downloads items sorted by size (smallest to largest)

set -e

# Parse arguments
DELETE_AFTER_DOWNLOAD=true
REMOTE_DIR=""
TARGET_PATH="."

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-delete)
            DELETE_AFTER_DOWNLOAD=false
            shift
            ;;
        *)
            if [ -z "$REMOTE_DIR" ]; then
                REMOTE_DIR="$1"
            elif [ -z "$TARGET_PATH" ] || [ "$TARGET_PATH" = "." ]; then
                TARGET_PATH="$1"
            fi
            shift
            ;;
    esac
done

# Check if remote directory argument is provided
if [ -z "$REMOTE_DIR" ]; then
    echo "Usage: $0 [--no-delete] <remote-directory> [target-path]"
    echo "Example: $0 myremote:/path/to/folder"
    echo "Example: $0 --no-delete myremote:/path/to/folder"
    echo "Example: $0 myremote:/path/to/folder /path/to/local/folder"
    echo "Example: $0 --no-delete myremote:/path/to/folder ./downloads"
    exit 1
fi

# Create target directory if it doesn't exist
if [ ! -d "$TARGET_PATH" ]; then
    echo "Target directory does not exist. Creating: $TARGET_PATH"
    mkdir -p "$TARGET_PATH"
fi

# Convert to absolute path for clarity
TARGET_PATH=$(cd "$TARGET_PATH" && pwd)

echo "Starting continuous sync from: $REMOTE_DIR"
echo "Items will be downloaded to: $TARGET_PATH"
echo "Delete after download: $DELETE_AFTER_DOWNLOAD"
echo "Press Ctrl+C to stop"
echo ""

# Function to format size in human readable format
format_size() {
    local size=$1
    if [ "$size" -lt 1024 ]; then
        echo "${size}B"
    elif [ "$size" -lt 1048576 ]; then
        awk "BEGIN {printf \"%.2fKB\", $size/1024}"
    elif [ "$size" -lt 1073741824 ]; then
        awk "BEGIN {printf \"%.2fMB\", $size/1048576}"
    else
        awk "BEGIN {printf \"%.2fGB\", $size/1073741824}"
    fi
}

# Infinite loop to continuously check for new files and folders
while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Checking for files and folders..."

    # Use temporary files to store the lists
    TEMP_FILES=$(mktemp)
    TEMP_FOLDERS=$(mktemp)
    TEMP_COMBINED=$(mktemp)

    # List files only (not directories) with size
    # --files-only: skip directories
    # --format "sp": output size;path (semicolon separated)
    rclone lsf "$REMOTE_DIR" --files-only --format "sp" > "$TEMP_FILES" 2>/dev/null || true

    # List folders only (not files)
    # --dirs-only: skip files
    rclone lsf "$REMOTE_DIR" --dirs-only > "$TEMP_FOLDERS" 2>/dev/null || true

    # Process files - add to combined list with type marker
    if [ -s "$TEMP_FILES" ]; then
        while IFS=';' read -r fsize fname; do
            echo "${fsize};file;${fname}" >> "$TEMP_COMBINED"
        done < "$TEMP_FILES"
    fi

    # Process folders - calculate total size for each folder
    if [ -s "$TEMP_FOLDERS" ]; then
        while read -r folder; do
            echo "  [CALC] Calculating size of folder: $folder"
            # Get total size of folder using rclone size
            folder_size=$(rclone size "$REMOTE_DIR/$folder" --json 2>/dev/null | grep -o '"bytes":[0-9]*' | cut -d':' -f2)

            if [ -n "$folder_size" ] && [ "$folder_size" -gt 0 ]; then
                echo "${folder_size};folder;${folder}" >> "$TEMP_COMBINED"
            else
                # Empty folder or error, treat as 0 bytes
                echo "0;folder;${folder}" >> "$TEMP_COMBINED"
            fi
        done < "$TEMP_FOLDERS"
    fi

    if [ ! -s "$TEMP_COMBINED" ]; then
        echo "No files or folders found. Waiting 30 seconds before rechecking..."
        rm "$TEMP_FILES" "$TEMP_FOLDERS" "$TEMP_COMBINED"
        sleep 30
        continue
    fi

    # Display all items sorted by size
    echo ""
    echo "Items in remote folder (sorted by size):"
    echo "----------------------------------------"
    sort -n -t';' -k1 "$TEMP_COMBINED" | while IFS=';' read -r item_size item_type item_name; do
        formatted_size=$(format_size "$item_size")
        printf "  %10s - [%s] %s\n" "$formatted_size" "$(echo $item_type | tr '[:lower:]' '[:upper:]')" "$item_name"
    done
    echo "----------------------------------------"
    echo ""

    # Sort items by size and process them one by one until we find one to download
    item_found=false
    while IFS=';' read -r size item_type item_name; do
        if [ -z "$item_name" ]; then
            continue
        fi

        # Remove trailing slash from folder name for checking
        check_name="${item_name%/}"

        # Check if item already exists locally
        if [ -e "$TARGET_PATH/$check_name" ]; then
            formatted_size=$(format_size "$size")
            echo "  [SKIP] [$item_type] $item_name ($formatted_size) - already exists locally"
            continue
        fi

        # Found an item that doesn't exist locally, download it
        item_found=true
        formatted_size=$(format_size "$size")
        echo "  [DOWN] [$item_type] $item_name ($formatted_size)"

        # Download based on type
        if [ "$item_type" = "file" ]; then
            # Download the file using 10 threads
            if rclone copyto "$REMOTE_DIR/$item_name" "$TARGET_PATH/$item_name" --progress --multi-thread-streams=10; then
                echo "  [OK] File $item_name downloaded successfully"

                # Delete the remote file after successful download
                if [ "$DELETE_AFTER_DOWNLOAD" = true ]; then
                    if rclone deletefile "$REMOTE_DIR/$item_name"; then
                        echo "  [DEL] File $item_name deleted from remote"
                    else
                        echo "  [WARN] Failed to delete $item_name from remote"
                    fi
                fi
            else
                echo "  [FAIL] Failed to download file $item_name"
                echo "Waiting 30 seconds before retry..."
                sleep 30
            fi
        elif [ "$item_type" = "folder" ]; then
            # Remove trailing slash from folder name if present
            item_name="${item_name%/}"

            # Download the entire folder using 10 threads
            if rclone copy "$REMOTE_DIR/$item_name" "$TARGET_PATH/$item_name" --progress --multi-thread-streams=10; then
                echo "  [OK] Folder $item_name downloaded successfully"

                # Delete the remote folder after successful download
                if [ "$DELETE_AFTER_DOWNLOAD" = true ]; then
                    if rclone purge "$REMOTE_DIR/$item_name"; then
                        echo "  [DEL] Folder $item_name deleted from remote"
                    else
                        echo "  [WARN] Failed to delete folder $item_name from remote"
                    fi
                fi
            else
                echo "  [FAIL] Failed to download folder $item_name"
                echo "Waiting 30 seconds before retry..."
                sleep 30
            fi
        fi

        # Break after processing one item
        break
    done < <(sort -n -t';' -k1 "$TEMP_COMBINED")

    # Clean up temp files
    rm "$TEMP_FILES" "$TEMP_FOLDERS" "$TEMP_COMBINED"

    if [ "$item_found" = false ]; then
        echo "All remote items already exist locally. Waiting 10 mins before rechecking..."
        sleep 600
        continue
    fi

    echo ""
done
