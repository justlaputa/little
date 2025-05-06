import os
import datetime
import re

# Assuming the current directory, but you can change 'current_directory' to any directory path
current_directory = '.'

# Regular expression to match the date format 'MM-DDTHH:MM' at the start of the filename
date_prefix_pattern = re.compile(r'^\d{2}-\d{2}T\d{2}:\d{2}_')

# List all files in the specified directory
for filename in os.listdir(current_directory):
    file_path = os.path.join(current_directory, filename)
    
    # Check if it is a file with .mp4 suffix
    if os.path.isfile(file_path) and filename.endswith('.mp4'):
        # Check if the filename already has a date prefix
        if date_prefix_pattern.match(filename):
            print(f"Skipping '{filename}' as it already has a date prefix.")
            continue
       
        # Get the creation time of the file
        stat = os.stat(file_path)
        try:
            creation_time = stat.st_birthtime
        except AttributeError:
            # We're probably on Linux. No easy way to get creation dates here,
            # so we'll use the last modification time instead.
            creation_time = stat.st_mtime
        
        # Convert the creation time to the desired format 'MM-DDTHH:MM'
        date_str = datetime.datetime.fromtimestamp(creation_time).strftime('%m-%dT%H%M')
        
        # Create the new filename by adding the date string as a prefix
        new_filename = f"{date_str}_{filename}"
        
        # Rename the file
        os.rename(file_path, os.path.join(current_directory, new_filename))
        
        print(f"File '{filename}' has been renamed to '{new_filename}'")
