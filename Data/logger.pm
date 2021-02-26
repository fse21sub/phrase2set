#!/usr/bin/perl

package logger;

use warnings;
use strict;

sub log_value($){
	print_to_console(@_);
}

sub print_to_console($){
	my $self = shift;
	my ($text) = @_;

	print $text;
}

1;
