#!/bin/sh

#------------------------------------------------------
# case 1
# Test for branch before any init.
#------------------------------------------------------
legit.pl branch

#------------------------------------------------------
# case 2
# Test for some basic operation on branch.
#------------------------------------------------------
legit.pl init
touch a b c
legit.pl add a b c
legit.pl branch b1
legit.pl branch
legit.pl commit -m 'add a b c'
legit.pl branch

legit.pl branch b1
legit.pl branch b1
legit.pl branch

legit.pl branch b2
legit.pl branch b2
legit.pl branch

legit.pl branch @2
legit.pl branch 897
legit.pl branch 1
legit.pl branch io@#
legit.pl branch a-d_9
legit.pl branch 9_3-d
legit.pl branch

legit.pl branch -d 9
legit.pl branch -d d9e
legit.pl branch -d @#
legit.pl branch -d b1
legit.pl branch

legit.pl branch -d master
legit.pl branch

legit.pl branch -d b2
legit.pl branch

legit.pl branch -d b3
legit.pl branch

legit.pl branch -d b4
legit.pl branch


