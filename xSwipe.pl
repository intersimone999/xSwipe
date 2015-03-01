#!/usr/bin/perl
################################################
 #	#   ####   #	#	 #	#####   ######
  #  #   #	   #	#	 #	#	#  #
   ##	 ####   #	#	 #	#	#  #####
   ##		 #  # ## #	 #	#####   #
  #  #   #	#  ##  ##	 #	#	   #
 #	#   ####   #	#	 #	#	   ######
################################################
use strict;
use Time::HiRes();
use X11::GUITest qw( :ALL );
use FindBin;
#debug
#use Smart::Comments;

my $naturalScroll = 1;
my $baseDist = 0.1;
my $pollingInterval = 10;
my $confFileName = "eventKey.cfg";

while(my $ARGV = shift){
	### $ARGV
	if ($ARGV eq '-n'){
		$naturalScroll = 1;
		print("Deprecated -n option");
	}elsif ($ARGV eq '-d'){
		if ($ARGV[0] > 0){
			$baseDist = $baseDist * $ARGV[0];
			### $baseDist
			shift;
		}else{
			print "Set a value greater than 0\n";
			exit(1);
		}
	}elsif ($ARGV eq '-m'){
		if ($ARGV[0] > 0){
			$pollingInterval = $ARGV[0];
			### $pollingInterval
			shift;
		}else{
			print "Set a value greater than 0\n";
			exit(1);
		}
	}else{
		print "
		Available Options
		-d RATE
			RATE sensitivity to swipe
			RATE > 0, default value is 1
		-m INTERVAL
			INTERVAL how often synclient monitor changes to the touchpad state
			INTERVAL > 0, default value is 10 (ms)
		-n
			Natural Scrolling, like a macbook. setting
			DEPRECATED file path=nScroll/eventKey.cfg
		\n";
		exit(1);
	}
}
# add syndaemon setting
system("syndaemon -m 10 -i 0.5 -K -t -d &");

open (Scroll_setting, "synclient -l | grep ScrollDelta | grep -v -e Circ | ")or die "can't synclient -l";
my @Scroll_setting = <Scroll_setting>;
close(fileHundle);

my $VertScrollDelta  = abs((split "= ", $Scroll_setting[0])[1]);
my $HorizScrollDelta = abs((split "= ", $Scroll_setting[1])[1]);

&initSynclient($naturalScroll);

open (area_setting, "synclient -l | grep Edge | grep -v -e Area -e Motion -e Scroll | ")or die "can't synclient -l";
my @area_setting = <area_setting>;
close(fileHundle);

my $LeftEdge   = (split "= ", $area_setting[0])[1];
my $RightEdge  = (split "= ", $area_setting[1])[1];
my $TopEdge	= (split "= ", $area_setting[2])[1];
my $BottomEdge = (split "= ", $area_setting[3])[1];

my $TouchpadSizeH = abs($TopEdge - $BottomEdge);
my $TouchpadSizeW = abs($LeftEdge - $RightEdge);
my $centerTouchPad = 3000;
# todo:タッチパッドの比率^2でMinThresholdを決定してもいいかも
my $xMinThreshold = $TouchpadSizeW * $baseDist;
my $yMinThreshold = $TouchpadSizeH * $baseDist;
# todo: エリア取得方法の見直し。場合によっては外部ファイル化やキャリブレーションを検討
my $innerEdgeLeft   = $LeftEdge   + $xMinThreshold/2;
my $innerEdgeRight  = $RightEdge  - $xMinThreshold/2;
my $innerEdgeTop	= $TopEdge	+ $yMinThreshold;
my $innerEdgeBottom = $BottomEdge - $yMinThreshold;

### @area_setting
### $TouchpadSizeH
### $TouchpadSizeW
### $xMinThreshold
### $yMinThreshold
### $innerEdgeLeft
### $innerEdgeRight
### $innerEdgeTop
### $innerEdgeBottom

#load config
my $script_dir = $FindBin::Bin;#CurrentPath
my $conf = require $script_dir."/".$confFileName;
my $swipeName = 'swipe';
my $moveName = 'move';
my $pinchName = 'pinch';

### Loads the combinations for each gesture
#Swipe gestures
my @swipe3Right = split "/", ($conf->{$swipeName}->{swipe3}->{right});
my @swipe3Left  = split "/", ($conf->{$swipeName}->{swipe3}->{left});
my @swipe3Down  = split "/", ($conf->{$swipeName}->{swipe3}->{down});
my @swipe3Up	= split "/", ($conf->{$swipeName}->{swipe3}->{up});

my @swipe4Right = split "/", ($conf->{$swipeName}->{swipe4}->{right});
my @swipe4Left  = split "/", ($conf->{$swipeName}->{swipe4}->{left});
my @swipe4Down  = split "/", ($conf->{$swipeName}->{swipe4}->{down});
my @swipe4Up	= split "/", ($conf->{$swipeName}->{swipe4}->{up});

my @swipe5Right = split "/", ($conf->{$swipeName}->{swipe5}->{right});
my @swipe5Left  = split "/", ($conf->{$swipeName}->{swipe5}->{left});
my @swipe5Down  = split "/", ($conf->{$swipeName}->{swipe5}->{down});
my @swipe5Up	= split "/", ($conf->{$swipeName}->{swipe5}->{up});

my @edgeSwipe1Right = split "/", ($conf->{$swipeName}->{edgeSwipe1}->{right});
my @edgeSwipe1Left  = split "/", ($conf->{$swipeName}->{edgeSwipe1}->{left});
my @edgeSwipe2Right = split "/", ($conf->{$swipeName}->{edgeSwipe2}->{right});
my @edgeSwipe2Left  = split "/", ($conf->{$swipeName}->{edgeSwipe2}->{left});
my @edgeSwipe3Down  = split "/", ($conf->{$swipeName}->{edgeSwipe3}->{down});
my @edgeSwipe3Up	= split "/", ($conf->{$swipeName}->{edgeSwipe3}->{up});
my @edgeSwipe4Down  = split "/", ($conf->{$swipeName}->{edgeSwipe4}->{down});
my @edgeSwipe4Up	= split "/", ($conf->{$swipeName}->{edgeSwipe4}->{up});
my @longPress2 = split "/", ($conf->{$swipeName}->{swipe2}->{press});
my @longPress3 = split "/", ($conf->{$swipeName}->{swipe3}->{press});
my @longPress4 = split "/", ($conf->{$swipeName}->{swipe4}->{press});
my @longPress5 = split "/", ($conf->{$swipeName}->{swipe5}->{press});

#Move gestures
my $moveCombo = $conf->{$moveName}->{key};
my $moveFingers = $conf->{$moveName}->{fingers};

#Pinch gestures
my @pinchIn = split "/", ($conf->{$pinchName}->{in});
my @pinchOut = split "/", ($conf->{$pinchName}->{out});
my $openSt		= 1000;	# start of open pinch
my $openEn		= 500;	 # end of open pinch
my $closeSt		= 1000;	# start of close pinch
my $closeEn		= 1000;	# end of close pinch

my @xHist1 = ();				# x coordinate history (1 finger)
my @yHist1 = ();				# y coordinate history (1 finger)
my @xHist2 = ();				# x coordinate history (2 fingers)
my @yHist2 = ();				# y coordinate history (2 fingers)
my @xHist3 = ();				# x coordinate history (3 fingers)
my @yHist3 = ();				# y coordinate history (3 fingers)
my @xHist4 = ();				# x coordinate history (4 fingers)
my @yHist4 = ();				# y coordinate history (4 fingers)
my @xHist5 = ();				# x coordinate history (5 fingers)
my @yHist5 = ();				# y coordinate history (5 fingers)

my $axis = 0;
my $rate = 0;
my $touchState = 0;			 # touchState={0/1/2} 0=notSwiping, 1=Swiping, 2=edgeSwiping
my $lastTime = 0;			   # time monitor for TouchPad event reset
my $eventTime = 0;			  # ensure enough time has passed between events
my @eventString = ("default");  # the event to execute

my $currWind = GetInputFocus();
my $oneTimeCombination = 0;	 # one time combination (for those combinations which need single press) is disabled
my $movingWindow = 0;

my $onetime = 0;
my $move = 0;
my $mouseRelX = 0;
my $mouseRelY = 0;

die "couldn't get input window" unless $currWind;
open(INFILE,"synclient -m $pollingInterval |") or die "can't read from synclient";

while(my $line = <INFILE>){
	chomp($line);
	my($time, $x, $y, $z, $f, $w, $click) = split " ", $line;
	next if($time =~ /time/); #ignore header lines
	if($time - $lastTime > 5){
		&initSynclient($naturalScroll);
	}#if time reset
	$lastTime = $time;
	$axis = 0;
	$rate = 0;
	if($f == 1){
		if($touchState == 0){
			if(($x < $innerEdgeLeft)or($innerEdgeRight < $x)){
				$touchState = 2;
		} else {
				$touchState = 1;
			}
		}
		cleanHist(2 ,3 ,4 ,5);
		if ($touchState == 2){
			push @xHist1, $x;
			push @yHist1, $y;
			$axis = getAxis(\@xHist1, \@yHist1, 2, 0.1);
			if($axis eq "x"){
				$rate = getRate(@xHist1);
				$touchState = 2;
			}elsif($axis eq "y"){
				$rate = getRate(@yHist1);
				$touchState = 2;
			}
		}

	}elsif($f == 2){
		if($touchState == 0){
			if(
				($x < $innerEdgeLeft) or ($innerEdgeRight  < $x)
		   # or ($y < $innerEdgeTop ) or ($innerEdgeBottom < $y)
			){
				$touchState = 2;
				### $touchState
			}else{
				$touchState = 1;
			}
		}
		cleanHist(1, 3, 4, 5);
		push @xHist2, $x;
		push @yHist2, $y;
		$axis = getAxis(\@xHist2, \@yHist2, 2, 0.1);
		if($axis eq "x"){
			$rate = getRate(@xHist2);
		}elsif($axis eq "y"){
			$rate = getRate(@yHist2);
		}elsif($axis eq "z"){
			$axis = getAxis(\@xHist2, \@yHist2, 30, 0.5);
			if($axis eq "z"){
			}
		}

	}elsif($f == 3){
		if($touchState == 0 ){
			if(($y < $innerEdgeTop)or($innerEdgeBottom < $y)){
				$touchState = 2;
				### $touchState
			}else{
				$touchState = 1;
			}
		}
		cleanHist(1, 2, 4, 5);
		push @xHist3, $x;
		push @yHist3, $y;
		$axis = getAxis(\@xHist3, \@yHist3, 5, 0.5);
		if($axis eq "x"){
			$rate = getRate(@xHist3);
		}elsif($axis eq "y"){
			$rate = getRate(@yHist3);
		}elsif($axis eq "z"){
			$axis = getAxis(\@xHist3, \@yHist3, 30, 0.5);
			if($axis eq "z"){
			}
		}

	}elsif($f == 4){
		if($touchState == 0 ){
			if(($y < $innerEdgeTop)or($innerEdgeBottom < $y)){
				$touchState = 2;
				### $touchState
			}else{
				$touchState = 1;
			}
		}
		cleanHist(1, 2, 3, 5);
		push @xHist4, $x;
		push @yHist4, $y;
		$axis = getAxis(\@xHist4, \@yHist4, 5, 0.5);
		if($axis eq "x"){
			$rate = getRate(@xHist4);
		}elsif($axis eq "y"){
			$rate = getRate(@yHist4);
		}elsif($axis eq "z"){
			$axis = getAxis(\@xHist4, \@yHist4, 30, 0.5);
			if($axis eq "z"){
			}
		}

	}elsif($f == 5){
		if($touchState == 0 ){
			if(($y < $innerEdgeTop)or($innerEdgeBottom < $y)){
				$touchState = 2;
				### $touchState
			}else{
				$touchState = 1;
			}
		}
		cleanHist(1, 2, 3 ,4);
		push @xHist5, $x;
		push @yHist5, $y;
		$axis = getAxis(\@xHist5, \@yHist5, 5, 0.5);
		if($axis eq "x"){
			$rate = getRate(@xHist5);
		}elsif($axis eq "y"){
			$rate = getRate(@yHist5);
		}
	}else{
		cleanHist(1, 2, 3, 4, 5);
		if($touchState > 0){
			$touchState = 0; #touchState Reset
			#&switchTouchPad("On");
		}
		$oneTimeCombination = 0;
	}


	#detect actiononetime
	if ($axis ne 0){
		@eventString = setEventString($f,$axis,$rate,$touchState,$click);
		cleanHist(1, 2, 3, 4, 5);
	}

	$onetime = 0;
	if (@eventString > 1) {
		if ($eventString[1] == 'onetime') {
			$onetime = 1;
		}
	}

	# move events
	if ($f eq $moveFingers) {
		PressKey($moveCombo);
		PressMouseButton(M_LEFT);
		$movingWindow = 1;
	} elsif ($movingWindow eq 1 and $f eq 0) {
		$movingWindow = 0;
		ReleaseMouseButton(M_LEFT);
		ReleaseKey($moveCombo);
	}

	# swipe/pinch events
	if ($movingWindow ne 1) {
		if($oneTimeCombination ne 1) {
			if($onetime) {
				$oneTimeCombination = 1;
			}
			if( $eventString[0] ne "default"){
				### ne default
				if( abs($time - $eventTime) > 0.2 ){
					### $time - $eventTime got: $time - $eventTime
					$eventTime = $time;
					SendKeys($eventString[0]);
					### @eventString
				}# if enough time has passed
				@eventString = ("default");
			}#if non default event
		}
	}
}#synclient line in
close(INFILE);

###init
sub initSynclient{
	### initSynclient
	# &switchTouchPad('On');
	my $naturalScroll = 1;
	`synclient VertScrollDelta=-$VertScrollDelta HorizScrollDelta=-$HorizScrollDelta ClickFinger3=1 TapButton3=2`;
}

#sub switchTouchPad{
#	open(TOUCHPADOFF,"synclient -l | grep TouchpadOff |") or die "can't read from synclient";
#	my $TouchpadOff = <TOUCHPADOFF>;
#	close(TOUCHPADOFF);
#	chomp($TouchpadOff);
#	my $TouchpadOff = (split "= ", $TouchpadOff)[1];
#	### $TouchpadOff
#	my $switch_flag = shift;
#	### $switch_flag
#	if($switch_flag eq 'Off'){
#		if($TouchpadOff eq '0'){
#			`synclient TouchpadOff=1`;
#		}
#	}elsif($switch_flag eq 'On'){
#		if($TouchpadOff ne '0' ){
#			`synclient TouchpadOff=0`;
#		}
#	}
#}



sub getAxis{
	my($xHist, $yHist, $max, $thresholdRate)=@_;
	if(@$xHist > $max or @$yHist > $max){
		my $x0 = @$xHist[0];
		my $y0 = @$yHist[0];
		my $xmax = @$xHist[$max];
		my $ymax = @$yHist[$max];
		my $xDist = abs( $x0 - $xmax );
		my $yDist = abs( $y0 - $ymax );
		if($xDist > $yDist){
			if($xDist > $xMinThreshold * $thresholdRate){
				return "x";
			}else{
				return "z";
			}
		}else{
			if($yDist > $yMinThreshold * $thresholdRate){
				return "y";
			}else{
				return "z";
			}
		}
	}
	return 0;
}

sub getRate{
	my @hist = @_;
	my @srt	= sort {$a <=> $b} @hist;
	my @revSrt = sort {$b <=> $a} @hist;
	if( "@srt" eq "@hist" ){
		return "+";
	}elsif( "@revSrt" eq "@hist" ){
		return "-";
	}#if forward or backward
	return 0;
}

sub cleanHist{
	while(my $arg = shift){
		if($arg == 1){
			@xHist1 = ();
			@yHist1 = ();
		}elsif($arg == 2){
			@xHist2 = ();
			@yHist2 = ();
		}elsif($arg == 3){
			@xHist3 = ();
			@yHist3 = ();
		}elsif($arg == 4){
			@xHist4 = ();
			@yHist4 = ();
		}elsif($arg == 5){
			@xHist5 = ();
			@yHist5 = ();
		}
	}
}

#return @eventString $_[0]
sub setEventString{
	my($f, $axis, $rate, $touchState, $click)=@_;
	if($f == 1){
		if($axis eq "x"){
			if($rate eq "+"){
				if($touchState eq "2"){
					return @edgeSwipe1Right;
				}
			}elsif($rate eq "-"){
				if($touchState eq "2"){
					return @edgeSwipe1Left;
				}
			}
		}
	}elsif($f == 2){
		if($axis eq "x"){
			if($rate eq "+"){
				if($touchState eq "2"){
					return @edgeSwipe2Right;
				}
			}elsif($rate eq "-"){
				if($touchState eq "2"){
					return @edgeSwipe2Left;
				}
			}
		}elsif($axis eq "z"){
			if($rate eq "0"){
				if($touchState eq "1"){
					return @longPress2;
				}
			}
		}

		if($click eq "1") {
			return @longPress2;
		}
	}elsif($f == 3){
		if($axis eq "x"){
			if($rate eq "+"){
				return @swipe3Right;
			}elsif($rate eq "-"){
				return @swipe3Left;
			}
		}elsif($axis eq "y"){
			if($rate eq "+"){
				if($touchState eq "2"){
					return @edgeSwipe3Down;
				}
				return @swipe3Down;
			}elsif($rate eq "-"){
				if($touchState eq "2"){
					return @edgeSwipe3Up;
				}
				return @swipe3Up;
			}
		}elsif($axis eq "z"){
			if($rate eq "0"){
				return @longPress3;
			}
		}

		if($click eq "1") {
			return @longPress3;
		}
	}elsif($f == 4){
		if($axis eq "x"){
			if($rate eq "+"){
				return @swipe4Right;
			}elsif($rate eq "-"){
				return @swipe4Left;
			}
		}elsif($axis eq "y"){
			if($rate eq "+"){
				if($touchState eq "2"){
					return @edgeSwipe4Down;
				}
				return @swipe4Down;
			}elsif($rate eq "-"){
				if($touchState eq "2"){
					return @edgeSwipe4Up;
				}
				return @swipe4Up;
			}
		}elsif($axis eq "z"){
			if($rate eq "0"){
				return @longPress4;
			}
		}

		if($click eq "1") {
			return @longPress4;
		}
	}elsif($f == 5){
		if($axis eq "x"){
			if($rate eq "+"){
				return @swipe5Right;
			}elsif($rate eq "-"){
				return @swipe5Left;
			}
		}elsif($axis eq "y"){
			if($rate eq "+"){
				return @swipe5Down;
			}elsif($rate eq "-"){
				return @swipe5Up;
			}
		}elsif($axis eq "z"){
			if($rate eq "0"){
				return @longPress5;
			}
		}

		if($click eq "1") {
			return @longPress4;
		}
	}

	return "default";
}
