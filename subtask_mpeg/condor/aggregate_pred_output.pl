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
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_mpeg/figures";
my $gnuplot_mother = "plot.pr";

## data - TRACE - OPT_DECT - OPT_DELTA - BLOCK_SIZE - THRESH - [TP, TN, FP, TN, ...]
my %data = ();
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
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
my $func = "mpeg_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @block_sizes;
my @seeds;
my @drop_rates;
my @opt_deltas;
my @opt_f_bs;
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

        @block_sizes = (30);
    }
    elsif($file_name eq "TM_Airport_period5_") {
        $num_frames = 12;
        $width = 300;
        $height = 300;

        @block_sizes = (30);
    }
    #######################
    elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
        $num_frames = 12;
        $width = 28;
        $height = 28;

        @block_sizes = (10, 14, 28);
    }
    #######################
    elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
        $num_frames = 8;
        $width = 400;
        $height = 400;

        @block_sizes = (40, 100, 200);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.5.txt.3600.") {
        $num_frames = 8;
        $width = 738;
        $height = 738;

        @block_sizes = (70, 125, 247);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.1.sub_CN.txt.3600.") {
        $num_frames = 8;
        $width = 410;
        $height = 410;

        @block_sizes = (41, 103, 205);
    }
    elsif($file_name eq "tm.sort_ips.ap.bgp.8.txt.3600.") {
        $num_frames = 8;
        $width = 421;
        $height = 421;

        @block_sizes = (43, 106, 211);
    }
    elsif($file_name eq "tm.sort_ips.ap.bgp.10.sub_CN.txt.3600.") {
        $num_frames = 8;
        $width = 403;
        $height = 403;

        @block_sizes = (41, 101, 202);
    }
    #######################

    @seeds = (1 .. 10);
    @opt_swap_mats = (0, 1, 3);
    @drop_rates = (0.005, 0.01, 0.05);
    @opt_deltas = (1, 2);
    @opt_f_bs = (16, 18, 19, 21);


    for my $drop_rate (@drop_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;
            }

            for my $opt_delta (@opt_deltas) {
                if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE})) {
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} = -1;
                    $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} = -1;
                }

                for my $opt_fb (@opt_f_bs) {
                    if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE})) {
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MAE} = -1;
                        $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{CC} = -1;
                    }

                    for my $block_size (@block_sizes) {
                        if(!(exists $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE})) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} = -1;
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} = -1;
                        }

                        my @mses;
                        my @maes;
                        my @ccs;
                        for my $seed (@seeds) {
                            my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$block_size.$block_size.$opt_delta.$opt_fb.$opt_swap_mat.$drop_rate.$seed.txt";
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

                                my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $opt_delta, $opt_fb, $block_size, $block_size, $drop_rate, $seed, $mse, $mae, $cc\n";
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
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE} = $avg_mse;
                        }
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE} = $avg_mse;
                        }
                        if($avg_mse < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE} = $avg_mse;
                        }
                        ## MAE
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MAE} = $avg_mae;
                        }
                        if($avg_mae < $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE} = $avg_mae;
                        }
                        ## CC
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{CC} = $avg_cc;
                        }
                        if($avg_cc > $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} or 
                           $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} == -1) {
                            $best{TRACE}{"$file_name"}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC} = $avg_cc;
                        }
                    }
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
        foreach my $opt_delta (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA} })) {
            print "$trace (drop $drop_rate), opt_delta=$opt_delta, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MSE}."\n";
        }
        foreach my $opt_fb (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB} })) {
            print "$trace (drop $drop_rate), opt_fb=$opt_fb, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MSE}."\n";
        }
        foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE} })) {
            print "$trace (drop $drop_rate), block_size=$block_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MSE}."\n";
        }

        ## MAE    
        print "MAE:\n";
        foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT} })) {
            print "$trace (drop $drop_rate), opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE}."\n";
        }
        foreach my $opt_delta (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA} })) {
            print "$trace (drop $drop_rate), opt_delta=$opt_delta, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{MAE}."\n";
        }
        foreach my $opt_fb (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB} })) {
            print "$trace (drop $drop_rate), opt_fb=$opt_fb, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{MAE}."\n";
        }
        foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE} })) {
            print "$trace (drop $drop_rate), block_size=$block_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{MAE}."\n";
        }

        ## CC    
        print "CC:\n";
        foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT} })) {
            print "$trace (drop $drop_rate), opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC}."\n";
        }
        foreach my $opt_delta (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA} })) {
            print "$trace (drop $drop_rate), opt_delta=$opt_delta, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_DELTA}{$opt_delta}{CC}."\n";
        }
        foreach my $opt_fb (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB} })) {
            print "$trace (drop $drop_rate), opt_fb=$opt_fb, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{OPT_FB}{$opt_fb}{CC}."\n";
        }
        foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE} })) {
            print "$trace (drop $drop_rate), block_size=$block_size, ".$best{TRACE}{$trace}{DROP_RATE}{$drop_rate}{BLOCK_SIZE}{$block_size}{CC}."\n";
        }
        print "\n";
    }
    print "\n";
}
