#!/bin/bash

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
    movie_details=$(curl -s "http://www.omdbapi.com/?apikey=<your_api_key>&t=$encoded_movie_name" | sed -n 's/.*"Year":"\([^"]*\)".*/\1/p')
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
