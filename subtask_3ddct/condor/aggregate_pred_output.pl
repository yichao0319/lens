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
my $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/condor/output";
my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/output";
my $figure_dir = "/u/yichao/anomaly_compression/condor_data/subtask_3ddct/figures";
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
my $func = "dct_based_pred";
open FH_OUT, "> $output_dir/$func.txt" or die $!;

my $num_frames;
my $width;
my $height;
my @opt_swap_mats;
my @chunk_sizes;
my @sel_chunks;
my @seeds;
my @loss_rates;
my @group_sizes;
my @opt_types;
my @quantizations;
my @files;

# @files = ("TM_Airport_period5_");
@files = ("tm.sort_ips.ap.country.txt.3600.", "tm.sort_ips.ap.gps.4.txt.3600.", "tm.select_matrix_for_id-Assignment.txt.60.");
for my $file_name (@files) {
    
    
    if($file_name eq "TM_Manhattan_period5_") {
        $num_frames = 12;
        $width = 500;
        $height = 500;

        @opt_swap_mats = (0, 1, 2, 3);
        @chunk_sizes = (30, 50, 100);
        @sel_chunks = (1, 5, 10, 20, 30);
    }
    elsif($file_name eq "TM_Airport_period5_") {
        $num_frames = 12;
        $width = 300;
        $height = 300;

        @opt_swap_mats = (0, 1, 2, 3);
        @chunk_sizes = (30, 50, 100);
        @sel_chunks = (1, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.country.txt.3600.") {
        $num_frames = 9;
        $width = 346;
        $height = 346;

        @opt_swap_mats = (0, 3);
        @chunk_sizes = (30, 50, 100);
        @sel_chunks = (1, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.sort_ips.ap.gps.4.txt.3600.") {
        $num_frames = 9;
        $width = 741;
        $height = 741;

        @opt_swap_mats = (0, 3);
        @chunk_sizes = (70, 125, 247);
        @sel_chunks = (1, 5, 10, 20, 30);
    }
    elsif($file_name eq "tm.select_matrix_for_id-Assignment.txt.60.") {
        $num_frames = 12;
        $width = 28;
        $height = 28;

        @opt_swap_mats = (0, 3);
        @chunk_sizes = (10, 14);
        @sel_chunks = (1, 2, 3, 5, 10);
    }

    @seeds = (1 .. 10);
    @loss_rates = (0.001, 0.005, 0.01);
    @group_sizes = (4);
    @opt_types = (0, 1);
    @quantizations = (5, 10, 20, 30, 50);


    for my $loss_rate (@loss_rates) {

        for my $opt_swap_mat (@opt_swap_mats) {
            if(!(exists $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE})) {
                $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = 0;
            }

            for my $group_size (@group_sizes) {
                if(!(exists $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE})) {
                    $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE} = 0;
                }
                
                for my $opt_type (@opt_types) {
                    if(!(exists $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE})) {
                        $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE} = 0;
                    }



                    ##############
                    if($opt_type == 0) {
                        my $chunk_size = 0;
                        my $sel_chunks = 0;

                        ## gnuplot - data
                        open FH_OUT_2, "> $output_dir/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.txt" or die $!;

                        ## gnuplot - MSE
                        my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mse/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MSE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mse.plot";
                        `$cmd`;
                        open FH_GNU_MSE, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mse.plot" or die $!;

                        ## gnuplot - MAE
                        my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mae/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MAE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mae.plot";
                        `$cmd`;
                        open FH_GNU_MAE, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mae.plot" or die $!;

                        ## gnuplot - CC
                        my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.cc/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/CC/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.cc.plot";
                        `$cmd`;
                        open FH_GNU_CC, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.cc.plot" or die $!;



                        my $first_seed = 1;
                        for my $seed (@seeds) {
                            print FH_OUT_2 "$seed, ";

                            my $cnt = 0;
                            for my $quantization (@quantizations) {
                                if(!(exists $best{TRACE}{"$file_name"}{QUANTIZATION}{$quantization}{MSE})) {
                                    $best{TRACE}{"$file_name"}{QUANTIZATION}{$quantization}{MSE} = 0;
                                }
                                

                                my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$chunk_size.$sel_chunks.$quantization.$loss_rate.$seed.txt";

                                print "$this_file_name\n";
                                
                                open FH, $this_file_name or die $!;
                                while(<FH>) {
                                    my @ret = split(/, /, $_);
                                    my $mse = $ret[0] + 0;
                                    my $mae = $ret[1] + 0;
                                    my $cc  = $ret[2] + 0;

                                    ## XXX: figure out why nan
                                    if($mse eq "nan") {
                                        $mse = 0;
                                    }
                                    if($mae eq "nan") {
                                        $mae = 0;
                                    }
                                    if($cc eq "nan") {
                                        $cc = 0;
                                    }


                                    ## swap - type 0 - quantizations
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{MSE} = $mse;
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{MAE} = $mae;
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{CC} = $cc;

                                    ## type 0 - quantizations - swap
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE} = $mse;
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE} = $mae;
                                    $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC} = $cc;

                                    

                                    my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_size, $chunk_size, $sel_chunks, $quantization, $loss_rate, $seed, $mse, $mae, $cc\n";
                                    print $buf;
                                    print FH_OUT $buf;


                                    ####################
                                    if($mse < $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE}) {
                                        $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE} = $mse;
                                    }
                                    if($mse < $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE}) {
                                        $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE} = $mse;
                                    }
                                    if($mse < $best{TRACE}{"$file_name"}{QUANTIZATION}{$quantization}{MSE}) {
                                        $best{TRACE}{"$file_name"}{QUANTIZATION}{$quantization}{MSE} = $mse;
                                    }
                                    if($mse < $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}) {
                                        $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $mse;
                                    }


                                    ####################
                                    ## gnuplot - data
                                    print FH_OUT_2 "$quantization, $mse, $mae, $cc, ";
                                    
                                    if($first_seed == 1 and $cnt < $NUM_CURVE){
                                        ## gnuplot - MSE
                                        my $ind = 1 + $cnt * 4 + 2;
                                        my $ls_cnt = $cnt % 8 + 1;
                                        print FH_GNU_MSE "," if($cnt != 0);
                                        print FH_GNU_MSE " \\\n";
                                        print FH_GNU_MSE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";

                                        ## gnuplot - MAE
                                        $ind = 1 + $cnt * 4 + 3;
                                        print FH_GNU_MAE "," if($cnt != 0);
                                        print FH_GNU_MAE " \\\n";
                                        print FH_GNU_MAE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";

                                        ## gnuplot - CC
                                        $ind = 1 + $cnt * 4 + 4;
                                        print FH_GNU_CC "," if($cnt != 0);
                                        print FH_GNU_CC " \\\n";
                                        print FH_GNU_CC "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";
                                        
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
                        $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mse.plot";
                        `$cmd`;

                        $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.mae.plot";
                        `$cmd`;

                        $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$loss_rate.cc.plot";
                        `$cmd`;
                    }

                    elsif($opt_type == 1) {
                        my $quantization = 0;

                        for my $chunk_size (@chunk_sizes) {

                            ## gnuplot - data
                            open FH_OUT_2, "> $output_dir/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.txt" or die $!;

                            ## gnuplot - MSE
                            my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mse/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MSE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mse.plot";
                            `$cmd`;
                            open FH_GNU_MSE, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mse.plot" or die $!;

                            ## gnuplot - MAE
                            my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mae/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/MAE/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mae.plot";
                            `$cmd`;
                            open FH_GNU_MAE, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mae.plot" or die $!;

                            ## gnuplot - CC
                            my $cmd = "sed 's/FILENAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate/g;s/FIGNAME/$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.cc/g;s/X_RANGE_S//g;s/X_RANGE_E//g;s/Y_RANGE_S//g;s/Y_RANGE_E//g;s/X_LABEL/seed/g;s/Y_LABEL/CC/g;s/DEGREE/-45/g;' $gnuplot_mother.mother.plot > tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.cc.plot";
                            `$cmd`;
                            open FH_GNU_CC, ">> tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.cc.plot" or die $!;


                            my $first_seed = 1;
                            for my $seed (@seeds) {
                                print FH_OUT_2 "$seed, ";

                                my $cnt = 0;
                                for my $sel_chunks (@sel_chunks) {
                                    if(!(exists $best{TRACE}{"$file_name"}{SEL_CHUNKS}{$sel_chunks}{MSE})) {
                                        $best{TRACE}{"$file_name"}{SEL_CHUNKS}{$sel_chunks}{MSE} = 0;
                                    }
                                    

                                    my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$chunk_size.$sel_chunks.$quantization.$loss_rate.$seed.txt";

                                    print "$this_file_name\n";
                                    
                                    open FH, $this_file_name or die $!;
                                    while(<FH>) {
                                        my @ret = split(/, /, $_);
                                        my $mse = $ret[0] + 0;
                                        my $mae = $ret[1] + 0;
                                        my $cc  = $ret[2] + 0;

                                        ## XXX: figure out why nan
                                        if($mse eq "nan") {
                                            $mse = 0;
                                        }
                                        if($mae eq "nan") {
                                            $mae = 0;
                                        }
                                        if($cc eq "nan") {
                                            $cc = 0;
                                        }

                                        ## swap - type 1 - chunk - sel
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{MSE} = $mse;
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{MAE} = $mae;
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{CC} = $cc;

                                        ## type 1 - chunk - sel - swap
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE} = $mse;
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE} = $mae;
                                        $data{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC} = $cc;


                                        my $buf = "$file_name, $num_frames, $width, $height, $opt_swap_mat, $group_size, $opt_type, $chunk_size, $chunk_size, $sel_chunks, $quantization, $loss_rate, $seed, $mse, $mae, $cc\n";
                                        print $buf;
                                        print FH_OUT $buf;


                                        ####################
                                        if($mse > $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE}) {
                                            $best{TRACE}{"$file_name"}{GROUP_SIZE}{$group_size}{MSE} = $mse;
                                        }
                                        if($mse > $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE}) {
                                            $best{TRACE}{"$file_name"}{OPT_TYPE}{$opt_type}{MSE} = $mse;
                                        }
                                        if($mse > $best{TRACE}{"$file_name"}{CHUNK_SIZE}{$chunk_size}{MSE}) {
                                            $best{TRACE}{"$file_name"}{CHUNK_SIZE}{$chunk_size}{MSE} = $mse;
                                        }
                                        if($mse > $best{TRACE}{"$file_name"}{SEL_CHUNKS}{$sel_chunks}{MSE}) {
                                            $best{TRACE}{"$file_name"}{SEL_CHUNKS}{$sel_chunks}{MSE} = $mse;
                                        }
                                        if($mse > $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}) {
                                            $best{TRACE}{"$file_name"}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $mse;
                                        }


                                        ####################
                                        ## gnuplot - data
                                        print FH_OUT_2 "$sel_chunks, $mse, $mae, $cc, ";
                                        
                                        ## gnuplot - PR
                                        if($first_seed == 1 and $cnt < $NUM_CURVE){
                                            ## gnuplot - MSE
                                            my $ind = 1 + $cnt * 4 + 2;
                                            my $ls_cnt = $cnt % 8 + 1;
                                            print FH_GNU_MSE "," if($cnt != 0);
                                            print FH_GNU_MSE " \\\n";
                                            print FH_GNU_MSE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";

                                            ## gnuplot - MAE
                                            $ind = 1 + $cnt * 4 + 3;
                                            print FH_GNU_MAE "," if($cnt != 0);
                                            print FH_GNU_MAE " \\\n";
                                            print FH_GNU_MAE "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";

                                            ## gnuplot - CC
                                            $ind = 1 + $cnt * 4 + 4;
                                            print FH_GNU_CC "," if($cnt != 0);
                                            print FH_GNU_CC " \\\n";
                                            print FH_GNU_CC "data_dir.file_name.\".txt\" using 1:$ind with linespoints ls $ls_cnt title '{/Helvetica=28 quant=$quantization}'";

                                            
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
                            $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mse.plot";
                            `$cmd`;

                            $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.mae.plot";
                            `$cmd`;

                            $cmd = "gnuplot tmp.$gnuplot_mother.$func.$file_name.$group_size.$opt_swap_mat.$opt_type.$chunk_size.$loss_rate.cc.plot";
                            `$cmd`;
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
## best - TRACE - [OPT_DECT | OPT_DELTA | BLOCK_SIZE] - [MSE | SETTING | FP | ...]
foreach my $trace (sort {$a cmp $b} (keys %{ $best{TRACE} })) {
    foreach my $group_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{GROUP_SIZE} })) {
        print "$trace, group_size=$group_size, ".$best{TRACE}{$trace}{GROUP_SIZE}{$group_size}{MSE}."\n";
    }

    foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_SWAP_MAT} })) {
        print "$trace, opt_swap_mat=$opt_swap_mat, ".$best{TRACE}{$trace}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}."\n";
    }

    foreach my $opt_type (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{OPT_TYPE} })) {
        print "$trace, opt_type=$opt_type, ".$best{TRACE}{$trace}{OPT_TYPE}{$opt_type}{MSE}."\n";
    }

    foreach my $chunk_size (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{CHUNK_SIZE} })) {
        print "$trace, chunk_size=$chunk_size, ".$best{TRACE}{$trace}{CHUNK_SIZE}{$chunk_size}{MSE}."\n";
    }

    foreach my $sel_chunks (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{SEL_CHUNKS} })) {
        print "$trace, sel_chunks=$sel_chunks, ".$best{TRACE}{$trace}{SEL_CHUNKS}{$sel_chunks}{MSE}."\n";
    }

    foreach my $quantization (sort {$a <=> $b} (keys %{ $best{TRACE}{$trace}{QUANTIZATION} })) {
        print "$trace, quantization=$quantization, ".$best{TRACE}{$trace}{QUANTIZATION}{$quantization}{MSE}."\n";
    }
    
}


#############
## Comparison
#############
foreach my $file (@files) {
    open FH_S1, ">$output_dir/$func.$file.comp.swap.mse.txt" or die $!;
    open FH_S2, ">$output_dir/$func.$file.comp.swap.mae.txt" or die $!;
    open FH_S3, ">$output_dir/$func.$file.comp.swap.cc.txt" or die $!;
    open FH_T1, ">$output_dir/$func.$file.comp.type.mse.txt" or die $!;
    open FH_T2, ">$output_dir/$func.$file.comp.type.mae.txt" or die $!;
    open FH_T3, ">$output_dir/$func.$file.comp.type.cc.txt" or die $!;
    
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

    print FH_T1 "missing_rate, ";
    print FH_T2 "missing_rate, ";
    print FH_T3 "missing_rate, ";
    foreach my $opt_type (@opt_types) {
        print FH_T1 "type=$opt_type, ";
        print FH_T2 "type=$opt_type, ";
        print FH_T3 "type=$opt_type, ";
    }
    print FH_T1 "\n";
    print FH_T2 "\n";
    print FH_T3 "\n";

    
    foreach my $loss_rate (@loss_rates) {
        foreach my $group_size (@group_sizes) {
            #############
            ## Compare swap
            #############
            print FH_S1 "$loss_rate, ";
            print FH_S2 "$loss_rate, ";
            print FH_S3 "$loss_rate, ";
            foreach my $opt_swap_mat (sort {$a <=> $b} (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT} })) {
                
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = -1;
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = -1;
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = -1;

                foreach my $opt_type (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE} }) {

                    if($opt_type == 0) {
                        foreach my $quantization (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION} }) {

                            my $tmp_mse = 0;
                            my $tmp_mae = 0;
                            my $tmp_cc = 0;
                            foreach my $seed (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED} }) {
                                $tmp_mse += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{MSE};
                                $tmp_mae += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{MAE};
                                $tmp_cc += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{SEED}{$seed}{CC};
                            }
                            $tmp_mse /= scalar(@seeds);
                            $tmp_mae /= scalar(@seeds);
                            $tmp_cc /= scalar(@seeds);

                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1);
                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1);
                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1);
                        }
                    }
                    elsif($opt_type == 1) {
                        foreach my $chunk_size (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE} }) {
                            foreach my $sel_chunks (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS} }) {

                                my $tmp_mse = 0;
                                my $tmp_mae = 0;
                                my $tmp_cc = 0;
                                foreach my $seed (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED} }) {
                                    $tmp_mse += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{MSE};
                                    $tmp_mae += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{MAE};
                                    $tmp_cc += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{SEED}{$seed}{CC};
                                }
                                $tmp_mse /= scalar(@seeds);
                                $tmp_mae /= scalar(@seeds);
                                $tmp_cc /= scalar(@seeds);

                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE} == -1);
                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE} == -1);
                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC} == -1);
                            }
                        }
                    }
                    else {
                        die "no such type : $opt_type\n";
                    }
                }
                print FH_S1 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MSE}.", ";
                print FH_S2 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{MAE}.", ";
                print FH_S3 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_SWAP_MAT}{$opt_swap_mat}{CC}.", ";
            }


            #############
            ## Compare Type
            #############
            print FH_T1 "$loss_rate, ";
            print FH_T2 "$loss_rate, ";
            print FH_T3 "$loss_rate, ";
            foreach my $opt_type (sort {$a <=> $b} (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE} })) {
                
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} = -1;
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} = -1;
                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} = -1;

                if($opt_type == 0) {
                    foreach my $quantization (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION} }) {
                        foreach my $opt_swap_mat (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT} }) {

                            my $tmp_mse = 0;
                            my $tmp_mae = 0;
                            my $tmp_cc = 0;
                            foreach my $seed (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED} }) {

                                $tmp_mse += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE};
                                $tmp_mae += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE};
                                $tmp_cc += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{QUANTIZATION}{$quantization}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC};
                            }
                            $tmp_mse /= scalar(@seeds);
                            $tmp_mae /= scalar(@seeds);
                            $tmp_cc /= scalar(@seeds);

                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} == -1);
                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} == -1);
                            $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} == -1);
                        }
                    }
                }
                elsif($opt_type == 1) {
                    foreach my $chunk_size (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE} }) {
                        foreach my $sel_chunks (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS} }) {
                            foreach my $opt_swap_mat (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT} }) {

                                my $tmp_mse = 0;
                                my $tmp_mae = 0;
                                my $tmp_cc = 0;
                                foreach my $seed (keys %{ $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED} }) {
                                    $tmp_mse += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MSE};
                                    $tmp_mae += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{MAE};
                                    $tmp_cc += $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CHUNK_SIZE}{$chunk_size}{SEL_CHUNKS}{$sel_chunks}{OPT_SWAP_MAT}{$opt_swap_mat}{SEED}{$seed}{CC};
                                }
                                $tmp_mse /= scalar(@seeds);
                                $tmp_mae /= scalar(@seeds);
                                $tmp_cc /= scalar(@seeds);

                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} = $tmp_mse if($tmp_mse < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE} == -1);
                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} = $tmp_mae if($tmp_mae < $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE} == -1);
                                $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} = $tmp_cc if($tmp_cc > $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} or $data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC} == -1);
                            }
                        }
                    }
                }
                else {
                    die "no such type : $opt_type\n";
                }

                print FH_T1 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MSE}.", ";
                print FH_T2 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{MAE}.", ";
                print FH_T3 "".$data{TRACE}{"$file"}{GROUP_SIZE}{$group_size}{LOSS_RATE}{$loss_rate}{OPT_TYPE}{$opt_type}{CC}.", ";
            }
            

            print FH_S1 "\n";
            print FH_S2 "\n";
            print FH_S3 "\n";
            print FH_T1 "\n";
            print FH_T2 "\n";
            print FH_T3 "\n";
        }
    }

    close FH_S1;
    close FH_S2;
    close FH_S3;
    close FH_T1;
    close FH_T2;
    close FH_T3;


    my $escape_output_dir = $output_dir."/";
    $escape_output_dir =~ s{\/}{\\\/}g;
    my $escape_figure_dir = $figure_dir."/";
    $escape_figure_dir =~ s{\/}{\\\/}g;

    my $method = "swap";
    my $eval   = "mse";
    my $col_size = 2 + scalar(@opt_swap_mats) - 1;
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

    $method = "type";
    $eval   = "mse";
    $col_size = 2 + scalar(@opt_types) - 1;
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
