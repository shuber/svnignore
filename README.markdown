# svnignore

git style ignores with subversion

This script looks for files named `.svnignore` in the current directory along with all of its nested directories and ignores the patterns found in them

It can handle basic ignores, patterns (with *), recursive patterns (with **), and ignoring multiple files in the same directory


## Installation

Copy the `svnignore` file to `/usr/local/bin/svnignore` (or wherever you want it)


## Usage

Move into the root of your svn project (`cd ~/Projects/project_name`) and run `svnignore`

Here's a sample `.svnignore` file that I frequently use with rails projects

	**/.DS_Store
	config/application_settings.yml
	config/database.yml
	db/*.sqlite3
	log/*.log
	tmp/*

In this case, the script would parse those patterns and execute the following commands

	svn propset svn:ignore -R '.DS_Store' .
	svn propset svn:ignore -F some_temp_file config/
	svn propset svn:ignore '*.sqlite3' db/
	svn propset svn:ignore '*.log' log/
	svn propset svn:ignore '*' tmp/


## Contact

Problems, comments, and suggestions all welcome: [shuber@huberry.com](mailto:shuber@huberry.com)