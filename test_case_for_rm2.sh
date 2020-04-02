#!/bin/sh

#------------------------------------------------------
# test 1
# base case: all the file in working, index, repo are the same
# should remove successfully for (rm, --force, --cached)
###############################
# working #  index  #  repo   #
#  a,b,c  #  a,b,c  #  a,b,c  #
###############################

legit.pl init
touch a b c
legit.pl add a b c
legit.pl commit -m 'add a b c'
legit.pl rm a
legit.pl rm --force b
legit.pl rm --cached c

# after that, the files should be
###############################
# working #  index  #  repo   #
#    c    #         #  a,b,c  #
###############################

#------------------------------------------------------
#test 2
# Initiate the files:
touch 1
legit.pl add 1
touch b
legit.pl add b
rm b
# then the three directory will look like:
###############################
# working #  index  #  repo   #
#   1,c   #   1,b   #  a,b,c  #
###############################
# if file exist in working and index but not in repo like file 1
# rm <file> should produce error 'legit.pl: error: '1' has changes staged in the index'
legit.pl rm 1

# if the content of file 1 in working and index is different
# rm <file> should produce error:
# 'legit.pl: error: '1' in index is different to both working file and repository'
echo abc >1
legit.pl rm 1
rm 1
touch 1

# rm --force should remove file
legit.pl rm --force 1
touch 1
legit.pl add 1

# rm --cached should remode file only from index
legit.pl rm --cached 1

# if the content of file 1 in working and index is different
# rm --cached <file> should produce error:
# 'legit.pl: error: '1' in index is different to both working file and repository'
echo abc >1
legit.pl rm --cached 1

# if file exist in index and repo but not in working like file b
# rm <file> should remove file from index
# NOTE if <file> content in index is different from that in repo, file should also be removed
legit.pl rm b
echo 123 >b
legit.pl add b
rm b
legit.pl rm b

# rm --force should remove file from index
touch b;legit.pl add b;rm b
legit.pl rm --force b

# rm --cached should remove file from index
touch b;legit.pl add b;rm b
legit.pl rm --cached b


# if file exist in working and repo but not in index like file c
# rm [--force] [--cached] should all produce error
# 'legit.pl: error: 'c' is not in the legit repository'
legit.pl rm c
legit.pl rm --force c
legit.pl rm --cached c

# after that, the files should be
###############################
# working #  index  #  repo   #
#  1',c   #    1    #  a,b,c  #
###############################

#------------------------------------------------------
#test 3
# Initiate the files:
rm 1;legit.pl rm 1
rm c
touch 1
touch 2;legit.pl add 2;rm 2
# then the three directory will look like:
###############################
# working #  index  #  repo   #
#    1    #    2    #  a,b,c  #
###############################
# if file only exist in working like file 1
# rm [--force] [--cached] should all produce error
# 'legit.pl: error: '1' is not in the legit repository'
legit.pl rm 1
legit.pl rm --force 1
legit.pl rm --cached 1

# if file only exist in index like file 2
# rm [--force] [--cached] should all remove file from index
legit.pl rm 2
touch 2;legit.pl add 2;rm 2
legit.pl rm --force 2
touch 2;legit.pl add 2;rm 2
legit.pl rm --cached 2

# after that, the files should be
###############################
# working #  index  #  repo   #
#    1    #         #  a,b,c  #
###############################

#------------------------------------------------------
#test 4
# Initiate the files:
rm 1;touch a b c d;legit.pl add a b c d
legit.pl commit -m 'add d'
echo 123 >>a;legit.pl add a
echo 123 >>b;legit.pl add b;rm b;touch b
echo 1234 >>c
echo 1234 >>d;legit.pl add d;echo abcd >>d

# then the three directory will look like:
########################################
#   working   #    index   #   repo    #
# a',b,c',d'' # a',b',c,d' #  a,b,c,d  #
########################################
# if <file> content same in working and index but different in repo like file a
# rm <file> will produce an error:
# 'legit.pl: error: 'a' has changes staged in the index'
legit.pl rm a

# rm --force will remove file from index and working
legit.pl rm --force a
echo 123 >a;legit.pl add a

# rm --cached will remove file from index
legit.pl rm --cached a


# if <file> content same in working and repo but different in index like file b
# rm <file> should produce error:
# 'legit.pl: error: 'b' in index is different to both working file and repository'
legit.pl rm b

# rm --force will remove file from both index and working
legit.pl rm --force b
echo 123 >b;legit.pl add b;rm b;touch b

# rm --cached will produce error:
# 'legit.pl: error: 'b' in index is different to both working file and repository'
legit.pl rm --cached b


# if <file> content same in index and repo but different in working like file c
# rm <file> should produce error:
# 'legit.pl: error: 'c' in repository is different to working file'
legit.pl rm c

# rm --force will remove file from index and working
legit.pl rm --force c
touch c;legit.pl add c;echo 1234 >>c

# NOTE: rm --cached will remove only from index:
legit.pl rm --cached c


# if <file> in working, index, repo are not the same like file d
# rm <file> will produce error:
# 'legit.pl: error: 'd' in index is different to both working file and repository'
legit.pl rm d

# --cached will produce error:
# 'legit.pl: error: 'd' in index is different to both working file and repository'
legit.pl rm --cached d

# --force will remove file in both index and working
legit.pl rm --force d

# after that, the files should be
##################################
# working #  index  #    repo    #
# a',b,c' #    b'   #   a,b,c,d  #
##################################

















