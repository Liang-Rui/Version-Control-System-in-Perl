#!/bin/sh

#------------------------------------------------------
# case 1
# Test for show before init.
#------------------------------------------------------
legit.pl show

#------------------------------------------------------
# case 2
# Test for show before any commits.
#------------------------------------------------------
legit.pl init
legit.pl show
legit.pl show :1
legit.pl show 0:1
legit.pl show 1
echo 123 >a
echo abc >0
legit.pl add a 0
legit.pl show :a
legit.pl show :0

#------------------------------------------------------
# case 3
# Test for some invalid show commands.
# REQUIREMENT: Implement legit commit.
#------------------------------------------------------
legit.pl commit -m 'add a 0'
legit.pl status
legit.pl show 0:0
legit.pl show 0:a
legit.pl show :a
legit.pl show :0
legit.pl show ::0
legit.pl show
legit.pl show a::0
legit.pl show :0 :a
legit.pl show :a a
legit.pl show :::0
legit.pl show :
legit.pl show 0:123
legit.pl show abc
legit.pl show abcde123
legit.pl show :::::
legit.pl show 0:0:0:0:0

#------------------------------------------------------
# case 4
# Test for showing some invalid or valid file names.
#------------------------------------------------------
legit.pl show :_abc
legit.pl show :a_@
legit.pl show :0abc
legit.pl show :abc\(abc\)
legit.pl show :abc.c_i-o
legit.pl show :\(abc\)
legit.pl show :^\(abc\)
legit.pl show 0:_abc
legit.pl show 0:0abc
legit.pl show 0:abc\(abc\)
legit.pl show 0:abc.c_i-o
legit.pl show 0:\(abc\)
legit.pl show 0:^\(abc\)
legit.pl show '':''
legit.pl show ' ':' '
legit.pl show '   ':'   '
legit.pl show    :   

#------------------------------------------------------
# case 4
# Test for multiple commits and show again.
# REQUIREMENT: Implement legit commit.
#------------------------------------------------------
echo 123abc >>0
legit.pl add 0
legit.pl show :0
legit.pl commit -m 'modify 0'
legit.pl show 1:0
legit.pl status

echo ijk >>a
legit.pl add a
legit.pl show :0
legit.pl show :a
legit.pl commit -m 'modify a'
legit.pl show 2:0
legit.pl show 2:a

echo 888 >>b
legit.pl show :b
legit.pl show 2:b
legit.pl show 3:b
legit.pl add b
legit.pl show :b
legit.pl show 2:b
legit.pl commit -m 'add b'
legit.pl show :b
legit.pl show 3:b
legit.pl show 3:0
legit.pl show 3:a
legit.pl show 3:c
legit.pl status






