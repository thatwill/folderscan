# folderscan
Windows script to scan a list of folders for older unused files. Within the chosen folders, files that have not been created, modified, or accessed for a set number of days, will be recycled/deleted.

Intended to occasionally clear out folders full of crap, such as a Download folder. Inspired by, but not based on, a feature of Belvedere.

Written haphazardly in Autoit. Use with caution.

# Download
[Download 0.1 here](https://github.com/thatwill/folderscan/releases/tag/0.1)

# Instructions
Extract to a new folder, and edit the settings.ini file to reflect the folders you wish to clean out. Run the application to immediately clean out. The tool is designed to run silently in the background; there is no UI. The results will be shown in a log file.
