#!/usr/bin/perl -w

use File::Compare;
use File::Copy;

$0 =~ s/.*\///;
sub main() {
    if (@ARGV == 0) {
        legit_usage();
        exit 1;
    } elsif ($ARGV[0] eq 'init') {
        legit_init();
    } elsif ($ARGV[0] eq 'add') {
        shift @ARGV;
        legit_add(@ARGV);
    } elsif ($ARGV[0] eq 'commit') {
        legit_commit();
    } elsif ($ARGV[0] eq 'show') {
        legit_show();
    } elsif ($ARGV[0] eq 'log') {
        legit_log();
    } elsif ($ARGV[0] eq 'rm') {
        legit_rm();
    } elsif ($ARGV[0] eq 'status') {
        legit_status();
    } elsif ($ARGV[0] eq 'branch') {
        legit_branch();
    } elsif ($ARGV[0] eq 'checkout') {
        legit_checkout();
    } elsif ($ARGV[0] eq 'merge') {
        
    } else {
        print STDERR "$0: error: unknown command $ARGV[0]\n";
        legit_usage();
        exit 1;
    }
}


# Print legit usage if no command specified.
sub legit_usage {
    print STDERR <<eof;;
Usage: $0 <command> [<args>]

These are the legit commands:
   init       Create an empty legit repository
   add        Add file contents to the index
   commit     Record changes to the repository
   log        Show commit log
   show       Show file at particular state
   rm         Remove files from the current directory and from the index
   status     Show the status of files in the current directory, index, and repository
   branch     list, create or delete a branch
   checkout   Switch branches or restore current directory files
   merge      Join two development histories together

eof
}


# Init legit repository.
sub legit_init{
    if (@ARGV != 1) {
        print STDERR "usage: legit.pl init\n";
        exit 1;
    }
    if (-d ".legit") {
        print STDERR "$0: error: .legit already exists\n";
        exit 1;
    }

    mkdir ".legit" or die "can not create .legit: $!\n";
    mkdir ".legit/repo" or die "can not create .legit/repo: $!\n";
    mkdir ".legit/index" or die "can not create .legit/index: $!\n";
    mkdir ".legit/backup_index" or die "can not create .legit/backup_index: $!\n";

    open my $log, '>', ".legit/log" or die "Cannot open .legit/log: $!\n";
    close $log;

    open my $branches, '>', ".legit/branches" or die "Cannot open .legit/branches: $!\n";
    print $branches "master#none#none\n";  # make it easy for update branches
    close $branches;

    open my $current_branch, '>', ".legit/current_branch" or die "Cannot open .legit/current_branch: $!\n";
    print $current_branch "master\nnone";
    close $current_branch;

    print "Initialized empty legit repository in .legit\n";

    return 0;
}


# Main function for legit_add which adds files into index.
sub legit_add{
    check_legit_init();
    my (@files) = @_;

    # validate input files
    foreach $file (@files) {
        # NOTE: IMPORTANT! validate file name
        validate_file_name($file);
        validate_regular_file($file);

        my $file_in_index = ".legit/index/".$file;

        # if the file is not in both current directory and index, print error:
        # "legit.pl: error: can not open '<file>'"
        if (!-f $file && !-f $file_in_index) {
            print STDERR "$0: error: can not open '$file'\n";
            exit 1;
        }
    }

    foreach $file (@files) {
        my $file_in_index = ".legit/index/".$file;

        # First remove file from index then copy file in current directory to index
        # if file exist in current directory.
        # This can handle if the case when the file exist in index but not in current directory.
        unlink $file_in_index if -f $file_in_index;
        copy($file, $file_in_index) or die "Copy $file failed: $!\n" if -f $file;
    }
    return 0;
}


# Main function for legit_commit which put all the files in index to repository.
sub legit_commit{
    check_legit_init();
    shift @ARGV;
    my @status_code;

    if (@ARGV == 2 && $ARGV[0] eq '-m' && $ARGV[1] ne "") {
        @status_code = legit_commit_m($ARGV[1]);
    } elsif (@ARGV == 3 && $ARGV[0] eq '-a' && $ARGV[1] eq '-m' && $ARGV[2] ne "") {
        @status_code = legit_commit_a($ARGV[2]);
    } else {
        print STDERR "usage: legit.pl commit [-a] -m commit-message\n";
        exit 1;
    }

    if (scalar @status_code == 1) {
        print "nothing to commit\n";
    } else {
        print "Committed as commit $status_code[1]\n";
    }
    return 0;
}


# Sub function for legit_commit with specified "-m".
sub legit_commit_m{
    my ($commit_message) = @_;

    my ($current_branch, $last_commit_number) = read_current_branch_and_commit_number();
    my $last_commit_dir = ".legit/repo/commit".$last_commit_number."/*";

    if ($last_commit_number ne 'none') {
        # Check whether the number of file with same name in index and repo are the same
        # if it is not the same, then perform a commit.
        my @common_files_of_index_repo = select_common_files(".legit/index/*", $last_commit_dir);

        my $index_and_repo_is_equal = pop @common_files_of_index_repo;
        if (!$index_and_repo_is_equal) {
            copy_file_to_commit($current_branch, ++$last_commit_number, $commit_message);
            return (1, $last_commit_number);
        }
        # If the number of files with same name in index and repo are the same
        # then we need to check the content of these files. If one of the content of
        # the file is not the same, then perform commit.
        foreach $file (@common_files_of_index_repo) {
            my $file_in_index = ".legit/index/".$file;
            my $file_in_repo = ".legit/repo/commit".$last_commit_number."/".$file;

            # compare will return:
            # 1 if two file are not the same 
            # 0 if the same
            # -1 if an error occur
            if (compare($file_in_index, $file_in_repo) == 1) {
                copy_file_to_commit($current_branch, ++$last_commit_number, $commit_message);
                return (1, $last_commit_number);
            }
        }
        # If the content of the files are the same, then nothing to commit.
        return 0; 
    } else {
        # If this is the first commit for the branch, and index is empty, then nothing to commit.
        my @index_files = glob ".legit/index/*";
        if (@index_files) {
            copy_file_to_commit($current_branch, 0, $commit_message);
            return (1, 0);
        } else {
            return 0;
        }
    }
}


# Sub function for legit_commit with specified "-a".
# commit -a is a combined command which first perform legit add all the file in index
# then perform a commit
# However, if nothing to commit, we need to restore previous files in index.
sub legit_commit_a{
    my ($commit_message) = @_;
    my @files_in_index;

    # delte backup files in brackup_index
    # NOTE: It is important to delete files before copying to that directory.
    unlink  $_ foreach glob ".legit/backup_index/*";

    # perform commit add for all the files in index
    foreach $file (glob ".legit/index/*") {
        copy($file, ".legit/backup_index");
        $file =~ s/.*\///;
        push @files_in_index, $file;
    }
    legit_add(@files_in_index);

    # if nothing to commmit, restore all the files
    my @status_code = legit_commit_m($commit_message);
    if (scalar @status_code == 1) {
        unlink $_ foreach glob ".legit/index/*";
        copy($_, ".legit/index") foreach glob ".legit/backup_index/*";
    }

    return @status_code;
}


# Sub function of legit_commit which finds common files in two directory and return those
# file names and whether the number of files with the same name in two directory is equal
sub select_common_files {
    my ($directory1, $directory2) = @_;
    my %files;
    my @common_files;
    my $is_equal = 1;

    # read all the <file_name> in directory1 and directory2 to hash %files;
    foreach $file (glob "$directory1 $directory2") {
        $file =~ s/.*\///;
        next if $file eq "legit.pl";
        $files{$file} ++;
    }

    # select common files
    foreach $file (keys %files) {
        if ($files{$file} == 2) {
            push @common_files, $file;
        }
    }
    # Check whether the number of files with the same name in both directory is
    # the same.
    # NOTE: THIS DOES NOT COMPARE CONTENTS.
    $is_equal = 0 if scalar keys %files != scalar @common_files;
    push @common_files, $is_equal;
    return @common_files;
}


# Sub function of legit_commit which copies all the files in index to repo/commit<N>,
# update log, branches and current_branch file.
sub copy_file_to_commit {
    my ($current_branch, $last_commit_number, $commit_message) = @_;

    my $commit_dir = ".legit/repo/commit".$last_commit_number;

    # create a new directory for commit
    mkdir $commit_dir or die "can not create $commit_dir: $!\n";

    # copy all the file in index to repo
    foreach $file (glob ".legit/index/*") {
        copy($file, $commit_dir) or die "Copy $file failed: $!\n";
    }

    # update log file
    # the format of log file is as follows:
    #-------------------
    # 0 message0
    # 1 message1
    # 2 message2
    # ...
    #-------------------
    open my $log, '>>', ".legit/log" or die "Cannot open .legit/log: $!\n";
    print $log "$last_commit_number $commit_message\n";
    close $log;

    # update branches file
    # the format of branches file is as follows:
    #-------------------
    # (branch_name)#first_commit#last_commit
    #-------------------
    # if no commit:
    # (branch_name)#none#none
    #-------------------
    # after some commits:
    # master#commit0#commit3
    # branch1#commit4#commit5
    # branch2#commit6#commit8
    # ...
    #-------------------
    open my $read_branches, '<', ".legit/branches" or die "Cannot open .legit/branches: $!\n";
    my @branches;
    while ($branch = <$read_branches>) {
        chomp $branch;
        $branch =~ /^(.*)#(\d+|none)#(\d+|none)$/;
        my $branch_name = $1;
        my $first_commit = $2;
        if ($branch_name eq $current_branch) { 
            if ($first_commit eq "none") {
                # if this is the first time of a commit for the new branch, then update all
                $branch_name .= "#".$last_commit_number."#".$last_commit_number;
            } else {
                # if this is not the first time, then update the last commit number
                $branch_name .= "#".$first_commit."#".$last_commit_number;
            }
            push @branches, $branch_name;
        } else {
            push @branches, $branch;
        }
    }
    close $read_branches;
    open my $write_branches, '>', ".legit/branches" or die "Cannot open .legit/branches: $!\n";
    print $write_branches "$_\n" foreach @branches;
    close $write_branches;

    # update current_branch file
    # the format of current_branch file is as follows:
    #-------------------
    # current_branch_name
    # current_commmit_number
    #-------------------
    open my $write_current_branch, '>', ".legit/current_branch" or die "Cannot open .legit/current_branch: $!\n";
    print $write_current_branch "$current_branch\n".$last_commit_number;
    close $write_current_branch;
    return 0;
}


# Main function for legit_show which shows the content of index or repository.
sub legit_show {
    check_legit_init();
    check_legit_any_commit();
    if (@ARGV != 2) {
        print STDERR "usage: $0 show <commit>:<filename>\n";
        exit 1;
    }
    my $legit_show_command = $ARGV[1] =~ /^(.*?):(.*)/;
    my $commit_number = $1;
    my $file_name = $2;
    my $status_code;  # return status_code for legit_show_file() function
    if ($legit_show_command) {
        if ($commit_number ne "") {
            # if commit number specified, show file in repo
            validate_commit_number($commit_number);
            # The order of validating is important, we first validate commit
            # then validate file name.
            validate_file_name($file_name);
            $status_code = legit_show_file(".legit/repo/commit".$commit_number."/".$file_name);
        } else {
            validate_file_name($file_name);
            # if commit number is not specified then show file in index
            $status_code = legit_show_file(".legit/index/".$file_name);
        }
        if ($status_code) {
            if ($commit_number ne "") {
                print STDERR "$0: error: '$file_name' not found in commit $commit_number\n";
                exit 1;
            } else {
                print STDERR "$0: error: '$file_name' not found in index\n";
                exit 1;
            }
        }
    } else {
        print STDERR "$0: error: invalid object $ARGV[1]\n";
        exit 1;
    }
    return 0;
}


# Main function for legit_log which shows the commits log.
sub legit_log {
    check_legit_init();
    check_legit_any_commit();
    if (@ARGV != 1) {
        print STDERR "usage: $0 log\n";
        exit 1;
    }

    # simplily print the log
    open my $log, '<', ".legit/log" or die "Cannot open .legit/log: $!\n";
    my @log = <$log>;
    close $log;
    print "$_" foreach reverse @log;
    return 0;
}


# Main function for legit_rm which removes files in index or repository.
sub legit_rm {
    check_legit_init();
    check_legit_any_commit();
    my ($force, $cached, @files) = validate_command_for_rm_and_retrieve_files();

    my @branch_and_commit_number = read_current_branch_and_commit_number();
    my $commit_number = $branch_and_commit_number[1];

    my $repo_dir = ".legit/repo/commit".$commit_number."/";

    # error checking for all the input files
    foreach $file (@files) {
        my $file_in_index = ".legit/index/".$file;
        my $file_in_repo = $repo_dir.$file;

        validate_file_name($file);

        if (!-f $file_in_index) {
            print STDERR "$0: error: '$file' is not in the legit repository\n";
            exit 1;
        }

        validate_regular_file($file);
        
        # If not force, we need to futher check whether files which in working, index and repo
        # are the same.
        if (!$force && -f $file) {
            my $same_in_working_index = is_file_same($file, $file_in_index);
            my $same_in_working_repo = is_file_same($file, $file_in_repo);
            my $same_in_index_repo = is_file_same($file_in_index, $file_in_repo);

            if (!$same_in_working_index && !$same_in_index_repo) {
                print STDERR "$0: error: '$file' in index is different to both working file and repository\n";
                exit 1;
            }
            if (!$same_in_index_repo && !$cached) {
                print STDERR "$0: error: '$file' has changes staged in the index\n";
                exit 1;
            }
            if (!$same_in_working_repo && !$cached) {
                print STDERR "$0: error: '$file' in repository is different to working file\n";
                exit 1;
            }
        }
    }

    # delete files in index and working directory
    foreach $file (@files) {
        unlink $file if (-f $file && !$cached);
        unlink ".legit/index/".$file;
    }

    return 0;
}


# Sub function of legit_rm which validates command line arguments for legit_rm.
sub validate_command_for_rm_and_retrieve_files {
    my $force = 0;
    my $cached = 0;
    # make sure command line arguments are at least 2
    # rm <file or commands>
    if (@ARGV == 1) {
        print STDERR "usage: $0 rm [--force] [--cached] <filenames>\n";
        exit 1;
    }
    # command line argument may be the following:
    # legit.pl rm <fs>
    # legit.pl rm --force <fs>
    # legit.pl rm --cached <fs>
    # This implementation can deal with cases "--force" or "--cached" appear in first few arguments
    # or appear in the last few arguments but not in the middle.
    # such as:
    # "legit rm a b c d --cached" -> (this is valid)"
    # "legit rm --cached a b c d --cached" -> (this is valid)"
    # "legit rm --cached --force a b c d --cached --cached" -> (this is valid)"
    # "legit rm --force a b c d --cached" -> (this is valid)"
    # "legit rm --force a b --force c d --cached" -> (this is not valid)
    # "legit rm --force a b -f c d --cached" -> (this is not valid)
    shift @ARGV;

    # remove commands in the front
    while (@ARGV) {
        $argument = shift @ARGV;
        if ($argument eq "--force") {
            $force = 1;
        } elsif ($argument eq "--cached") {
            $cached = 1;
        } else {
            unshift @ARGV, $argument;
            last;
        }

    }

    # remove commands in the tail
    while (@ARGV) {
        $argument = pop @ARGV;
        if ($argument eq "--force") {
            $force = 1;
        } elsif ($argument eq "--cached") {
            $cached = 1;
        } else {
            push @ARGV, $argument;
            last;
        }

    }

    # Check whether there are any invalid commands start with "-".
    foreach $argument (@ARGV) {
        if ($argument =~ /^-/) {
            print STDERR "usage: $0 rm [--force] [--cached] <filenames>\n";
            exit 1;
        }
    }

    return ($force, $cached, @ARGV);
}


# Main function for legit_status which shows files information in working, index, and repository.
sub legit_status{
    check_legit_init();
    check_legit_any_commit();

    my @branch_and_commit_number = read_current_branch_and_commit_number();
    my $commit_number = $branch_and_commit_number[1];
    my $last_commit = ".legit/repo/commit".$commit_number."/";
    my @files_status;

    # check the file information in working, index and repo
    my @file_status_in_working_dir = file_status_in_working($last_commit);
    push @files_status, @file_status_in_working_dir;

    my @file_status_in_index_dir = file_status_in_index($last_commit);
    push @files_status, @file_status_in_index_dir;

    my @file_status_in_last_commit_dir = file_status_in_last_commit($last_commit);
    push @files_status, @file_status_in_last_commit_dir;

    print sort @files_status;
    return 0;

}


# Sub function of legit_status which chcecks files information in working directory.
sub file_status_in_working {
    my ($last_commit) = @_;
    my @files_status;

    foreach $file (glob "*") {
        next if ($file !~ /^[a-zA-Z0-9][a-zA-Z0-9_\-.]*$/ || !-f $file);
        next if $file eq "legit.pl";
        my $file_in_index = ".legit/index/".$file;
        my $file_in_repo = $last_commit.$file;

        if (!-f $file_in_index) {
            push @files_status, "$file - untracked\n";
            next;
        } elsif (!-f $file_in_repo) {
            push @files_status, "$file - added to index\n";
            next;
        }

        # if file in working, index and repo
        my $same_in_working_index = is_file_same($file, $file_in_index);
        my $same_in_index_repo = is_file_same($file_in_index, $file_in_repo);

        if ($same_in_working_index && $same_in_index_repo) {
            push @files_status, "$file - same as repo\n";
            next;
        }
        if (!$same_in_working_index && !$same_in_index_repo) {
            push @files_status, "$file - file changed, different changes staged for commit\n";
            next;
        }
        if (!$same_in_working_index && $same_in_index_repo) {
            push @files_status, "$file - file changed, changes not staged for commit\n";
            next;
        }
        if ($same_in_working_index && !$same_in_index_repo) {
            push @files_status, "$file - file changed, changes staged for commit\n";
            next;
        }
    }

    return @files_status;
}


# Sub function of legit_status which checks files information in index.
sub file_status_in_index {
    my ($last_commit) = @_;
    my @files_status;

    foreach $file (glob ".legit/index/*") {
        my $file_in_index = $file;
        $file =~ s/.*\///;
        my $file_in_repo = $last_commit.$file;

        if (!-f $file) {
            if (-f $file_in_repo && is_file_same($file_in_index, $file_in_repo)) {
                push @files_status, "$file - file deleted\n";
                next;
            } else {
                push @files_status, "$file - added to index\n";
                next;
            }
        }
    }
    return @files_status;
}


# Sub function of legit_status which ckecks files information in last commit.
sub file_status_in_last_commit {
    my ($last_commit) = @_;
    my @files_status;

    foreach $file (glob "$last_commit"."*") {
        $file =~ s/.*\///;
        my $file_in_index = ".legit/index/".$file;
        if (!-f $file && !-f $file_in_index) {
            push @files_status, "$file - deleted\n";
            next;
        }
    }

    return @files_status;
}


# Main function for legit branch [-d] [branch-name] which reads current branches,
# create a branch and delete a branch.
sub legit_branch {
    check_legit_init();
    check_legit_any_commit();

    if (@ARGV == 1) {
        display_branches();
    } elsif (@ARGV == 2) {
        create_branch($ARGV[1]);
    } elsif (@ARGV == 3 && $ARGV[1] eq "-d") {
        delete_branch($ARGV[2]);
    } else {
        print STDERR "usage: legit.pl branch [-d] <branch>\n";
        exit 1;
    }
    return 0;
}


# Sub function of legit_branch which prints all the current branches.
sub display_branches {
    my @branches = read_branches();
    print "$_\n" foreach sort @branches;
    return 0;
}


# Sub function of legit_branch which create a new branch.
sub create_branch {
    my ($new_branch_name) = @_;
    my @current_branches = read_branches();

    validate_branch_name($new_branch_name);

    foreach $branch (@current_branches) {
        if ($branch eq $new_branch_name) {
            print STDERR "$0: error: branch '$branch' already exists\n";
            exit 1;
        }
    }

    open my $write_branches, ">>", ".legit/branches" or die "$0 Cannot open .legit/branches: $!\n";
    print $write_branches "$new_branch_name#none#none\n";
    close $write_branches;

    return 0;

}


# Sub function of legit_branch which deletes a branch.
sub delete_branch {
    my ($delete_branch_name) = @_;

    my @branch_and_commit_number = read_current_branch_and_commit_number();
    my $current_branch_name = $branch_and_commit_number[0];
    validate_branch_name($delete_branch_name);

    if ($delete_branch_name eq "master") {
        print STDERR "$0: error: can not delete branch 'master'\n";
        exit 1;
    }

    # if the last commit of delete_branch_name is not the same as the current one
    # print an error message

    my $found_branch = 0;
    my @update_branches;

    open my $read_branches, "<", ".legit/branches" or die "$0 Cannot open .legit/branches: $!\n";
    my @current_branches = <$read_branches>;
    close $read_branches;

    foreach $line (@current_branches) {
        if ($line =~ /^$delete_branch_name#/) {

            # if the last commit of delete_branch_name is not the same as the current one
            # print an error message
            my $last_commit_of_current_branch = read_last_commit_of_branche($current_branch_name);
            my $last_commit_of_delete_branch = read_last_commit_of_branche($delete_branch_name);
            if ($last_commit_of_current_branch eq $last_commit_of_delete_branch || $last_commit_of_delete_branch eq "none") {
                $found_branch = 1 if ($last_commit_of_current_branch ne "not found" && $last_commit_of_delete_branch ne "not found")
            } else {
                print STDERR "$0: error: branch '$delete_branch_name' has unmerged changes\n";
                exit 1;
            }

        } else {
            push @update_branches, $line;
        }
    }

    # If branch needed to be deleted exist in current branches, then update branches
    # otherwise print error message.
    if ($found_branch) {
        open my $write_branches, ">", ".legit/branches" or die "$0 Cannot open .legit/branches: $!\n";
        print $write_branches "$_" foreach @update_branches;
        close $write_branches;
        print "Deleted branch '$delete_branch_name'\n"
    } else {
        print STDERR "$0: error: branch '$delete_branch_name' does not exist\n";
        exit 1;
    }

    return 0;
}


# Main function for legit checkout
sub legit_checkout {
    check_legit_init();
    check_legit_any_commit();
    if (@ARGV != 2) {
        print STDERR "usage: legit.pl checkout <branch>\n";
        exit 1;
    }
    my ($checkout_branch) = $ARGV[1];
    my @branch_and_commit_number = read_current_branch_and_commit_number();
    my $current_branch = $branch_and_commit_number[0];

    if ($checkout_branch eq $current_branch) {
        print "Already on '$current_branch'\n";
        return 0;
    }

    my $last_commit_number = read_last_commit_of_branche($checkout_branch);

    if ($last_commit_number eq "not found") {
        print STDERR "$0: error: unknown branch '$checkout_branch'\n";
        exit 1;
    }

    if ($last_commit_number ne "none") {
        my $repo_dir = ".legit/repo/commit".$last_commit_number."/";
        my @overwritten_files;
        foreach $file (glob $repo_dir."*") {
            my $file_in_repo = $file;
            $file =~ s/.*\///;
            if (!is_file_same($file, $file_in_repo)) {
                print STDERR "$0: error: Your changes to the following files would be overwritten by checkout:\n";
                push @overwritten_files, $file;
            }
        }

        if (@overwritten_files) {
            print "$_\n" foreach sort @overwritten_files;
            exit 1;
        } else {
            update_branch_info($checkout_branch, $last_commit_number);
        }
    } else {
        update_branch_info($checkout_branch, $last_commit_number);
    }
    
}


# Sub function of legit_checkout which updates current_branch information.
sub update_branch_info {
    my ($current_branch, $last_commit_number) = @_;

    open my $write_current_branch, '>', ".legit/current_branch" or die "Cannot open .legit/current_branch: $!\n";
    print $write_current_branch "$current_branch\n".$last_commit_number;
    close $write_current_branch;

    return 0;
}










#---------------------------------------------------------------------------------
# Helper funnctions.
#---------------------------------------------------------------------------------

# Helper function which checks whether legit has init a repository befor.
sub check_legit_init{
    if (!-d ".legit") {
        print STDERR "$0: error: no .legit directory containing legit repository exists\n";
        exit 1;
    }
    return 0;
}


# Helper function to validate a filename.
#---------------------------------------------------------------------------------
# Only ordinary files in the current directory can be added, and their names will 
# always start with an alphanumeric character ([a-zA-Z0-9]) and will only contain 
# alpha-numeric characters plus '.', '-' and '_' characters.
#---------------------------------------------------------------------------------
sub validate_file_name {
    my ($file) = @_;

    my $is_valid_file = $file =~ /^[a-zA-Z0-9][a-zA-Z0-9_\-.]*$/;

    if (!$is_valid_file || $file eq "") {
        print STDERR "$0: error: invalid filename '$file'\n";
        exit 1;
    }

    return 0;
}


# Helper function which checks whether a file is a regular file.
sub validate_regular_file {
    my ($file) = @_;
    # if the file is not plain file, print error:
    # "legit.pl: error: '<file>' is not a regular file"
    if (-e $file && !-f $file) {
        print STDERR "$0: error: '$file' is not a regular file\n";
        exit 1;
    }
    return 0;
}


# Helper function which can read the current branch and the last commit
# number in this branch.
sub read_current_branch_and_commit_number {
    open my $current_branches_file, '<', ".legit/current_branch" or die "Cannot open .legit/current_branch: $!\n";
    my ($current_branch, $last_commit_number) = <$current_branches_file>;
    close $current_branches_file;
    chomp $current_branch;
    return ($current_branch, $last_commit_number);
}


# Helper function which check whether there are any commits.
sub check_legit_any_commit{
    if (-z ".legit/log") {
        print STDERR "$0: error: your repository does not have any commits yet\n";
        exit 1;
    }
    return 0;
}


# Helper function which compares the file in two different directory, if the file does  
# not both exist or both not exist or have different contents in this two directory, 
# then return 0. If they both exist, both not exist, or have same content in this 
# two directory, then return 1.
sub is_file_same{
    my ($file_in_d1, $file_in_d2) = @_;

    if (-f $file_in_d1 && -f $file_in_d2) {
        my $compare_result = compare($file_in_d1, $file_in_d2);
        if ($compare_result == 1) {
            return 0;
        } elsif ($compare_result == 0) {
            return 1;
        } else {
            # catch unkonwn error if compare() fails
            print STDERR "$!\n";
            exit 1;
        }
    } elsif (!-f $file_in_d1 && !-f $file_in_d2) {
        return 1;
    } else {
        return 0;
    }
}


# Helper function that validates whether the input commit number is valid.
sub validate_commit_number {
    my ($commit_number) = @_;
    if ($commit_number !~ /\d+/ || !(-d ".legit/repo/commit".$commit_number)) {
        print STDERR "$0: error: unknown commit '$commit_number'\n";
        exit 1;
    }
    return 0;
}


# Helper function that prints the content of the file.
sub legit_show_file {
    my ($file) = @_;
    if (-f $file) {
        open my $read_file, '<', "$file" or die "Cannot open $file: $!\n";
        while ($line = <$read_file>) {
            print "$line";
        }
        close $read_file;
        return 0;
    } else {
        # file does not exist
        return 1;
    }
}


# Helper function that reads branches and return them.
sub read_branches {
    open my $read_branches, "<", ".legit/branches" or die "$0 Cannot open .legit/branches: $!\n";
    my @branches;
    while($line = <$read_branches>) {
        $line =~ /(.*?)#/;
        push @branches, $1;
    }
    close $read_branches;
    return @branches;
}


# Helper function that validates branch name.
sub validate_branch_name {
    my ($branch_name) = @_;
    if ($branch_name =~ /^[a-zA-Z0-9][a-zA-Z0-9\-_]*$/ && $branch_name !~ /^\d+$/) {
        return 1;
    } else {
        print STDERR "$0: error: invalid branch name '$branch_name'\n";
        exit 1;
    }
}


# Helper function which reads the last commit number of a certatin branch.
sub read_last_commit_of_branche {
    my ($branch) = @_;
    open my $read_branches, "<", ".legit/branches" or die "$0 Cannot open .legit/branches: $!\n";
    my $last_commit_number = "not found";
    while($line = <$read_branches>) {
        chomp $line;
        if ($line =~ /^$branch#.*?#(.*)$/) {
            $last_commit_number = $1;
            last;
        }
    }
    close $read_branches;
    return $last_commit_number;
}










main();
exit 0;


