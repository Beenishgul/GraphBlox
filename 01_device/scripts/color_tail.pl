#!/usr/bin/perl -w

while(<STDIN>) {
    my $line = $_;
    chomp($line);
    for($line){
        s/==>.*<==/\e[1;44m$&\e[0m/gi;   #tail multiples files name in blue background
        s/ERROR:.*/\e[0;31m$&\e[0m/gi;   #java errors & stacktraces in red
        s/INFO:.*/\e[1;32m$&\e[0m/gi;    #info replacement in green
        s/WARNING:.*/\e[1;33m$&\e[0m/gi; #warning replacement in yellow
        s/Reports:.*/\e[1;34m$&\e[0m/gi; #warning replacement in blue
        s/Time \(s\):.*/\e[0;31m$&\e[0m/gi;#java errors & stacktraces in red
        s/Run vpl:.*/\e[0;35m$&\e[0m/gi; #java errors & stacktraces in red
        s/Log files::.*/\e[0;35m$&\e[0m/gi; #java errors & stacktraces in red
    }
    print $line, "\n";
}