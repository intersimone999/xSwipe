#!/usr/bin/perl
######################################################################
#   #      #  #   #          #####  #           #   #  ####   #####  #
#   #      #   # #          #        #   # #   #    #  #   #  #      #
#   #      #    #     ###    ####     #   #   #     #  ####   ###    #
#    #    #    # #               #     # # # #      #  #      #      #
#      ##     #   #         #####       #   #       #  #      #####  #
######################################################################
use strict;
use Time::HiRes();
use X11::GUITest qw( :ALL );

while (<>) {
	chomp($_);
	my ($kind, $action) = split "/", $_;

	if ($kind eq "SendKeys") {
		SendKeys($action);
	} elsif ($kind eq "PressKey") {
		PressKey($action);
	} elsif ($kind eq "ReleaseKey") {
		ReleaseKey($action);
	}
}
