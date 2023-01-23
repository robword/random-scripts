#!/bin/bash

#
#
# This script is designed to rename the files in the current directory by adding the release year of the movie to the file name.
# It does this by making an API call to the Open Movie Database (OMDb) API to retrieve movie details based on the file name (without the file extension).
# The script loops through all files in the current directory, ignores the script file itself, and for each file, it performs the following steps:
# 1. Extract the movie name by removing the file extension.
# 2. Check if the file name already contains the year by using a regular expression, if the pattern is found, the script will print a message that the file already has the year in the name and will continue to the next file.
# 3. Replace spaces with %20 in the movie name, this is necessary for the API call.
# 4. Make an API call to the OMDb API to retrieve the movie details based on the movie name, the API key is passed to the API call via a variable.
# 5. Extract the release year from the movie details using sed command.
# 6. Rename the file by adding the release year in the format `(yyyy)` to the movie name and the file extension.
# It is important to note that the script requires an API key from OMDb API to work, and that the key should be defined as a variable at the top of the script.
# Also, the script might fail if the movie name is not found in the OMDb database, in that case, the script will print an error message and continue to the next file.
#
#
#


# Define the API key
api_key=<your_api_key>

# Get the name of the script file
script_file="$(basename -- "$0")"

# Loop through all files in the current directory
for file in *; do
    # Skip the script file
    if [ "$file" == "$script_file" ]; then
        continue
    fi
    # Get the movie name by removing the file extension
    movie_name="${file%.*}"
    # check if the file name already contains the year
    if [[ $movie_name =~ \([0-9]{4}\)$ ]]; then
        echo "File $file already has the year in the name, skipping"
        continue
    fi
    # Replace spaces with %20
    encoded_movie_name="${movie_name// /%20}"
    # Search the movie on IMDb
    movie_details=$(curl -s "http://www.omdbapi.com/?apikey=$api_key&t=$encoded_movie_name" | sed -n 's/.*"Year":"\([^"]*\)".*/\1/p')
    if [ $? -ne 0 ]; then
        echo "Error: Failed to retrieve movie details for $movie_name"
        continue
    fi
    if [ -z "$movie_details" ] || [ "$movie_details" == "N/A" ]; then
        echo "Error: Failed to extract release year for $movie_name"
        continue
    fi
    # Rename the file to include the release year, use double quotes to handle spaces in filename
    mv "$file" "${movie_name} (${movie_details}).${file##*.}"
done
