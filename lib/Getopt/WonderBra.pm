#!/usr/bin/env perl

=head1 NAME

Getopt::WonderBra - Lift and Separate Command Line Options

=head1 SYNOPSIS

    use Getopt::WonderBra;
    @ARGV = getopt( 'opts:-:', @ARGV );
    print Dumper( \@ARGV );
    sub help() { print "Useless help message"; };
    sub version() { print "Useless version message"; };
    while ( ( $_ = shift ) ne '--' ) {
    	if    (/^-o$/) { $opt_o++ }
    	elsif (/^-p$/) { $opt_p++ }
    	elsif (/^-t$/) { $opt_t++ }
    	elsif (/^-s$/) { push( @opt_s, shift ); }
    	elsif (/^--/)  { push( @opt_long, $_ ); }
    	else           { die 'I do not grok -', $_; }
    }
    while (<>) {
    	print;
    }

=head1 REQUIRES

perl5.008006, Carp, Exporter

=head1 EXPORTS

getopt($@) also wraps main::help(@) and main::version(), or exports
it's own (nearly worthless) versions if they do not exist.

=head1 DESCRIPTION

See example.pl for an example of usage.

There just weren't enough command line processessing modules, so I had
to write my own.  Actually, it exists because it made it easy to port
shell scripts to perl:	it acts just like the getopt program.  Oddly,
none of the modules that are actually named after it do.  (Though some
act like the C function)  The following sequence chops your args up and
gives 'em to you straight:

=head2 HELP

main::help(), if it exists, is wrapped by this module. This is done to
ensure correct behavior for programs that use getopt.  (e.g. error
messages to stdout if --help in specified, so $ foo --help | less has
the desired results)

The wrapping has the following effects:

=over
=item *
If any args are passed to main::help, STDERR will be selected
before your sub is called, the args will be printed after your sub is
called, and the program will exit 1.

=item *
If no args are passed to main::help, STDOUT will be selected
before your sub is called, and the program will exit 0.

=back

=head2 VERSION

If you define a main::version() sub, it will be called if the
user specified --version, and the program will terminate.

STDOUT will always be selected.

=cut

package Getopt::WonderBra;
use strict;
our($VERSION)="1.02";


use strict;
use Carp;
use Carp qw(confess);
sub import {
	*{main::getopt}=\&getopt;
};
our (%switches, @arg, @noarg, $res);
my $mainhelp;
my $mainver;
sub version {
	select STDERR if ( @_ );
	$mainver->();
	if ( @_ ) {
		print "\n ERROR: @_\n";
	};
	exit @_ != 0;
};
sub help { 
	select STDERR if ( @_ );
	$mainhelp->(@_);
	if ( @_ ) {
		print "\n ERROR: @_\n";
	};
	exit @_ != 0;
};
sub rep_funcs {
	die "missing main::help" unless exists &main::help;
	die "missing main::version" unless exists &main::version;
	unless (defined($mainhelp)){
		$mainhelp = \&main::help;
		no warnings 'redefine';
		*main::help=\&Getopt::WonderBra::help;
	};
	unless (defined($mainver)){
		$mainver = \&main::version;
		no warnings 'redefine';
		*main::version=\&Getopt::WonderBra::version;
	};
};
sub parsefmt($){
	local $_ = shift;
	while(length) {
		my ($switch,$colons);
		($switch,$colons,$_) = m/^(.)(:?:?)(.*)/;
		confess "no optional args" if ( $colons eq '::' );
		confess ": is not a legal switch" if ( $switch eq ':' );
		confess "$switch repeated" if ( $switches{$switch} );
		if ( $colons ) {
			push(@arg, $switch);
			$switches{$switch}='arg';
		} else {
			push(@noarg, $switch);
			$switches{$switch}='noarg';
		};
	}
	$switches{'-'} = 'arg' if defined $switches{'-'};
}

sub singleopt($\@){
	my $text = 'single: "'.join('","',@{$_[$#_]}).'"';
	local $_ = shift;
	my $arg = shift;
	my ($s, @res,$t);
	while(length) {
		( $s, $_ ) = m/^(.)(.*)/;
		if ( !exists $switches{$s} ) {
			help("illegal switch: $s (part of $s$_)");
		}
		my $type = $switches{$s};
		push(@res,"-$s");
		if ( $type eq 'noarg' )	{
			next;
		} elsif ( $type eq 'arg' ) {
			if ( length )			{ push(@res, $_);last; }
			if ( @$arg )			{ push(@res, shift @$arg);last; }
			help("switch $s missing required arg");
		} else {
			confess "Internal Error: $type";
		};
	}
	return ( @res );
};
sub doubleopt($\@){
	return help()			if $_[0] eq 'help';
	return version()		if $_[0] eq 'version';
	return "--".$_[0];
}

sub getopt($\@) {
	rep_funcs;
	my ($opts,$args) = @_;
	confess "Internal Error: Missing switch specifiers" unless @_;
	parsefmt($opts);
	local *_ = $args;
	my @nonopts;
	my @opts;
	while(@_) {
		confess "undef amongst the args?" unless defined($_ = shift);
		if 		( !s/^-// ) 		{ push(@nonopts,$_); next; }
		if		( !length )			{ push(@nonopts,'-'); next; }
		if		( !s/^-// ) 		{ push(@opts,singleopt $_, @_);next; }
		if		( length )			{ push(@opts,doubleopt $_, @_);next; }
		last;
	};
	return @opts, '--', @nonopts, @_;
}
1;

