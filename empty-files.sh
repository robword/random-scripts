#!/bin/bash

# This script takes the contents of a file and creates empty files for each entry.
# The user can pass the path to the input file as a command-line argument,
# or the script will prompt the user to enter the path to the input file.
# The script will read each line as a file name and create an empty file with that name.

file=$1

# If the file path is not provided as an argument, prompt the user for the input file
if [ -z "$file" ]
then
    echo "Enter the path to the input file:"
    read file
fi

# Read each line of the file and create an empty file with the same name
while read line; do
  touch "$line"
done < $file
