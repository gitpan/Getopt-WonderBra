#!/usr/bin/perl
use Test::More;
use Getopt::WonderBra;
plan( tests => 4);
sub help { print "help"; };
sub version { print "version"; };
use strict;
my %long;
is_deeply([getopt("",@ARGV)],[qw(--)]);
is_deeply([getopt("",@ARGV,%long)],[qw(--)]);
@ARGV=qw(x);
is_deeply([getopt("",@ARGV)],[qw(-- x)]);
@ARGV=qw(-v);
is_deeply([getopt("v",@ARGV)],[qw(-v --)]);
