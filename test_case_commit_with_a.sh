#!/bin/sh

#------------------------------------------------------
# case 1
# Test for commit before init.
#------------------------------------------------------
legit.pl commit -a

#------------------------------------------------------
# case 2
# Test for invalid or valid commit commands before init.
#------------------------------------------------------
legit.pl commit -a -m a b
legit.pl commit -a -m 'abc'
legit.pl commit -m -a 'abc'
legit.pl commit ' ' ' ' ' '
legit.pl commit '' '' ''

#------------------------------------------------------
# case 3
# Test for invalid or valid commit commands after init.
#------------------------------------------------------
legit.pl init
legit.pl commit -a -m a b
legit.pl commit -a -m 'abc'
legit.pl commit -m -a 'abc'
legit.pl commit ' ' ' ' ' '
legit.pl commit '' '' ''
legit.pl commit -a -m 'a' 'b'
legit.pl commit -a 'm'

#------------------------------------------------------
# case 4
# Test for first commit which files in index is different
# from files in working directory.
# REQUIREMENT: Implement legit add.
#------------------------------------------------------
echo 123 >a
echo 123 >b
echo 123 >c
legit.pl add a b c
rm a b c
touch 1 2 3
# before:
# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  1,2,3  #  a,b,c  #         #
###############################
legit.pl commit -a -m 'add a b c and rm a b c'

# after:
# Files in working, index and repo(last commit) are:
###############################
# working #  index  #  repo   #
#  1,2,3  #  a,b,c  #         #
###############################

#------------------------------------------------------
# case 5
# Test for first commit which files in index is different
# from files in working directory but with some common
# files like:

# REQUIREMENT: Implement legit add, show.
#------------------------------------------------------
echo 123 >b
# before:
###################################
#   working   #  index  #  repo   #
#   1,2,3,b   #  a,b,c  #         #
###################################
legit.pl commit -a -m 'add b'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show :1
legit.pl show :2
legit.pl show :3
legit.pl show 0:a
legit.pl show 0:b
legit.pl show 0:c
legit.pl show 0:1
legit.pl show 0:2
legit.pl show 0:3

# after, commit0
#################################
#  working  #  index  #  repo   #
#  1,2,3,b  #    b    #    b    #
#################################

#------------------------------------------------------
# case 4
# Repeating test 1 but after 1 commits.
# REQUIREMENT: Implement legit add, show, commit -m.
#------------------------------------------------------
rm b
legit.pl add b
legit.pl commit -m 'rm b'
echo 123 >a
echo 123 >b
echo 123 >c
legit.pl add a b c
rm a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 1:a
legit.pl show 1:b
legit.pl show 1:c
# before, commit1
#################################
#  working  #  index  #  repo   #
#  1,2,3    #  a,b,c  #         #
#################################
legit.pl commit -a -m 'add a b c and rm a b c'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 1:a
legit.pl show 1:b
legit.pl show 1:c
# after
#################################
#  working  #  index  #  repo   #
#  1,2,3    #  a,b,c  #         #
#################################

#------------------------------------------------------
# case 5
# Test for same files in index and some in working.
# REQUIREMENT: Implement legit add, show.
#------------------------------------------------------
echo 123 >a
echo 123 >b
echo 123 >c
# before:
#######################################
#    working      #  index  #  repo   #
#  1,2,3,a,b,c    #  a,b,c  #         #
#######################################
legit.pl commit -a -m 'add a b c'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 2:a
legit.pl show 2:b
legit.pl show 2:c
# after, commit2
#######################################
#    working      #  index  #  repo   #
#  1,2,3,a,b,c    #  a,b,c  #  a,b,c  #
#######################################

#------------------------------------------------------
# case 6
# Test for some changes to some of the files in index
# but not all.
# REQUIREMENT: Implement legit add.
#------------------------------------------------------
echo modify >>a
rm c
# before:
#######################################
#    working      #  index  #  repo   #
#  1,2,3,a',b     #  a,b,c  #  a,b,c  #
#######################################
legit.pl commit -a -m 'modify a rm c'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 3:a
legit.pl show 3:b
legit.pl show 3:c
# after, commit3
#######################################
#    working      #  index  #  repo   #
#  1,2,3,a',b     #  a',b   #  a',b   #
#######################################
# double check nothing to commit would not cause
# changes in index
legit.pl commit -a -m 'modify a rm c'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 4:a
legit.pl show 4:b
legit.pl show 4:c

#------------------------------------------------------
# case 7
# Test for commit -a that add some directories in working 
# which the name is the same as files.
# REQUIREMENT: Implement legit add.
#------------------------------------------------------
mkdir a b
# before:
###########################################
#      working        #  index  #  repo   #
#  1,2,3,a',b,a,b     #  a',b   #  a',b   #
###########################################

legit.pl commit -a -m 'add directories a b'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show 4:a
legit.pl show 4:b
legit.pl show 4:c











