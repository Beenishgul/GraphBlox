#!/usr/bin/perl -w

#!/usr/bin/perl -w

while(<STDIN>) {
    my $line = $_;
    chomp($line);

    for($line){
        s/\[.*\]/\e[1;34m$&\e[0m/g;   #vivdo operation in blue
        s/ERROR:/\e[0;31m$&\e[0m/g;   #vivdo errors & stacktraces in red
        s/INFO:/\e[1;32m$&\e[0m/g;    #info replacement in green
        s/WARNING:/\e[1;33m$&\e[0m/g; #warning replacement in yellow
        s/Time \(s\):/\e[0;35m$&\e[0m/g;#vivdo
        s/Run vpl/\e[0;35m$&\e[0m/g;   #vivdo
        s/Creating Vivado project/\e[0;31m$&\e[0m/g;   #vivdo errors & stacktraces in red
        s/Running Dispatch.*/\e[0;31m$&\e[0m/g;   #vivdo errors & stacktraces in red
        s/Closing dispatch client/\e[0;31m$&\e[0m/g;   #vivdo errors & stacktraces in red
        s/Successfully/\e[1;32m$&\e[0m/g;    #info replacement in green
        s/Log files:/\e[0;35m$&\e[0m/g; #vivdo
        s/Reports:/\e[1;35m$&\e[0m/g; #warning replacement in blue
        s/Guidance:/\e[1;35m$&\e[0m/g; #warning replacement in yellow
        s/Steps Log File:/\e[1;35m$&\e[0m/g; #warning replacement in blue
    }

    my @fields = split /[\.\/]/, $line;

    if (@fields) {
        if ($fields[0] ne "")
        {
           print $fields[0], "\n";
        }
    }
   
}