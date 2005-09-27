#!/usr/bin/perl
use Test::More;
plan( tests => 7);
sub help { print "help"; };
sub version { print "version"; };
use strict;

sub getopt_test($$@){
	my $txt = shift;
	my $exp = shift;
	my $str = shift;
	if ( open(STDIN,"-|") ) {
		my $res = join("", <STDIN>);
		is($res,$exp,$txt);
	} else {
		eval {
			use Getopt::WonderBra;
			print join("\n",getopt($str,@_));
			exit(0);
		};
	};
};
getopt_test("nada",  "--",         "");
getopt_test("ddash", "--",         "",            qw(--));
getopt_test("dasha", "-a\n--",     "a",           qw(-a));
getopt_test("long",  "--long\n--", "",            qw(--long));
getopt_test("justx", "--\nx",      "x",           qw(x));
getopt_test("ddx",   "--\nx",      "x",           qw(-- x));
getopt_test("dv",    "-v\n--",     "v",           qw(-v));
