#!/usr/bin/perl -w
use File::Temp;
use Cwd;

# create two temporary directories
# this is done conveniently and securely by File::Temp
# File::Temp also automatically removes the directory when the program finishes

$test_directory = File::Temp->newdir or die;
$reference_directory = File::Temp->newdir or die;

# read commands and execute them
sub main {
    my $command;
    while ($command = <>) {
        chomp $command;
        execute($command) if $command;
    }
    print "*** Test passed ***\n";
    exit 0;
}

# execute a command using legit.pl
# and using the refenece implementation
# then check results are identical

sub execute {
    my ($command) = @_;
    print "\$ $command\n";

    # because of the cd - replace legit.pl with its full pathname
    my $test_command = $command;
    my $current_directory = getcwd;
    $test_command =~ s/(.\/)?legit\.pl/$current_directory\/legit.pl/g;

    my $test_output = `cd $test_directory; $test_command 2>&1`;
    print $test_output;

    # replace legit.pl with 2041 legit
    my $reference_command = $command;
    $reference_command =~ s/(.\/)?legit\.pl/2041 legit/g;

    my $reference_output = `cd $reference_directory; $reference_command 2>&1`;

    if ($test_output ne $reference_output) {
        $reason = "incorrect";
        $reason = "unexpected" if $reference_output eq '';
        $reason = "no" if $test_output eq '';
        print "*** TEST STOPPED: $reason output from legit.pl\n";
        print "2041 legit output:\n$reference_output";
        print "legit.pl output:\n$test_output";
        exit 1;
    }
    check_test_and_reference_directories_identical()
}

sub check_test_and_reference_directories_identical {

    # set up hashes containing files from both directories
    my (%test_file_set, %reference_file_set);

    # this won't files starting with .

    foreach $file (glob "$test_directory/*") {
        $file =~ s/.*\///;
        $test_file_set{$file} = 1;
    }
    foreach $file (glob "$reference_directory/*") {
        $file =~ s/.*\///;
        $reference_file_set{$file} = 1;
    }

    my @unexpected_files;
    for $file (sort keys %test_file_set) {
        push @unexpected_files, $file if !$reference_file_set{$file};
    }

    if (@unexpected_files) {
        print "*** TEST STOPPED: legit.pl incorrectly created these files: @unexpected_files\n";
        exit 1;
    }

    my @missing_files;
    for $file (sort keys %reference_file_set) {
        push @missing_files, $file if !$test_file_set{$file}
    }

    if (@missing_files) {
        print "*** TEST STOPPED: legit.pl should have created these files but did not: @missing_files\n";
        exit 1;
    }

    for $file (sort keys %test_file_set) {
        check_test_and_reference_file_identical($file) if $file ne ".legit";
    }
}

# check two files have identical contents
sub check_test_and_reference_file_identical {
    my ($file) = @_;

    open my $f, '<', "$reference_directory/$file" or die "can not open $reference_directory/$file\n";
    $reference_file_contents = join "", <$f>;
    close $f;

    open my $g, '<', "$test_directory/$file" or die "can not open $test_directory/$file\n";
    $test_file_contents = join "", <$g>;
    close $g;

    if ($reference_file_contents ne $test_file_contents) {
        print "*** TEST STOPPED: legit.pl has created file '$file' with incorrect contents\n";
        print "*** '$file' incorrect contents were:\n$test_file_contents\n";
        print "*** '$file' correct contents are:\n$reference_file_contents\n";
    }
}

main()