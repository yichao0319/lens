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
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_pca/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_pca/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_pca/figures";
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
my $func = "pca_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @block_sizes;
my @seeds;
my @loss_rates;
my @opt_dects;
my @ranks;
my @files;

# @files = ("TM_Airport_period5_");
@files = ("tm.sort_ips.ap.country.txt.3600.", "tm.sort_ips.ap.gps.4.txt.3600.", "tm.select_matrix_for_id-Assignment.txt.60.");
for my $file_name (@files) {
    
    
    if($file_name eq "TM_Manhattan_period5_") {
        $num_frames = 12;
        $width = 500;
        $height = 500;

        @opt_swap_mats = (0, 1, 2, 3);
        @block_sizes = (30, 100, 200, 400);
        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "TM_Airport_period5_") {
        $num_frames = 12;
        $width = 300;
        $height = 300;

        @opt_swap_mats = (0, 1, 2, 3);
        @block_sizes = (30, 100, 200, 400);
        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
        $num_frames = 9;
        $width = 346;
        $height = 346;

        @opt_swap_mats = (0, 3);
        @block_sizes = (30, 100, 200, 400);
        @ranks = (1, 2, 3, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.4.txt.3600.") {
        $num_frames = 9;
        $width = 741;
        $height = 741;

        @opt_swap_mats = (0, 3);
        @block_sizes = (70, 125, 247, 800);
        @ranks = (1, 2, 3, 5, 10, 20, 30, 50);
    }
    elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
        $num_frames = 12;
        $width = 28;
        $height = 28;

        @opt_swap_mats = (0, 3);
        @block_sizes = (10, 14, 28);
        @ranks = (1, 2, 3, 4, 5, 10);
    }

    @seeds = (1 .. 10);
    # @loss_rates = (0.001, 0.005, 0.01);
    @loss_rates = (0.005, 0.01);
    @opt_dects = (1);

    for my $loss_rate (@loss_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = 0;
            }

            for my $opt_dect (@opt_dects) {
                if(!(exists $best{TRACE}{"$file_name"}{OPT_DECT}{$opt_dect}{MSE})) {
                    $best{TRACE}{"$file_name"}{OPT_DECT}{$opt_dect}{MSE} = 0;
                }
                
                for my $block_size (@block_sizes) {
                    if(!(exists $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE})) {
                        $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE} = 0;
                    }
                    

                    ## gnuplot - data
                    open FH_OUT_2, "> $output_dir/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.txt" or die $!;

                    ## gnuplot - MSE
                    my $cmd = "sed 's/FILENAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mse/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MSE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mse.plot";
                    `$cmd`;
                    open FH_GNU_MSE, ">> tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mse.plot" or die $!;

                    ## gnuplot - MAE
                    my $cmd = "sed 's/FILENAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mae/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MAE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mae.plot";
                    `$cmd`;
                    open FH_GNU_MAE, ">> tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mae.plot" or die $!;

                    ## gnuplot - CC
                    my $cmd = "sed 's/FILENAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate/g;s/FIGNAME/$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.cc/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/CC/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.cc.plot";
                    `$cmd`;
                    open FH_GNU_CC, ">> tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.cc.plot" or die $!;


                    my $first_seed = 1;
                    for my $seed (@seeds) {
                        print FH_OUT_2 "$seed, ";

                        my $cnt = 0;
                        for my $rank (@ranks) {
                            if(!(exists $best{TRACE}{"$file_name"}{RANK}{$rank}{MSE})) {
                                $best{TRACE}{"$file_name"}{RANK}{$rank}{MSE} = 0;
                            }


                            my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$block_size.$block_size.$rank.$opt_dect.$opt_swap_mat.$loss_rate.$seed.txt";

                            print "$this_file_name\n";
                            
                            open FH, $this_file_name or die ">> $this_file_name\n\t".$!;
                            while(<FH>) {
                                my @ret = split(/, /, $_);
                                my $mse = $ret[0] + 0;
                                my $mae = $ret[1] + 0;
                                my $cc = $ret[2] + 0;

                                
                                ## rank - block size - opt_swap_mat
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{"$block_size,$block_size"}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE} = $mse;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{"$block_size,$block_size"}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE} = $mae;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{"$block_size,$block_size"}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC} = $cc;

                                ## block size - rank - opt_swap_mat
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE} = $mse;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE} = $mae;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC} = $cc;

                                ## opt_swap_mat - block size - rank
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{SEED}{$seed}{MSE} = $mse;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{SEED}{$seed}{MAE} = $mae;
                                $data{TRACE}{"$file_name"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{"$block_size,$block_size"}{RANK}{$rank}{SEED}{$seed}{CC} = $cc;
                                

                                my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $opt_dect, $rank, $block_size, $block_size, $loss_rate, $seed, $mse, $mae, $cc\n";
                                print $buf;
                                print FH_OUT $buf;


                                ####################
                                if($mse < $best{TRACE}{"$file_name"}{OPT_DECT}{$opt_dect}{MSE}) {
                                    $best{TRACE}{"$file_name"}{OPT_DECT}{$opt_dect}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE}) {
                                    $best{TRACE}{"$file_name"}{BLOCK_SIZE}{$block_size}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}) {
                                    $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $mse;
                                }
                                if($mse < $best{TRACE}{"$file_name"}{RANK}{$rank}{MSE}) {
                                    $best{TRACE}{"$file_name"}{RANK}{$rank}{MSE} = $mse;
                                }
                                

                                ####################
                                ## gnuplot - data
                                print FH_OUT_2 "$rank, $mse, $mae, $cc, ";
                                
                                ## gnuplot - PR
                                if($first_seed == 1 and $cnt < $NUM_CURVE){
                                    ## gnuplot - MSE
                                    my $ind = 1 + $cnt * 4 + 2;
                                    my $ls_cnt = $cnt % 8 + 1;
                                    print FH_GNU_MSE "," if($cnt != 0);
                                    print FH_GNU_MSE " \\\n";
                                    print FH_GNU_MSE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 rank=$rank}'";

                                    ## gnuplot - MAE
                                    $ind = 1 + $cnt * 4 + 3;
                                    print FH_GNU_MAE "," if($cnt != 0);
                                    print FH_GNU_MAE " \\\n";
                                    print FH_GNU_MAE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 rank=$rank}'";

                                    ## gnuplot - CC
                                    $ind = 1 + $cnt * 4 + 4;
                                    print FH_GNU_CC "," if($cnt != 0);
                                    print FH_GNU_CC " \\\n";
                                    print FH_GNU_CC "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 rank=$rank}'";

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
                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mse.plot";
                    `$cmd`;

                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.mae.plot";
                    `$cmd`;

                    $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$block_size.$opt_dect.$opt_swap_mat.$loss_rate.cc.plot";
                    `$cmd`;
                }  ## end of rank
            }
        }
    }
}
close FH_OUT;



#############
# Statistics
#############
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [F1SCORE | SETTING | FP | ...]
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    foreach my $opt_dect (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_DECT} })) {
        print "$trace, opt_dect=$opt_dect, ".$best{TRACE}{$trace}{OPT_DECT}{$opt_dect}{MSE}."\n";
    }

    foreach my $rank (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{RANK} })) {
        print "$trace, rank=$rank, ".$best{TRACE}{$trace}{RANK}{$rank}{MSE}."\n";
    }

    foreach my $block_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{BLOCK_SIZE} })) {
        print "$trace, block_size=$block_size, ".$best{TRACE}{$trace}{BLOCK_SIZE}{$block_size}{MSE}."\n";
    }

    foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_SWAP_MAT} })) {
        print "$trace, opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}."\n";
    }
}


#############
## Comparison
#############
foreach my $file (@files) {
    open FH_R1, ">$output_dir/$func.$file.comp.rank.mse.txt" or die $!;
    open FH_R2, ">$output_dir/$func.$file.comp.rank.mae.txt" or die $!;
    open FH_R3, ">$output_dir/$func.$file.comp.rank.cc.txt" or die $!;
    open FH_B1, ">$output_dir/$func.$file.comp.block.mse.txt" or die $!;
    open FH_B2, ">$output_dir/$func.$file.comp.block.mae.txt" or die $!;
    open FH_B3, ">$output_dir/$func.$file.comp.block.cc.txt" or die $!;
    open FH_S1, ">$output_dir/$func.$file.comp.swap.mse.txt" or die $!;
    open FH_S2, ">$output_dir/$func.$file.comp.swap.mae.txt" or die $!;
    open FH_S3, ">$output_dir/$func.$file.comp.swap.cc.txt" or die $!;

    print FH_R1 "missing_rate, ";
    print FH_R2 "missing_rate, ";
    print FH_R3 "missing_rate, ";
    foreach my $rank (@ranks) {
        print FH_R1 "rank=$rank, ";
        print FH_R2 "rank=$rank, ";
        print FH_R3 "rank=$rank, ";
    }
    print FH_R1 "\n";
    print FH_R2 "\n";
    print FH_R3 "\n";

    print FH_B1 "missing_rate, ";
    print FH_B2 "missing_rate, ";
    print FH_B3 "missing_rate, ";
    foreach my $block_size (@block_sizes) {
        print FH_B1 "block=$block_size, ";
        print FH_B2 "block=$block_size, ";
        print FH_B3 "block=$block_size, ";
    }
    print FH_B1 "\n";
    print FH_B2 "\n";
    print FH_B3 "\n";

    print FH_S1 "missing_rate, ";
    print FH_S2 "missing_rate, ";
    print FH_S3 "missing_rate, ";
    foreach my $opt_swap_mat (@opt_swap_mats) {
        print FH_S1 "swap=$opt_swap_mat, ";
        print FH_S2 "swap=$opt_swap_mat, ";
        print FH_S3 "swap=$opt_swap_mat, ";
    }
    print FH_S1 "\n";
    print FH_S2 "\n";
    print FH_S3 "\n";
    
    
    foreach my $loss_rate (@loss_rates) {
        foreach my $opt_dect (@opt_dects) {
            #############
            ## Compare ranks
            #############
            print FH_R1 "$loss_rate, ";
            print FH_R2 "$loss_rate, ";
            print FH_R3 "$loss_rate, ";
            foreach my $rank (sort {$a <=> $b} (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK} })) {
                
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MSE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MAE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{CC} = -1;

                foreach my $block_size (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE} }) {
                    foreach my $opt_swap_mat (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{$block_size}{OPT_SWAP_MAT} }) {

                        my $tmp_mse = 0;
                        my $tmp_mae = 0;
                        my $tmp_cc = 0;
                        foreach my $seed (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{$block_size}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED} }) {
                            $tmp_mse += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{$block_size}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE};
                            $tmp_mae += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{$block_size}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE};
                            $tmp_cc += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{BLOCK_SIZE}{$block_size}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC};
                        }
                        $tmp_mse /= scalar(@seeds);
                        $tmp_mae /= scalar(@seeds);
                        $tmp_cc /= scalar(@seeds);

                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MSE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MSE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MAE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MAE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{CC} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{CC} == -1);
                    }
                }
                print FH_R1 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MSE}.", ";
                print FH_R2 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{MAE}.", ";
                print FH_R3 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{RANK}{$rank}{CC}.", ";
            }
            

            #############
            ## Compare group sizes
            #############
            print FH_B1 "$loss_rate, ";
            print FH_B2 "$loss_rate, ";
            print FH_B3 "$loss_rate, ";
            foreach my $block_size (sort {$a <=> $b} (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE} })) {
                
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MSE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MAE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{CC} = -1;

                foreach my $rank (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK} }) {
                    foreach my $opt_swap_mat (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{OPT_SWAP_MAT} }) {

                        my $tmp_mse = 0;
                        my $tmp_mae = 0;
                        my $tmp_cc = 0;
                        foreach my $seed (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED} }) {
                            $tmp_mse += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE};
                            $tmp_mae += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE};
                            $tmp_cc += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC};
                        }
                        $tmp_mse /= scalar(@seeds);
                        $tmp_mae /= scalar(@seeds);
                        $tmp_cc /= scalar(@seeds);

                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MSE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MSE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MAE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MAE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{CC} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{CC} == -1);
                    }
                }

                print FH_B1 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MSE}.", ";
                print FH_B2 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{MAE}.", ";
                print FH_B3 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{BLOCK_SIZE}{$block_size}{CC}.", ";
            }


            #############
            ## Compare opt swap mats
            #############
            print FH_S1 "$loss_rate, ";
            print FH_S2 "$loss_rate, ";
            print FH_S3 "$loss_rate, ";
            foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT} })) {
                
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;

                foreach my $block_size (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE} }) {
                    foreach my $rank (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{$block_size}{RANK} }) {

                        my $tmp_mse = 0;
                        my $tmp_mae = 0;
                        my $tmp_cc = 0;
                        foreach my $seed (keys %{ $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{SEED} }) {
                            $tmp_mse += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{SEED}{$seed}{MSE};
                            $tmp_mae += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{SEED}{$seed}{MAE};
                            $tmp_cc += $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{BLOCK_SIZE}{$block_size}{RANK}{$rank}{SEED}{$seed}{CC};
                        }
                        $tmp_mse /= scalar(@seeds);
                        $tmp_mae /= scalar(@seeds);
                        $tmp_cc /= scalar(@seeds);

                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1);
                        $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or $data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1);
                    }
                }

                print FH_S1 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}.", ";
                print FH_S2 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE}.", ";
                print FH_S3 "".$data{TRACE}{"$file"}{LOSS_RATE}{$loss_rate}{OPT_DECT}{$opt_dect}{OPT_SWAP_MAT}{$opt_swap_mat}{CC}.", ";
            }

            print FH_R1 "\n";
            print FH_R2 "\n";
            print FH_R3 "\n";
            print FH_B1 "\n";
            print FH_B2 "\n";
            print FH_B3 "\n";
            print FH_S1 "\n";
            print FH_S2 "\n";
            print FH_S3 "\n";
        }
    }
    close FH_R1;
    close FH_R2;
    close FH_R3;
    close FH_B1;
    close FH_B2;
    close FH_B3;
    close FH_S1;
    close FH_S2;
    close FH_S3;


    my $escape_output_dir = $output_dir."/";
    $escape_output_dir =~ s{\/}{\\\/}g;
    my $escape_figure_dir = $figure_dir."/";
    $escape_figure_dir =~ s{\/}{\\\/}g;

    my $method = "rank";
    my $eval   = "mse";
    my $col_size = 2 + scalar(@ranks) - 1;
    my $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "mae";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "cc";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;

    ##########

    $method = "block";
    $eval   = "mse";
    $col_size = 2 + scalar(@block_sizes) - 1;
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "mae";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "cc";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;

    ##########

    $method = "swap";
    $eval   = "mse";
    $col_size = 2 + scalar(@opt_swap_mats) - 1;
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "mae";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    
    $eval   = "cc";
    $cmd = "sed 's/DATA_DIR/$escape_output_dir/g; s/FIG_DIR/$escape_figure_dir/g; s/FILE_NAME/$func.$file.comp.$method.$eval/g; s/FIG_NAME/$func.$file.comp.$method.$eval/g; s/X_LABEL/missing rate/g; s/Y_LABEL/$eval/g; s/DEGREE/0/g; s/X_RANGE_S//g; s/X_RANGE_E//g; s/Y_RANGE_S//g; s/Y_RANGE_E//g; s/COL_S/2/g; s/COL_E/$col_size/g; ' plot.bar.mother.plot > tmp.plot";
    `$cmd`;
    $cmd = "gnuplot tmp.plot";
    `$cmd`;
    

    $cmd = "rm tmp.plot";
    `$cmd`;
}




