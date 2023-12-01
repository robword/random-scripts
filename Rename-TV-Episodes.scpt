(*
Rename TV Episodes Automator Quick Action:
This script, designed as an Automator Quick Action, renames TV show files from 
"Season X Episode Y" to "SXXEYY" format and removes specified text from filenames.
-----------------------------------------
Script Configuration:
- Text Removal: Edit 'textToRemoveFromStart' and 'textToRemoveFromEnd' at the 
  start of the script to specify text to be removed from filenames.

- In Automator, choose "Quick Action" as document type, add "Run AppleScript" action.
  Paste this script, set "Workflow receives current files or folders in Finder" and save.

Usage:
- In Finder: Select files, right-click, choose "Quick Actions" > "Rename TV Episodes".
*)

on run {input, parameters}
    set textToRemoveFromStart to "TextFromStart" -- Replace with the text to remove from the start
    set textToRemoveFromEnd to "TextFromEnd" -- Replace with the text to remove from the end

    tell application "Finder"
        repeat with aFile in input
            try
                set fileName to name of aFile
                set fileExtension to name extension of aFile

                -- Extract the base name without extension
                set baseName to text 1 thru ((length of fileName) - (length of fileExtension) - 1) of fileName

                -- Remove specified text from start and end
                if baseName starts with textToRemoveFromStart then
                    set baseName to text ((length of textToRemoveFromStart) + 1) thru (length of baseName) of baseName
                end if
                if baseName ends with textToRemoveFromEnd then
                    set baseName to text 1 thru ((length of baseName) - (length of textToRemoveFromEnd)) of baseName
                end if

                -- Check for 'Season X Episode Y' pattern
                if baseName contains "Season " and baseName contains " Episode " then
                    set AppleScript's text item delimiters to "Season "
                    set parts to text items of baseName
                    set prePart to text item 1 of parts
                    set remainingPart to text item 2 of parts

                    set AppleScript's text item delimiters to " Episode "
                    set seasonEpisodeParts to text items of remainingPart
                    set seasonNumber to text item 1 of seasonEpisodeParts
                    set postPart to text item 2 of seasonEpisodeParts

                    -- Extract episode number and post-episode text
                    set AppleScript's text item delimiters to " "
                    set postParts to text items of postPart
                    if (count of postParts) ≥ 1 then
                        set episodeNumber to text item 1 of postParts
                        if (count of postParts) > 1 then
                            set postEpisodeText to text items 2 thru end of postParts
                            set postEpisodeText to postEpisodeText as text
                        else
                            set postEpisodeText to ""
                        end if
                    else
                        set episodeNumber to ""
                        set postEpisodeText to ""
                    end if

                    -- Padding single digit season and episode numbers
                    if (length of seasonNumber) = 1 then set seasonNumber to "0" & seasonNumber
                    if (length of episodeNumber) = 1 then set episodeNumber to "0" & episodeNumber

                    -- Reconstruct the new name
                    set newName to prePart & "S" & seasonNumber & "E" & episodeNumber
                    if (length of postEpisodeText) > 0 then set newName to newName & " " & postEpisodeText
                    if fileExtension is not "" then set newName to newName & "." & fileExtension
                    set name of aFile to newName
                end if

            on error errMsg
                -- Error handling: This file will be skipped
                display dialog "Error processing file: " & (name of aFile) & ". Error: " & errMsg buttons {"OK"} default button 1
            end try
        end repeat
    end tell
end run
