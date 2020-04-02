# Introduction

This is a Perl program features a subset of the version control system Git. The Perl script `legit.pl` implements the following features of Git:

`legit.pl init` which creates a directory named **.legit** to store the repository. It produce an error message if this directory already exists.

`legit.pl add filenames` which adds the contents of one or more files to the "index". Only ordinary files in the current directory can be added, and their names will always start with an alphanumeric character ([a-zA-Z0-9]) and will only contain alpha-numeric characters plus '.', '-' and '_' characters.

`legit.pl commit -m message` which saves a copy of all files in the index to the repository. `legit.pl` commits are numbered (not hashes like Git). 

`legit.pl commit [-a] -m message` can have a `-a` option which causes all files already in the index to have their contents from the current directory added to the index before the commit.

`legit.pl log` which prints one line for every commit that has been made to the repository.

`legit.pl show commit:filename` which prints the contents of the specified file as of the specified commit. If the commit is omitted the contents of the file in the index should be printed.

`legit.pl rm [--force] [--cached] filenames` removes a file from the index, or from the current directory and the index. If the `--cached` option is specified the file is removed only from the index and not from the current directory. The `--force` option overrides both these checks.

`legit.pl status` shows the status of files in the current directory, index, and repository.

`legit.pl branch [-d] [branch-name]` either creates a branch, deletes a branch or lists current branch names. 

`legit.pl checkout branch-name` switches branches.

`test_legit.pl` tests all the test cases in the current directory. 

PLEASE REFERENCE THIS PROJECT PROPERLY OTHERWISE YOU MAY INVOLVE IN PLAGIARISM!

