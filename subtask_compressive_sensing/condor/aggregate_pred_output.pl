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

my $num_frames;
my $width;
my $height;
my @seeds;
my @group_sizes;
my @ranks;
my @opt_swap_mats;
my @opt_types;
my @opt_dims;
my @sigma_mags;
my @sigma_noises;
my @threshs;
my @files;


# @files = ("tm_totem.", "X", "tm_3g_region_all.res0.006.bin10.sub.", "tm_download.sjtu_wifi.ap_load.600.txt");
# @files = ("tm_3g.cell.bs.bs6.all.bin10.txt");
@files = ("tm_3g.cell.bs.bs1.all.bin10.txt");

@seeds = (1, 2, 3, 4, 5);
@opt_swap_mats = ("org");
@opt_types = ("srmf_knn", "lens_knn2", "srmf_lens_knn2");
@opt_dims = ("2d");

@sigma_mags = (0, 0.2, 0.4, 0.6, 0.8, 1);
@sigma_noises = (0);
@threshs = (-1);

for my $file_name (@files) {    
    
    #############
    ## WiFi
    if($file_name eq "tm_upload.sjtu_wifi.ap_load.600.txt") {
        $num_frames = 100;
        $width = 250;
        $height = 1;

        @group_sizes = (100);
        @ranks = (100);
    }
    elsif($file_name eq "tm_download.sjtu_wifi.ap_load.600.txt") {
        $num_frames = 100;
        $width = 250;
        $height = 1;

        @group_sizes = (100);
        @ranks = (100);
    }
    ###############
    ## 3G
    elsif($file_name eq "tm_3g_region_all.res0.006.bin10.sub.") {
        $num_frames = 100;
        $width = 21;
        $height = 26;

        @group_sizes = (100);
        @ranks = (100);
    }
    elsif($file_name eq "tm_3g.cell.bs.bs1.all.bin10.txt") {
        $num_frames = 100;
        $width = 458;
        $height = 1;

        @group_sizes = (100);
        @ranks = (100);
    }
    elsif($file_name eq "tm_3g.cell.bs.bs6.all.bin10.txt") {
        $num_frames = 100;
        $width = 240;
        $height = 1;

        @group_sizes = (100);
        @ranks = (100);
    }
    #############
    ## GEANT
    elsif($file_name eq "tm_totem.") {
        $num_frames = 100;
        $width = 23;
        $height = 23;

        @group_sizes = (100);
        @ranks = (8);
    }
    #############
    ## Abilene
    elsif($file_name eq "X") {
        $num_frames = 100;
        $width = 121;
        $height = 1;

        @group_sizes = (100);
        @ranks = (8);
    }


    for my $group_size (@group_sizes) {
        for my $rank (@ranks) {
            for my $opt_swap_mat (@opt_swap_mats) {
                for my $opt_dim (@opt_dims) {

                    for my $sigma_mag (@sigma_mags) {
                        for my $sigma_noise (@sigma_noises) {
                            for my $thresh (@threshs) {
                                plot_pure_rand1($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $opt_swap_mat, $opt_dim, $sigma_mag, $sigma_noise, $thresh);
                            }
                        }
                    }
                }
            }
        }
    }
}



1;

sub plot_pure_rand1 {
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $opt_swap_mat, $opt_dim, $sigma_mag, $sigma_noise, $thresh) = @_;

    my $output_dir = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/output";

    ## PureRandLoss
    my $drop_ele_mode = "elem";
    my $drop_mode = "ind";
    my $elem_frac = 1;
    my @loss_rates = (0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.93, 0.95, 0.97, 0.98, 0.99);
    my $burst_size = 1;


    my @opt_types = ("srmf_knn", "lens_knn2", "srmf_lens_knn2");
    my @seeds = (1 .. 5);

    ## scheme - metric - loss rate
    my %info = ();
    my $num_ret = 15;


    foreach my $ti (0 .. @opt_types-1) {
        my $opt_type = $opt_types[$ti];
        $info{SCHEME}{$opt_type} = ();

        foreach my $lri (0 .. @loss_rates-1) {
            my $loss_rate = $loss_rates[$lri];

            
            ## metric - [values]
            my %rets;
            
            for my $seed (@seeds) {
                my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.$opt_swap_mat.".$opt_type.".".$opt_dim.".".$drop_ele_mode.".".$drop_mode.".elem".$elem_frac.".loss".$loss_rate.".burst".$burst_size.".anom".$sigma_mag.".noise".$sigma_noise.".thresh$thresh.seed$seed.txt";
                unless(-e $this_file_name) {
                    # print "$this_file_name\n";
                    next;
                }


                # print "$this_file_name\n";

                open FH, $this_file_name or die $!;
                while(<FH>) {
                    chomp;
                    my @tmp = split(/, /, $_);
                    
                    for my $mi (0 .. $num_ret-1) {
                        if($tmp[$mi] =~ /nan/i) { $tmp[$mi] = 0;  }
                        else                    { $tmp[$mi] += 0; }

                        push(@{ $rets{METRIC}{$mi}{VAL} }, $tmp[$mi]);

                        # print "'".$tmp[$mi]."', ";
                    }
                    # print "\n";
                }
                close FH;
            }


            ## get avg
            for my $mi (0 .. $num_ret-1) {
                if(exists $rets{METRIC}{$mi}{VAL}) {
                    $info{SCHEME}{$opt_type}{METRIC}{$mi}{LR}{$loss_rate} = MyUtil::average(\@{ $rets{METRIC}{$mi}{VAL} });
                }
                else {
                    $info{SCHEME}{$opt_type}{METRIC}{$mi}{LR}{$loss_rate} = 0;
                }
            }
            
        }
    }

    
    open FH1, ">$output_dir/pred.$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.$opt_swap_mat.".$opt_dim.".PureRandLoss.anom".$sigma_mag.".noise".$sigma_noise.".thresh$thresh.txt";
    open FH2, ">$output_dir/dect.$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.$opt_swap_mat.".$opt_dim.".PureRandLoss.anom".$sigma_mag.".noise".$sigma_noise.".thresh$thresh.txt";
    

    foreach my $lri (0 .. @loss_rates-1) {
        my $loss_rate = $loss_rates[$lri];

        print FH1 $loss_rate.", ";
        
        ## MSE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH1 $info{SCHEME}{$opt_type}{METRIC}{0}{LR}{$loss_rate}.", ";
        }

        ## MAE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH1 $info{SCHEME}{$opt_type}{METRIC}{1}{LR}{$loss_rate}.", ";
        }

        ## y ratio
        print FH1 $info{SCHEME}{"lens_knn2"}{METRIC}{12}{LR}{$loss_rate}.", ";

        ## y values
        print FH1 $info{SCHEME}{"lens_knn2"}{METRIC}{13}{LR}{$loss_rate}."\n";
        

        print FH2 $loss_rate.", ";

        ## prec
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH2 $info{SCHEME}{$opt_type}{METRIC}{8}{LR}{$loss_rate}.", ";
        }

        ## recall
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH2 $info{SCHEME}{$opt_type}{METRIC}{9}{LR}{$loss_rate}.", ";
        }

        ## f1
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH2 $info{SCHEME}{$opt_type}{METRIC}{10}{LR}{$loss_rate}.", ";
        }

        ## jaccard
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH2 $info{SCHEME}{$opt_type}{METRIC}{11}{LR}{$loss_rate}.", ";
        }

        ## best thresh
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            print FH2 $info{SCHEME}{$opt_type}{METRIC}{14}{LR}{$loss_rate}.", ";
        }
        print FH2 "\n";
    }

    close FH1;
    close FH2;
}
