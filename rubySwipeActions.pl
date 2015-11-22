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
	} elsif ($kind eq "PressMouseButton") {
		if ($action eq "MLEFT") {
			PressMouseButton(M_LEFT);
		} elsif ($action eq "MRIGHT") {
			PressMouseButton(M_RIGHT);
		} elsif ($action eq "MCENTER") {
			PressMouseButton(M_MIDDLE);
		}
	} elsif ($kind eq "ReleaseMouseButton") {
		if ($action eq "MLEFT") {
			ReleaseMouseButton(M_LEFT);
		} elsif ($action eq "MRIGHT") {
			ReleaseMouseButton(M_RIGHT);
		} elsif ($action eq "MCENTER") {
			ReleaseMouseButton(M_MIDDLE);
		}
	}
}
