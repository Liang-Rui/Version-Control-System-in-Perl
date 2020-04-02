#!/bin/sh

#------------------------------------------------------
# case 1
# Test for status before any init.
#------------------------------------------------------
legit.pl status

#------------------------------------------------------
# case 2
# Test for each entry for status.
# REQUIREMENTS: Implement subset 0 and 1.
#------------------------------------------------------
legit.pl init
touch a b c d e f g h
echo 123 >i
echo lalala >j
legit.pl add a b c d e f i
legit.pl commit -m 'first commit'
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show :d
legit.pl show :e
legit.pl show :f
legit.pl show :g
legit.pl show :h
legit.pl show :i
legit.pl show :j
legit.pl show 0:a
legit.pl show 0:b
legit.pl show 0:c
legit.pl show 0:d
legit.pl show 0:e
legit.pl show 0:f
legit.pl show 0:g
legit.pl show 0:h
legit.pl show 0:i
legit.pl show 0:j
echo hello >a
echo hello >b
echo hello >c
echo abc >>i
legit.pl add a b i j
rm i
echo 123 >i
echo world >a
rm d
legit.pl rm e
legit.pl add g
legit.pl status
legit.pl status a b c o 9 7 ^se
legit.pl status 8 6 @s -de a b c o 9 7 ^se

legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show :d
legit.pl show :e
legit.pl show :f
legit.pl show :g
legit.pl show :h
legit.pl show :i
legit.pl show :j
legit.pl show 0:a
legit.pl show 0:b
legit.pl show 0:c
legit.pl show 0:d
legit.pl show 0:e
legit.pl show 0:f
legit.pl show 0:g
legit.pl show 0:h
legit.pl show 0:i
legit.pl show 0:j
# after:
##################################################################
#        working        #         index        #      repo       #
#  a'',b',c',g,h,i,j    #  a',b',c,d,f,g,i',j  #  a,b,c,d,e,f,i  #
##################################################################
