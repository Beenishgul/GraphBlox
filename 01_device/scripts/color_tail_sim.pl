#!/usr/bin/perl -w

use IO::Handle qw( );
use Term::ANSIColor qw(:constants);
use Text::Wrap;
use Cwd qw();
$Text::Wrap::columns = 72;

$time_flag     = 0;
@error_array   = ();
@warning_array = ();
$datestring    = localtime();
$step_cnt      = 0;

$reports_file = "Reports:Dir";
$log_file = "Reports:Dir";
$guidance_file = "Reports:Dir";
$steps_file = "Reports:Dir";

$| = 1; # unbuffer output

$spinner = 0;
@spinState = ("-", "\\", "|", "/");

sub status()
{
    for (my $x = 0; $x <= 100; ++$x){
     $spinner = ($spinner + 1) % 4;
     print "\b"; sleep 0.2; print "$spinState[$spinner]";
 }
}

# Time (s): cpu = 00:00:00 ; elapsed = 00:00:00 . Memory (MB): peak = 469.250 ; gain = 0.000 ; free physical = 49860 ; free virtual = 115857

sub sub_print_time {
 my $line = $_;
 $time_flag = 1;

 my @fields_t = split ';', $line;
   # my @fields_t2 = split ':', @fields_i2[0];
   
   print ' ' x 24;
   print "[", CYAN, "TIME" , RESET, "] "; 
   # print GREEN, $fields_t[0] , RESET," "; 
   print GREEN, $fields_t[0] , RESET,"\n"; 
   # print GREEN, @fields_i2[1] , RESET;   
}

sub sub_print_error {

 my $line = $_;
 push(@error_array, $line);
 $time_flag = 0;
 my @fields_i2 = split ':', $line;
 my @fields_i = split '/', $line;

 print ' ' x 24;
 print "[", RED, $fields_i2[0], RESET, "] "; 
 shift(@fields_i2);
 # print MAGENTA, join("\n                                ",@fields_i2), RESET; 
 # print MAGENTA, wrap('', ' ' x 24, @fields_i2), RESET;
 print MAGENTA, wrap('', ' ' x 24, join("\n", @fields_i2)), RESET; 

 sub_print_close($line);
}

sub sub_print_warning {
 my $line = $_;

   # print "\n", YELLOW, $line, RESET;  
   $time_flag = 1;
   push(@warning_array, $line);
}

sub sub_print_progress {
 my $line = $_;
   # status()
   print RED, ">", RESET;
}

sub sub_print_progress_s {
 my $line = $_;

   # print RED, "*", RESET;
}

sub sub_print_step {
 my $line = $_;
 $step_cnt++;

 print ' ' x 16;
 print YELLOW,"Step ", $step_cnt, ": ";
 print $line, RESET;  
 $time_flag = 0;
}

sub sub_print_close {
 my $line = $_;
 $step_cnt++;

 print ' ' x 16;
 print YELLOW,"Step ", $step_cnt, ": ";
 print $line, RESET;  
 $time_flag = 0;

 my $path = Cwd::cwd();
 my @fields_r = split ':', $reports_file;
 my @fields_l = split ':', $log_file;
 my @fields_g = split ':', $guidance_file;
 my @fields_s = split ':', $steps_file;

 print "\n", "=========================================================", "\n";
 print "[", BLUE, "Running Simulation", RESET, "]";
 print RED, " DONE!", RESET, "\n";
 print "=========================================================", "\n";
 print "[", GREEN, "$datestring",RESET,"\n";
 print "=========================================================", "\n";
 print "[", BLUE, "Number of warning...", RESET, "] ";
 print  YELLOW, scalar(@warning_array), RESET, "\n";
 print "[", BLUE, "Number of errors...", RESET, "] ";
 print  RED, scalar(@error_array), RESET, "\n";
 print "=========================================================", "\n";
 print "[", BLUE, "Reports..........", RESET, "] ";
 # print  YELLOW, $fields_r[1], RESET, "\n";
 print YELLOW, wrap('', '', $path), RESET, "\n";
 print "=========================================================", "\n";

 exit 0;
}

sub sub_print_info {
 my $line = $_;
 $time_flag = 0;
 my @fields_i2 = split ':', $line;
 my @fields_i = split '/', $fields_i2[1];


 print ' ' x 24;
 print "[", BLUE, $fields_i2[0], RESET, "] "; 
 shift(@fields_i2);
 # print GREEN, @fields_i2, RESET;
 print GREEN, wrap('', ' ' x 32, @fields_i2), RESET;    
 
}

sub sub_print_finished {
 my $line = $_;
 $time_flag = 0;
 my @fields_i2 = split ' ', $line;

 print ' ' x 24;
 print "[", RED, $fields_i2[0], RESET, "] "; 
 shift(@fields_i2);
 # print GREEN, @fields_i2, RESET;
 print GREEN, wrap('', ' ' x 32, @fields_i2), RESET, "\n";    
 
}

sub sub_print_compiling {
 my $line = $_;
 $time_flag = 0;
 my @fields_i2 = split ' ', $line;

 print ' ' x 24;
 print "[", CYAN, "COMPILING", RESET, "] "; 
 shift(@fields_i2);
 # print GREEN, @fields_i2, RESET;
 print GREEN, wrap('', ' ' x 32, @fields_i2), RESET, "\n";    
 
}

sub sub_print_section {
 my $line = $_;
 $time_flag = 0;
 my @fields_i2 = split ':', $line;

 print ' ' x 24;
 print "[", BLUE, "SECTION", RESET, "] "; 
 shift(@fields_i2);
 # print GREEN, @fields_i2, RESET;
 print MAGENTA, wrap('', ' ' x 32, @fields_i2), RESET;    
 
}

sub sub_print_substep {
 my $line = $_;

 print ' ' x 24;
 # print BLUE, $line, RESET;
 print BLUE, wrap('', ' ' x 32, $line), RESET;   
 $time_flag = 0;
}

sub sub_print_vpl {
 my $line = $_;

 my @fields_v3 =  split /[\[\]]/, $line;
 my @fields_v2 =  split ',', $fields_v3[2];

 print ' ' x 24;
 print "[", BLUE, $fields_v3[1], RESET, "] "; 
 # print MAGENTA, join("\n                                   ",@fields_v2), RESET; 
 print MAGENTA, wrap('', ' ' x 36, join("\n", @fields_v2)), RESET; 
 $time_flag = 0;
}

sub sub_print_ns {
 my $line = $_;

 my @fields_v3 =  split ' ', $line;

 print ' ' x 24;
 print "[", BLUE, $fields_v3[0], " ", $fields_v3[1], RESET , "] "; 
 # print MAGENTA, join("\n                                   ",@fields_v2), RESET;
 shift(@fields_v3); 
 shift(@fields_v3);
 print MAGENTA, wrap('', ' ' x 36, @fields_v3), RESET, "\n"; 
 $time_flag = 0;
}

sub sub_print_msg {
 my $line = $_;

 my @fields_v3 =  split ' ', $line;

 print ' ' x 24;
 print "[", BLUE, "MESSAGE ", RESET , "] "; 
 # print MAGENTA, join("\n                                   ",@fields_v2), RESET;
 shift(@fields_v3); 
 print MAGENTA, wrap('', ' ' x 36, @fields_v3), RESET, "\n"; 
 $time_flag = 0;
}


print "\n", "=========================================================", "\n";
print "[", BLUE, "Running Simulation", RESET, "]";
print RED, " START!", RESET, "\n";
print "=========================================================", "\n";
print "[", GREEN, "$datestring",RESET,"]","\n";
print "=========================================================", "\n";

while(<STDIN>) {
    my $line = $_;
    chomp($line);

    for($line){
        s/.*/$&/g;   #vivdo operation in blue
    }

    my @fields_s = split ' ', $line;



    # print "\nline     --> ", $line, "\n";
    # print "fields_s --> ",scalar(@fields_s)," -- ", join('+',@fields_s),"\n";
    # print "=========================================================", "\n";

    my $step_0 = "Running";
    my $step_1 = "Create";
    my $step_2 = "Run";
    my $step_3 = "Creating";
    my $step_4 = "Exiting";
    my $step_5 = "Reports:";
    my $step_6 = "Log";
    my $step_7 = "Guidance:";
    my $step_8 = "Steps";
    my $step_9 = "Section:";
    my $step_10 = "Scanning";
    my $step_11 = "Finished";
    my $step_12 = "Time";
    my $step_13 = "Compiling";
    my $step_14 = "Vivado";
    my $step_15 = "Starting";
    my $step_16 = "Starting:";
    my $step_17 = "MSG:";
    
  
    # my $vpl = \[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\];

        if (@fields_s) {
            if ($fields_s[0] ne "")
            {
                if    ($fields_s[0] =~ /^\*/   )       { }
                elsif ($fields_s[0] =~ /^$step_0$/ )   { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_14$/ )  { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_15$/ )  { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_16$/ )  { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_17$/ )  { sub_print_msg($line);}
                elsif ($fields_s[0] =~ /^$step_1$/ )   { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_2$/ )   { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_3$/ )   { sub_print_step($line);}
                elsif ($line =~ /$step_4/ )            { sub_print_close($line);}
                elsif ($fields_s[0] =~ /^$step_5$/ )   { $reports_file = $line;}
                elsif ($fields_s[0] =~ /^$step_6$/ )   { $log_file = $line;}
                elsif ($fields_s[0] =~ /^$step_7$/ )   { $guidance_file = $line;}
                elsif ($fields_s[0] =~ /^$step_8$/ )   { $steps_file = $line;}
                elsif ($fields_s[0] =~ /^$step_9$/ )   { sub_print_section($line);}
                elsif ($fields_s[0] =~ /^$step_10$/ )  { sub_print_step($line);}
                elsif ($fields_s[0] =~ /^$step_11$/ )  { sub_print_finished($line);}
                elsif ($fields_s[0] =~ /^$step_13$/ )  { sub_print_compiling($line);}
                elsif ($fields_s[0] =~ /^INFO:/   )    { if($time_flag == 1){sub_print_info($line);} }
                elsif ($fields_s[0] =~ /^ERROR:/  )    { sub_print_error ($line);}
                elsif ($fields_s[0] =~ /^WARNING:/)    { sub_print_warning ($line);}
                elsif ($line =~ /$step_12/    )        { sub_print_time ($line);}
                elsif ($fields_s[0] =~ /^\[[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\]$/       )  { sub_print_vpl($line);}
                elsif ($fields_s[0] =~ /^[0-9]/       )  { sub_print_ns($line);}
                else                                 { }       

                 # STDOUT->flush();
             } 
         } 
  
 }


# sub_print_close($line);