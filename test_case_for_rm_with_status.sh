#!/bin/sh

#------------------------------------------------------
# case 1
# Test for rm before init.
#------------------------------------------------------
legit.pl rm a
legit.pl rm --force a
legit.pl rm --cached a


#------------------------------------------------------
# case 2
# Test for some invalid or valid inputs.
# REQUIREMENT: Implement legit add, commit.
#------------------------------------------------------
legit.pl init
echo 123 >a
echo 123 >b
echo 123 >c
legit.pl add a b c
legit.pl commit -m 'add a b c'
legit.pl status
legit.pl rm a --a
legit.pl rm a b c --force d
legit.pl rm a b c -force d
legit.pl rm a b c force d
legit.pl rm a b c @force d
legit.pl rm @a b
legit.pl rm @a b --cached
legit.pl rm a b --cached @a
legit.pl rm --c i
legit.pl rm -c i
legit.pl rm i -c
legit.pl rm i c -c
legit.pl rm %d
legit.pl rm a b --force c
legit.pl rm --force a --force b c --force
legit.pl rm --force a --cached b c --cached
legit.pl rm --cached a --force b c --cached
legit.pl rm --force a -a
legit.pl rm --cached -a c

# make some directory and try to remove them
mkdir 1 2 3
legit.pl rm 1 2 3
legit.pl rm a b 1 2
legit.pl rm d e 1 a
legit.pl rm a d 1 k
legit.pl status

# the following will remove a b c both index and working directory
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --force a b c --force
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

# the following will remove a b c from index
echo 123 >a
echo 123 >b
echo 123 >c
legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status
legit.pl rm --cached a b c --cached
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status

# the following will remove a b c from index
legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --force a b c --cached
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status

# the following will remove a b c from index
legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --cached a b c --force
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status

legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --force --cached a
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status

legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --force b --cached --force
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status

legit.pl add a b c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl rm --force --cached --force c --cached
legit.pl show :a
legit.pl show :b
legit.pl show :c
cat a
cat b
cat c
legit.pl status


