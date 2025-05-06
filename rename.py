import os
import datetime
import re
import argparse

# Set up argument parser
parser = argparse.ArgumentParser(description='Rename MP4 files with size and date prefix')
parser.add_argument('-m', '--dry-run', action='store_true', help='Dry run mode - only show what would be done')
args = parser.parse_args()

# Assuming the current directory, but you can change 'current_directory' to any directory path
current_directory = '.'

# Regular expression to match the format '{size}_{date}_' at the start of the filename
file_prefix_pattern = re.compile(r'^\d{6}_\d{2}-\d{2}T\d{2}:\d{2}_')

# List all files in the specified directory
for filename in os.listdir(current_directory):
    file_path = os.path.join(current_directory, filename)
    
    # Check if it is a file with .mp4 suffix
    if os.path.isfile(file_path) and filename.endswith('.mp4'):
        # Check if the filename already has our prefix format
        if file_prefix_pattern.match(filename):
            print(f"Skipping '{filename}' as it already has the required prefix format.")
            continue

        # Get the creation time of the file
        stat = os.stat(file_path)
        try:
            creation_time = stat.st_birthtime
        except AttributeError:
            # We're probably on Linux. No easy way to get creation dates here,
            # so we'll use the last modification time instead.
            creation_time = stat.st_mtime

        # Get file size in MiB and format it to 6 digits with leading zeros
        file_size_mib = os.path.getsize(file_path) / (1024 * 1024)  # Convert bytes to MiB
        size_str = f"{int(file_size_mib):05d}"

        # Convert the creation time to the desired format 'MM-DDTHH:MM'
        date_str = datetime.datetime.fromtimestamp(creation_time).strftime('%m-%dT%H%M')
        
        # Create the new filename with size and date prefix
        new_filename = f"{size_str}_{date_str}_{filename}"
        new_file_path = os.path.join(current_directory, new_filename)
        
        if args.dry_run:
            print(f"{filename} -> {new_filename}")
        else:
            os.rename(file_path, new_file_path)
