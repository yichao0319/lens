#!/bin/perl

######################################################
## Author: Yi-Chao Chen
## 2013.09.20 @ UT Austin
##
## - Input:
##   1. City:
##      The city used to generate Human TM.
##
## - e.g.
##   perl batch_plot_TM.pl Manhattan
##
######################################################

use strict;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);


#############
## DEBUG
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1;


#############
## Variables
#############
my $input_dir = '../processed_data/subtask_process_4sq/TM';
my $city;
my $file_name;
my %period_max_value = ();


#############
# check input
#############
if(@ARGV != 1) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}
$city = $ARGV[0];
$file_name = "TM_".$city."_period";

#############
## Main starts here
#############
my $cur_period = 1;
my $largest = -1;
my $num_venues = 0;


#############
## get the number of venues
#############
print "get the number of venues\n" if($DEBUG2);
my $cmd = "cat $input_dir/$city\_sorted.txt | wc -l";
$num_venues = `$cmd` + 0;
print "  $num_venues\n";


#############
## start to list files in dir
#############
# print "start to list files in dir: $input_dir\n" if($DEBUG2);
# opendir (DIR, $input_dir) or die $!;
# while (my $file = readdir(DIR)) {
#     if($file =~ /$file_name(\d+)_(\d+).txt/) {
#         print "  $file\n" if($DEBUG1);

#         my $period = $1 + 0;
#         my $cnt = $2 + 0;
#         # print "$file ($period, $cnt)\n";
        

#         #############
#         ## Read the file to get the max value in the matrix
#         #############
#         print "  Read the file to get the max value in the matrix\n" if($DEBUG2);
#         open FH, "$input_dir/$file" or die $!;
#         while(<FH>) {
#             my @tmp = split(/, /, $_);
#             my $cur_max = max(@tmp);

#             # $largest = $cur_max if($cur_max > $largest);
#             $period_max_value{$period} = $cur_max if($period_max_value{$period} < $cur_max);
#         }
#         close FH;
#         print "    ".$period_max_value{$period}."\n" if($DEBUG2);
#     }
# }
# closedir(DIR);


#############
## list files again
#############
print "list files again\n" if($DEBUG2);

opendir (DIR, $input_dir) or die $!;
while (my $file = readdir(DIR)) {
    if($file =~ /$file_name(\d+)_(\d+).txt/) {

        my $period = $1 + 0;
        my $cnt = $2 + 0;


        #####
        ## DEBUG
        $num_venues = 1000;
        if($period == 1) {
            $period_max_value{$period} = 5;
        }
        elsif($period == 5) {
            $period_max_value{$period} = 50;
        }
        elsif($period == 10) {
            $period_max_value{$period} = 100;
        }
        elsif($period == 20) {
            $period_max_value{$period} = 300;
        }
        #####
        

        print "$file ($period, $cnt): ".$period_max_value{$period}."\n" if($DEBUG1);

        my $cmd = "sed 's/XXX/$file_name$period\_$cnt/;s/YYY/".$period_max_value{$period}."/;s/ZZZ/$num_venues/' plot_TM.mother.plot > tmp.plot_TM.plot";
        `$cmd`;

        $cmd = "gnuplot tmp.plot_TM.plot";
        `$cmd`;
    }
}
closedir(DIR);

