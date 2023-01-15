#!/usr/bin/perl -w

use IO::Handle qw( );
use Term::ANSIColor qw(:constants);

$progress_flag = 0;
$time_flag = 0;

while(<STDIN>) {
    my $line = $_;
    chomp($line);

    for($line){
        s/.*/$&/g;   #vivdo operation in blue
    }

    my @fields_s = split ' ', $line;

    my $step_0 = "Running";
    my $step_1 = "Create";
    my $step_2 = "Run";
    my $step_3 = "Creating";
    my $step_4 = "Closing";
    my $step_5 = "\tReports:";
    my $step_6 = "\tLog";
    my $step_7 = "\tGuidance:";
    my $step_8 = "\tSteps";
    my $vpl = /^(\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9])\]/;

    if($progress_flag == 0){
        print "\n";
    } 

    if($time_flag == 1){
       print "\n", BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;
    } else {

        if (@fields_s) {
            if ($fields_s[0] ne "")
            {
                if    ($fields_s[0] =~ /^INFO:/   )  { print BRIGHT_RED, "=", RESET; $progress_flag = 1;}
                elsif ($fields_s[0] =~ /^ERROR:/  )  { print "\n", RED, $line, RESET; $progress_flag  = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^WARNING:/)  { print "\n", YELLOW, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^Time/    )  { print "\n", GREEN, $line, RESET;  $progress_flag = 0; $time_flag = 1;}
                elsif ($fields_s[0] =~ $vpl       )  { print BRIGHT_RED, "=", RESET; $progress_flag = 1;}
                elsif ($fields_s[0] =~ /^$step_0/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_1/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_2/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_3/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_4/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_5/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_6/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_7/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                elsif ($fields_s[0] =~ /^$step_8/ )  { print "\n", BRIGHT_BLUE, $line, RESET;  $progress_flag = 0; $time_flag = 0;}
                else                                 { print "";}
            } 
        } 

    }

    STDOUT->flush();
    
}

