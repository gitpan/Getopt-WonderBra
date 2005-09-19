# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

BEGIN { use Test::More; };
my @mods = qw( Getopt::WonderBra );
plan tests => 0+@mods;
for ( @mods ) {
	use_ok($_);
};
#########################

# Insert your test code below, the Test module is use()ed here so read
# its man page ( perldoc Test ) for help writing this test script.

