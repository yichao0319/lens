#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.09.27 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##
##########################################

use strict;

use lib "/u/yichao/anomaly_compression/utils";
use MyUtil;

#############
# Debug
#############
my $DEBUG0 = 0;
my $DEBUG1 = 1;
my $DEBUG2 = 1; ## print progress
my $DEBUG3 = 1; ## print output


#############
# Constants
#############
my $NUM_CURVE = 8;


#############
# Variables
#############
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/figures";
my $gnuplot_mother = "plot.pr";

## data - TRACE - OPT_DECT - OPT_DELTA - BLOCK_SIZE - THRESH - [TP, TN, FP, TN, ...]
my %data = ();
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [MSE | SETTING | FP | ...]
my %best = ();


#############
# check input
#############
if(@ARGV != 0) {
    print "wrong number of input: ".@ARGV."\n";
    exit;
}


#############
# Main starts
#############
my $func = "srmf_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @seeds;
my @drop_rates;
my @ranks;
my @group_sizes;
my @opt_types;
my @files;

# @files = ("TM_Airport_period5_");
# @files = ("tm.sort_ips.ap.country.txt.3600.", "tm.sort_ips.ap.gps.4.txt.3600.", "tm.select_matrix_for_id-Assignment.txt.60.");
@files = ("tm.sort_ips.ap.gps.1.sub_CN.txt.3600.");

for my $file_name (@files) {    
    
    #######################
    if($file_name eq "TM_Manhattan_period5_") {
        $num_frames = 12;
        $width = 500;
        $height = 500;

        @ranks = (1, 2, 3, 5, 7, 10, 20, 30, 50);
    }
    elsif($file_name eq "TM_Airport_period5_") {
        $num_frames = 12;
        $width = 300;
        $height = 300;

        @ranks = (1, 2, 3, 5, 7, 10, 20, 30, 50);
    }
    #######################
    elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
        $num_frames = 12;
        $width = 28;
        $height = 28;

        @ranks = (1, 2, 3, 5, 7, 10);
    }
    #######################
    elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
        $num_frames = 8;
        $width = 400;
        $height = 400;

        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.5.txt.3600.") {
        $num_frames = 8;
        $width = 738;
        $height = 738;

        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.1.sub_CN.txt.3600.") {
        $num_frames = 8;
        $width = 410;
        $height = 410;

        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.bgp.8.txt.3600.") {
        $num_frames = 8;
        $width = 421;
        $height = 421;

        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600.") {
        $num_frames = 8;
        $width = 403;
        $height = 403;

        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    #######################
    

    @seeds = (1 .. 10);
    @opt_swap_mats = (0, 1, 3);
    @drop_rates = (0.005, 0.01, 0.05);
    @group_sizes = (4);
    @opt_types = (0, 1);


    for my $drop_rate (@drop_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;
            }

            for my $group_size (@group_sizes) {
                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE})) {
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} = -1;
                }
                
                for my $opt_type (@opt_types) {
                    if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE})) {
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} = -1;
                    }

                    for my $rank (@ranks) {
                        if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE})) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MAE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{CC} = -1;
                        }

                        my @mses;
                        my @maes;
                        my @ccs;
                        for my $seed (@seeds) {
                            my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.$rank.$opt_swap_mat.$opt_type.$drop_rate.$seed.txt";
                            die "cannot find the file: $this_file_name\n" unless(-e $this_file_name);

                            print "$this_file_name\n";
                            
                            open FH, $this_file_name or die $!;
                            while(<FH>) {
                                chomp;
                                my @ret = split(/, /, $_);
                                my $mse = $ret[0] + 0;
                                my $mae = $ret[1] + 0;
                                my $cc = $ret[2] + 0;


                                ## XXX: figure out why nan
                                if($mse eq "nan") {
                                    die;
                                    $mse = 0;
                                }
                                if($mae eq "nan") {
                                    die;
                                    $mae = 0;
                                }
                                if($cc eq "nan") {
                                    $cc = 0;
                                }

                                push(@mses, $mse);
                                push(@maes, $mae);
                                push(@ccs, $cc);

                                my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $rank, $opt_type, $drop_rate, $seed, $mse, $mae, $cc\n";
                                print $buf;
                                print FH_OUT $buf;
                            }
                        } ## end seeds

                        my $avg_mse = MyUtil::average(\@mses);
                        my $avg_mae = MyUtil::average(\@maes);
                        my $avg_cc = MyUtil::average(\@ccs);

                        ## MSE
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $avg_mse;
                        }
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE} = $avg_mse;
                        }
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE} = $avg_mse;
                        }
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE} = $avg_mse;
                        }

                        ## MAE
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MAE} = $avg_mae;
                        }

                        ## CC
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{RANK}{$rank}{CC} = $avg_cc;
                        }
                    }  ## end ranks
                }
            }
        }
    }
}
close FH_OUT;



#############
# Statistics
#############
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    foreach my $drop_rate (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE} })) {

        ## MSE
        print "MSE:\n";
        foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT} })) {
            print "$trace (drop $drop_rate), opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}."\n";
        }
        foreach my $group_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE} })) {
            print "$trace (drop $drop_rate), group_size=$group_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MSE}."\n";
        }
        foreach my $opt_type (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE} })) {
            print "$trace (drop $drop_rate), opt_type=$opt_type, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MSE}."\n";
        }
        foreach my $rank (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK} })) {
            print "$trace (drop $drop_rate), rank=$rank, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MSE}."\n";
        }

        ## MAE
        print "MAE:\n";
        foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT} })) {
            print "$trace (drop $drop_rate), opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE}."\n";
        }
        foreach my $group_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE} })) {
            print "$trace (drop $drop_rate), group_size=$group_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{MAE}."\n";
        }
        foreach my $opt_type (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE} })) {
            print "$trace (drop $drop_rate), opt_type=$opt_type, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{MAE}."\n";
        }
        foreach my $rank (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK} })) {
            print "$trace (drop $drop_rate), rank=$rank, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK}{$rank}{MAE}."\n";
        }

        ## CC
        print "CC:\n";
        foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT} })) {
            print "$trace (drop $drop_rate), opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC}."\n";
        }
        foreach my $group_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE} })) {
            print "$trace (drop $drop_rate), group_size=$group_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{GROUP_SIZE}{$group_size}{CC}."\n";
        }
        foreach my $opt_type (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE} })) {
            print "$trace (drop $drop_rate), opt_type=$opt_type, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_TYPE}{$opt_type}{CC}."\n";
        }
        foreach my $rank (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK} })) {
            print "$trace (drop $drop_rate), rank=$rank, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{RANK}{$rank}{CC}."\n";
        }
        print "\n";
    }
    print "\n";
}
