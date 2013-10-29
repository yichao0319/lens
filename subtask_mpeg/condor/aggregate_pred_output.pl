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

for my $file_name ("TM_Airport_period5_") {
    
    my $num_frames = 12;
    my $width = 300;
    my $height = 300;
    if($file_name eq "TM_Manhattan_period5_") {
        my $width = 500;
        my $height = 500;
    }

    for my $loss_rate (0.001, 0.005, 0.01) {

        for my $opt_swap_mat (0, 1, 2, 3) {
            if(!(exists $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = 0;
            }

            for my $opt_delta (1, 2) {
                if(!(exists $best{TRACE}{"$file_name"}{OPT_DELTA}{$opt_delta}{MSE})) {
                    $best{TRACE}{"$file_name"}{OPT_DELTA}{$opt_delta}{MSE} = 0;
                }


                for my $opt_fb (16, 18, 19, 21) {
                    if(!(exists $best{TRACE}{"$file_name"}{OPT_FB}{$opt_fb}{MSE})) {
                        $best{TRACE}{"$file_name"}{OPT_FB}{$opt_fb}{MSE} = 0;
                    }

                    ## gnuplot - data
                    open FH_OUT_2, "> $output_dir/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.txt" or die $!;

                    ## gnuplot - MSE
                    my $cmd = "sed 's/FILENAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mse/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MSE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mse.plot";
                    `$cmd`;
                    open FH_GNU_MSE, ">> tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mse.plot" or die $!;

                    ## gnuplot - MAE
                    $cmd = "sed 's/FILENAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mae/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MAE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mae.plot";
                    `$cmd`;
                    open FH_GNU_MAE, ">> tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mae.plot" or die $!;

                    ## gnuplot - CC
                    $cmd = "sed 's/FILENAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.cc/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/CC/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.cc.plot";
                    `$cmd`;
                    open FH_GNU_CC, ">> tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.cc.plot" or die $!;


                    my $first_seed = 1;
                    for my $seed (1 .. 10) {
                        print FH_OUT_2 "$seed, ";

                        my $cnt = 0;
                        for my $block_size (30) {
                            if(!(exists $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE})) {
                                $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE} = 0;
                            }


                            my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$block_size.$block_size.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.$seed.txt";

                            print "$this_file_name\n";
                            
                            open FH, $this_file_name or die $!;
                            while(<FH>) {
                                my @ret = split(/, /, $_);
                                my $mse = $ret[0] + 0;
                                my $mae = $ret[1] + 0;
                                my $cc = $ret[2] + 0;
                                

                                $data{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DELTA}{$opt_delta}{OPT_FB}{$opt_fb}{BLOCK_SIZE}{"$block_size,$block_size"}{LOSS_RATE}{$loss_rate}{SEED}{$seed}{MSE} = $mse;
                                $data{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DELTA}{$opt_delta}{OPT_FB}{$opt_fb}{BLOCK_SIZE}{"$block_size,$block_size"}{LOSS_RATE}{$loss_rate}{SEED}{$seed}{MAE} = $mae;
                                $data{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_DELTA}{$opt_delta}{OPT_FB}{$opt_fb}{BLOCK_SIZE}{"$block_size,$block_size"}{LOSS_RATE}{$loss_rate}{SEED}{$seed}{CC} = $cc;
                                
                                my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $opt_delta, $opt_fb, $block_size, $block_size, $loss_rate, $seed, $mse, $mae, $cc\n";
                                print $buf;
                                print FH_OUT $buf;


                                ####################
                                if($mse < $best{TRACE}{"$file_name"}{OPT_DELTA}{$opt_delta}{MSE}) {
                                    $best{TRACE}{"$file_name"}{OPT_DELTA}{$opt_delta}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{OPT_FB}{$opt_fb}{MSE}) {
                                    $best{TRACE}{"$file_name"}{OPT_FB}{$opt_fb}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE}) {
                                    $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}) {
                                    $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $mse;
                                }


                                ####################
                                ## gnuplot - data
                                print FH_OUT_2 "$block_size, $mse, $mae, $cc, ";

                                if($first_seed == 1 and $cnt < $NUM_CURVE){
                                    ## gnuplot - MSE
                                    my $ind = 1 + $cnt * 4 + 2;
                                    my $ls_cnt = $cnt % 8 + 1;
                                    print FH_GNU_MSE "," if($cnt != 0);
                                    print FH_GNU_MSE " \\\n";
                                    print FH_GNU_MSE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 block=$block_size}'";

                                    ## gnuplot - MAE
                                    $ind = 1 + $cnt * 4 + 3;
                                    print FH_GNU_MAE "," if($cnt != 0);
                                    print FH_GNU_MAE " \\\n";
                                    print FH_GNU_MAE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 block=$block_size}'";

                                    ## gnuplot - CC
                                    $ind = 1 + $cnt * 4 + 4;
                                    print FH_GNU_CC "," if($cnt != 0);
                                    print FH_GNU_CC " \\\n";
                                    print FH_GNU_CC "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 block=$block_size}'";
                                    
                                    
                                    $cnt ++;
                                }
                            }
                            close FH;
                        }
                        $first_seed = 0;
                        print FH_OUT_2 "\n";
                    }
                    close FH_OUT_2;
                    close FH_GNU_MSE;
                    close FH_GNU_MAE;
                    close FH_GNU_CC;

                    ## gnuplot
                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mse.plot";
                    `$cmd`;

                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.mae.plot";
                    `$cmd`;

                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$opt_delta.$opt_fb.$opt_swap_mat.$loss_rate.cc.plot";
                    `$cmd`;
                }  ## end of opt_fb
            }  ## end of opt_delta
        }
    }
}
close FH_OUT;



#############
# Statistics
#############
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    
    foreach my $opt_delta (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_DELTA} })) {
        print "$trace, opt_delta=$opt_delta, ".$best{TRACE}{$trace}{OPT_DELTA}{$opt_delta}{MSE}."\n";
    }

    foreach my $opt_fb (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_FB} })) {
        print "$trace, opt_fb=$opt_fb, ".$best{TRACE}{$trace}{OPT_FB}{$opt_fb}{MSE}."\n";
    }

    foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{BLOCK_SIZE} })) {
        print "$trace, block_size=$block_size, ".$best{TRACE}{$trace}{BLOCK_SIZE}{$block_size}{MSE}."\n";
    }

    foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_SWAP_MAT} })) {
        print "$trace, opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}."\n";
    }
}
