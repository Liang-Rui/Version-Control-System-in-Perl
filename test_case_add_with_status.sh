#!/bin/sh

#------------------------------------------------------
# case 1
# test for add before init
#------------------------------------------------------
legit.pl add

#------------------------------------------------------
# case 2
# test for file does not exist in current directory
# and index
#------------------------------------------------------
legit.pl init
legit.pl add 0

#------------------------------------------------------
# case 3
# test for adding deleted file but already in index
# REQUIREMENT: Implement legit commit and legit show.
#------------------------------------------------------
echo 123abc >1
legit.pl add 1
legit.pl commit -m 'add 1'
legit.pl show 0:1
legit.pl show :1
rm 1
legit.pl status
legit.pl add 1
legit.pl show :1
legit.pl commit -m 'rm 1'
legit.pl show 1:1
legit.pl status

#------------------------------------------------------
# case 4
# test for adding one or more invalid files
# NOTE: If we add multiple files, and if there is an 
# error, the files are not added to index.
# REQUIREMENT: Implement legit commit and legit show.
#------------------------------------------------------
mkdir directory
legit.pl add directory
touch file\ with\ spaces
legit.pl add file\ with\ spaces
echo abc >file_with-different.characters
legit.pl add file_with-different.characters
legit.pl show :file_with-different.characters
echo 1234 >123file_start_with-numbers
legit.pl add 123file_start_with-numbers
legit.pl show :123file_start_with-numbers
touch _file-starts-with-characters
legit.pl add _file-starts-with-characters
touch .123
legit.pl add .123
touch ^123
legit.pl add ^123
legit.pl add ""
legit.pl add ' '
legit.pl add " "
legit.pl add '   '
legit.pl add "   "
echo abc >0
legit.pl add 0
legit.pl show :0
echo abc >0.0
legit.pl show :0.0
touch a%@b_
legit.pl add a%@b_
touch 'file_with*$'
legit.pl add 'file_with*$'
legit.pl status

echo 123 >a
echo 234 >b
echo 345 >c
legit.pl add a b no_file c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b a%@b_ c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b '' c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b ' ' c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b '   ' c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b     c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl status

legit.pl add a b file_with-different.characters c
legit.pl show :a
legit.pl show :b
legit.pl show :c
legit.pl show :file_with-different.characters
legit.pl status


#------------------------------------------------------
# case 4
# test for adding files updated
# REQUIREMENT: Implement legit commit and legit show.
#------------------------------------------------------
echo 123 >update_file
legit.pl add update_file
legit.pl show :update_file
echo abc123 >>update_file
legit.pl show :update_file
legit.pl add update_file
legit.pl show :update_file
legit.pl status

echo 123 >multiple_update_files1
echo abc >multiple_update_files2
echo def >multiple_update_files3
legit.add multiple_update_files1 multiple_update_files2 multiple_update_files3
legit.show :multiple_update_files1
legit.show :multiple_update_files2
legit.show :multiple_update_files3
echo 1234567 >>multiple_update_files2
legit.add multiple_update_files1 multiple_update_files2 multiple_update_files3
legit.show :multiple_update_files1
legit.show :multiple_update_files2
legit.show :multiple_update_files3
legit.pl status





