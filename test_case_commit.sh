#!/bin/sh

#------------------------------------------------------
# case 1
# Test for commit before any init.
#------------------------------------------------------
legit.pl commit -m 'abc'
legit.pl commit
legit.pl commit -b

#------------------------------------------------------
# case 2
# Test for invalid commit commands for -m (subset0).
#------------------------------------------------------
legit.pl init
legit.pl commit
legit.pl commit -b
legit.pl commit -m
legit.pl commit -m a b
legit.pl commit -m a b c
legit.pl commit -m ""

#------------------------------------------------------
# case 3
# Test for first commit, but nothing in index.
#------------------------------------------------------
legit.pl commit -m "nothing"

#------------------------------------------------------
# case 4
# Test for first commit, add some files.
# REQUIREMENT: Implement legit add, show and log.
#------------------------------------------------------
echo 123 >0
echo 234 >1
echo 345 >2
legit.pl add 0 1 2
legit.pl show :0
legit.pl show :1
legit.pl show :2
legit.pl commit -m 'add 0'
legit.pl show 0:0
legit.pl show 0:1
legit.pl show 0:2
legit.pl log

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  0,1,2  #  0,1,2  #  0,1,2  #
###############################


#------------------------------------------------------
# case 5
# Test for commiting same file in working, index and repo.
#------------------------------------------------------
legit.pl commit -m 'same content'

#------------------------------------------------------
# case 6
# Test for files with different contents in working but
# same content in index and repo.
#------------------------------------------------------
echo abc >>0
legit.pl commit -m 'change 0 but not add 0'

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
# 0',1,2  #  0,1,2  #  0,1,2  #
###############################

#------------------------------------------------------
# case 7
# Test for different file number in index and repo.
# REQUIREMENT: Implement legit add, show and log.
#------------------------------------------------------
rm 1
legit.pl add 1
legit.pl show :1
legit.pl show 0:1
legit.pl commit -m 'remove 1'
legit.pl show :1
legit.pl show 1:1
legit.pl log

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  0',2   #   0,2   #   0,2   #
###############################

#------------------------------------------------------
# case 8
# Test for same file number and content in index and
# repo but with different names.
# REQUIREMENT: Implement legit add, show and log.
#------------------------------------------------------
mv 2 3
legit.pl show :2
legit.pl add 2
legit.pl show :2
legit.pl add 3
legit.pl show :2
legit.pl show :3
legit.pl commit -m 'change file name 2 to 3'
legit.pl show :0
legit.pl show :2
legit.pl show :3
legit.pl show 2:2
legit.pl show 2:3
legit.pl show 2:0

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  0',3   #   0,3   #   0,3   #
###############################

#------------------------------------------------------
# case 9
# Test for same file number, same name but different
# content in index and repo.
# REQUIREMENT: Implement legit add, show and log.
#------------------------------------------------------
legit.pl add 0
legit.pl show :0
legit.pl commit -m 'update file 0'
legit.pl show :0
legit.pl show 3:0
legit.pl show 3:3
legit.pl log

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  0',3   #   0',3  #   0',3  #
###############################

#------------------------------------------------------
# case 10
# Test for commit empty index and repo after some
# commits.
# REQUIREMENT: Implement legit add, show and log.
#------------------------------------------------------
rm 0 3
legit.pl add 0 3
legit.pl commit -m 'rm 0 3'
legit.pl show :0
legit.pl show :3
legit.pl show 4:0
legit.pl show 4:3
legit.pl log
legit.pl commit -m 'empty index and repo'

# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#         #         #         #
###############################







