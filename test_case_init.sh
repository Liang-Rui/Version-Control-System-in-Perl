#!/bin/sh

# test for multiple init error message
legit.pl init
legit.pl init
# should print "legit.pl: error: .legit already exists"

legit.pl init a
# should print "usage: legit.pl init"

legit.pl
# should print help message

legit.pl a
# should first print error message then print help message