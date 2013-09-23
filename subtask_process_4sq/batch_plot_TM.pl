#!/bin/perl

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);

my $input_dir = '../processed_data/subtask_process_4sq';

my $cur_period = 1;
my $largest = -1;
my %period_max_value = ();
opendir (DIR, $input_dir) or die $!;
while (my $file = readdir(DIR)) {
    if($file =~ /TM_period(\d+)_(\d+).txt/) {
        my $period = $1 + 0;
        my $cnt = $2 + 0;
        # print "$file ($period, $cnt)\n";
        
        open FH, "$input_dir/$file" or die $!;
        while(<FH>) {
            my @tmp = split(/, /, $_);
            my $cur_max = max(@tmp);

            # $largest = $cur_max if($cur_max > $largest);
            $period_max_value{$period} = $cur_max if($period_max_value{$period} < $cur_max);
        }
        close FH;
    }
}
closedir(DIR);

opendir (DIR, $input_dir) or die $!;
while (my $file = readdir(DIR)) {
    if($file =~ /TM_period(\d+)_(\d+).txt/) {
        my $period = $1 + 0;
        my $cnt = $2 + 0;
        print "$file ($period, $cnt): ".$period_max_value{$period}."\n";

        my $cmd = "sed 's/XXX/TM_period$period\_$cnt/;s/YYY/".$period_max_value{$period}."/' plot_TM.mother.plot > plot_TM.plot";
        `$cmd`;

        $cmd = "gnuplot plot_TM.plot";
        `$cmd`;
    }
}
closedir(DIR);

