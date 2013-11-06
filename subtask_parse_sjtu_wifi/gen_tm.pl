#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##   1. ip_map_fullpath
##      the file that maps IP to matrix index
##   2. period
##      period of each frame
##
## - output:
##
## - e.g.
##   perl gen_tm.pl ../processed_data/subtask_parse_sjtu_wifi/sort_ips/sort_ips.ap.country.txt 3600
##
##########################################

use strict;

use lib "../utils";

use MyUtil;


#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output
my $DEBUG4 = 0;
my $DEBUG5 = 1;


#############
# Constants
#############


#############
# Variables
#############
my $input_trace_dir = "../processed_data/subtask_parse_sjtu_wifi/text";
my $output_dir      = "../processed_data/subtask_parse_sjtu_wifi/tm";

my $ip_map_fullpath;
my $period;

my $input_map_dir;
my $ip_map_file;

my %ip_map = ();
my %tm = ();  ## Dim1 - Dim2 - value
my $sx = 0;   ## number of ips
my $set_period_dt = 1;
my $period_end_dt = -1;
my $frame = 0;

my $total_bytes = 0;
my $missing_bytes = 0;


#############
# check input
#############
if(@ARGV != 2) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$ip_map_fullpath = $ARGV[0];
if($ip_map_fullpath =~ /^(.*)\/(.*)$/) {
    $input_map_dir = $1;
    $ip_map_file = $2;
}
$period = $ARGV[1] + 0;

if($DEBUG2) {
    print "ip map dir: $input_map_dir\n";
    print "ip map file: $ip_map_file\n";
    print "period: $period\n";
}


#############
# Main starts
#############

#############
## read the mapping
#############
print "read the mapping\n" if($DEBUG2);

open FH, "$ip_map_fullpath" or die $!;
while(<FH>) {
    chomp;

    my ($ip, $index) = split(/, /, $_);
    die "wrong format: $_\n  $ip => $index\n" unless($ip =~ /^\d+\.\d+\.\d+\.\d+$/);
    $index += 0;
    print "  $ip => $index\n" if($DEBUG0);

    $ip_map{$ip} = $index;
    $sx = $index if($index > $sx);
}
close FH;


#############
## for each file, get IP info
#############
print "read the trace in bz2: $input_trace_dir\n" if($DEBUG2);

my @files = ();
opendir(DIR, "$input_trace_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_trace_dir/$file");  ## don't show directories
    next unless($file =~ /bz2$/);

    push(@files, $file);
}

## XXX: fix the order of file ....
for my $file (sort {$a cmp $b} @files) {
    print "  $input_trace_dir/$file\n" if($DEBUG2);


    #############
    ## parse the file
    #############
    print "  parse the file\n" if($DEBUG2);

    open FH, "bzcat \"$input_trace_dir/$file\" |" or die $!;
    while(<FH>) {
        chomp;
        my ($ind, $time, $mac_src, $mac_dst, $len, $src, $dst) = split(/\|/, $_);

        #############
        ## parse time
        #############
        print "\n    - TIME: $time\n" if($DEBUG4);
        my $this_time;
        if($time =~ /(\w*)\s+(\d+),\s+(\d+)\s+(\d+):(\d+):(\d+)\.(\d+)/) {
            my $tmp = $1;
            my $mon;
            my $day = $2 + 0;
            my $year = $3 + 0;
            my $hour = $4 + 0;
            my $min = $5 + 0;
            my $sec = $6 + 0 + $7 / 1000000000;

            if($tmp eq "Jan") { $mon = 1; }
            elsif($tmp eq "Feb") { $mon = 2; }
            elsif($tmp eq "Mar") { $mon = 3; }
            elsif($tmp eq "Apr") { $mon = 4; }
            elsif($tmp eq "May") { $mon = 5; }
            elsif($tmp eq "Jan") { $mon = 6; }
            elsif($tmp eq "Jul") { $mon = 7; }
            elsif($tmp eq "Aug") { $mon = 8; }
            elsif($tmp eq "Sep") { $mon = 9; }
            elsif($tmp eq "Oct") { $mon = 10; }
            elsif($tmp eq "Nov") { $mon = 11; }
            elsif($tmp eq "Dec") { $mon = 12; }
            else { die "wrong month: $tmp\n"; }

            # $this_time = (((($year * 12 + $mon) * 31 + $day) * 24 + $hour) * 60 + $min) * 60 + $sec;
            $this_time = MyUtil::to_seconds($year, $mon, $day, $hour, $min, $sec);
            print "      = ".join("|", ($year, $mon, $day, $hour, $min, $sec))."\n" if($DEBUG4);
            print "      = $this_time\n" if($DEBUG4);
        }
        else {
            die "wrong time format: $time\n";
        }


        if($set_period_dt == 1) {
            $set_period_dt = 0;

            $period_end_dt = $this_time;
            print "      start time = $period_end_dt\n" if($DEBUG5);
            
            $period_end_dt += $period;
            print "      end time   = $period_end_dt\n" if($DEBUG5);
        }

        while($this_time > $period_end_dt) {
            write_tm("$output_dir/tm.$ip_map_file.$period.$frame.txt", \%tm, $sx);
            $frame ++;
            %tm = ();
            
            print "\n      start time = $period_end_dt\n" if($DEBUG5);
            $period_end_dt += $period;
            print "      end time   = $period_end_dt\n" if($DEBUG5);
        }
        


        #############
        ## parse len
        #############
        $len += 0;
        $total_bytes += $len;
        print "    - LEN: $len\n" if($DEBUG4);


        #############
        ## parse src
        #############
        print "    - SRC: $src\n" if($DEBUG4);
        my $valid = 0;
        my $src_ip;
        my @srcs = split(/,/, $src);
        foreach my $this_src (@srcs) {
            next unless(exists $ip_map{$this_src});
            
            $valid = 1;
            $src_ip = $this_src;
            print "      = $this_src -> ".$ip_map{$this_src}."\n" if($DEBUG4);
            last;
        }
        unless($valid) {
            $missing_bytes += $len;
            next;
        }


        #############
        ## parse dst
        #############
        print "    - DST: $dst\n" if($DEBUG4);
        my $dst_ip;
        $valid = 0;
        my @dsts = split(/,/, $dst);
        foreach my $this_dst (@dsts) {
            next unless(exists $ip_map{$this_dst});

            $valid = 1;
            $dst_ip = $this_dst;
            print "      = $this_dst -> ".$ip_map{$this_dst}."\n" if($DEBUG4);
            last;
        }
        unless($valid) {
            $missing_bytes += $len;
            next;
        }


        ## update Traffic Matrix
        $tm{SRC}{$ip_map{$src_ip}}{DST}{$ip_map{$dst_ip}}{VALUE} += $len;
    }
    close FH;
}
write_tm("$output_dir/tm.$ip_map_file.$period.$frame.txt", \%tm, $sx);
$frame ++;

print "total bytes = $total_bytes\n";
print "skip bytes = $missing_bytes\n";

1;



sub write_tm {
    my ($output_fullpath, $tm_ref, $sx) = @_;

    open FH_OUT, "> $output_fullpath" or die $!;
    for my $i (1 .. $sx) {
        for my $j (1 .. $sx) {
            print FH_OUT ", " if($j != 1);
            if(!(exists $tm_ref->{SRC}{$i}) or !(exists $tm_ref->{SRC}{$i}{DST}{$j})) {
                print FH_OUT "0";
            }
            else {
                print FH_OUT $tm_ref->{SRC}{$i}{DST}{$j}{VALUE};
            }
        }
        print FH_OUT "\n";
    }
    close FH_OUT;
}