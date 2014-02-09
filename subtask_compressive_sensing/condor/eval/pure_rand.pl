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

my $PLOT_PURE_RAND1 = 1;
my $PLOT_ELEM_RAND1 = 1;
my $PLOT_ELEM_SYN1  = 1;
my $PLOT_PRED1      = 1;
my $PLOT_TIME_RAND1 = 1;
my $PLOT_ROW_RAND1  = 1;
my $PLOT_COL_RAND1  = 1;


#############
# Constants
#############
my $NUM_CURVE = 12;


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
my @periods;
my @opt_swap_mats;
my @opt_types;
my @opt_dims;
my @num_anomalies;
my @sigma_mags;
my @sigma_noises;
my @threshs;
my @files;
my $drop_ele_mode;
my $drop_mode;
my @elem_fracs;
my $elem_frac;
my @loss_rates;
my $burst_size;



# @files = ("tm_abilene.od.");
# @files = ("tm_totem.");
# @files = ("tm_3g.cell.bs.bs3.all.bin10.txt");
# @files = ("tm_3g.cell.rnc.all.bin10.txt");
# @files = ("tm_3g.cell.load.top200.all.bin10.txt");
# @files = ("tm_sjtu_wifi.ap_load.all.bin600.top50.txt");
# @files = ("128.83.158.127_file.dat0_matrix.mat.txt");
# @files = ("128.83.158.50_file.dat0_matrix.mat.txt");
# @files = ("Mob-Recv1run1.dat0_matrix.mat_dB.txt");
# @files = ("Mob-Recv1run1.dat1_matrix.mat_dB.txt");
# @files = ("tm_ron1.latency.");
# @files = ("tm_telos_rssi.txt");
# @files = ("tm_multi_loc_rssi.txt");

@files = ("tm_abilene.od.", "tm_totem.", "tm_3g.cell.bs.bs3.all.bin10.txt", "tm_sjtu_wifi.ap_load.all.bin600.top50.txt", "Mob-Recv1run1.dat0_matrix.mat_dB.txt", "tm_ron1.latency.", "tm_telos_rssi.txt", "tm_multi_loc_rssi.txt");


@seeds = (1 .. 1);
# "srmf_knn" "lens_knn2" "srmf_lens_knn2" "lens_st_knn2" "srmf_lens_st_knn" "srmf" "lens" "lens_st" "knn"
# @opt_types = ("srmf", "srmf_knn", "lens", "lens_knn2", "srmf_lens_knn2", "lens_st", "lens_st_knn2", "srmf_lens_st_knn");
# @opt_types = ("srmf", "srmf_knn", "lens", "lens_st", "lens_st_knn2", "srmf_lens_st_knn", "base", "svd", "svd_base", "svd_base_knn", "nmf");
# @opt_types = ("srmf", "srmf_knn", "lens", "lens_st", "lens_st_knn2", "srmf_lens_st_knn", "base", "svd", "svd_base", "svd_base_knn", "nmf");
@opt_types = ("svd_base", "svd_base_knn", "srmf", "srmf_knn", "lens_st", "lens_st_knn2", "srmf_lens_st_knn");


my $opt_swap_mat = "org";
my $opt_dim = "2d";

my $num_anomaly = 0.05;
my $sigma_mag = 0.4;
my $sigma_noise = 0;
my $thresh = 0;

$drop_ele_mode = "elem";
$drop_mode = "ind";
$elem_frac = 1;
$burst_size = 1;
$input_dir = "/u/yichao/anomaly_compression/processed_data/subtask_compressive_sensing/condor/output";
# $input_dir  = "/u/yichao/anomaly_compression/condor_data/subtask_compressive_sensing/condor/output";

for my $file_name (@files) {    
    print $file_name."\n";
    my ($num_frames, $width, $height, $group_size, $rank, $period) = get_trace_property($file_name);

    plot_pure_rand($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, \@opt_types);
}



1;

sub plot_pure_rand {
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh, $opt_types_ref) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 0;  ## missing files
    my $DEBUG5 = 0;  ## get results


    my @opt_types = @$opt_types_ref;
    # my @loss_rates = (0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.93, 0.95, 0.97, 0.98, 0.99);
    my @loss_rates = (0.05, 0.1, 0.2, 0.4, 0.6, 0.8, 0.9, 0.95);

    
    
    foreach my $lri (0 .. @loss_rates-1) {
        my $loss_rate = $loss_rates[$lri];

        
        ## MAE
        foreach my $ti (0 .. @opt_types-1) {
            my $opt_type = $opt_types[$ti];

            my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
            print ", " if($ti > 0);
            print $rets{METRIC}{1}{AVG};
        }
        print "\n";

        ######################################

        # print FH2 $loss_rate;

        # ## prec
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{8}{AVG};
        # }

        # ## recall
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{9}{AVG};
        # }

        # ## f1
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{10}{AVG};
        # }

        # ## jaccard
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{11}{AVG};
        # }

        # ## best thresh
        # foreach my $ti (0 .. @opt_types-1) {
        #     my $opt_type = $opt_types[$ti];

        #     my %rets = get_results($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh);
        #     print FH2 ", ".$rets{METRIC}{12}{AVG};
        # }
        # print FH2 "\n";
    }
}



sub get_results {
    # srmf_based_pred.FILENAME.NUM_FRAMES.WIDTH.HEIGHT.GROUP_SIZE.rRANK.periodPERIOD.OPT_SWAP_MAT.OPT_TYPE.OPT_DIM.DROP_ELE_MODE.DROP_MODE.elemELEM_FRAC.lossLOSS_RATE.burstBURST_SIZE.naNUM_ANOM.anomSIGMA_MAG.noiseSIGMA_NOISE.threshTHRESH.seedSEED.txt
    my ($func, $file_name, $num_frames, $width, $height, $group_size, $rank, $period, $opt_swap_mat, $opt_type, $opt_dim, $drop_ele_mode, $drop_mode, $elem_frac, $loss_rate, $burst_size, $num_anomaly, $sigma_mag, $sigma_noise, $thresh) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 1;
    my $DEBUG4 = 1;  ## missing files
    my $DEBUG5 = 0;  ## get results

    my %rets;
    my $num_ret = 15;
    # my @seeds = (1...5);

    
    for my $seed (@seeds) {
        my $this_file_name = "$input_dir/$func.$file_name.$num_frames.$width.$height.$group_size.r$rank.period$period.$opt_swap_mat.$opt_type.$opt_dim.$drop_ele_mode.$drop_mode.elem$elem_frac.loss$loss_rate.burst$burst_size.na$num_anomaly.anom$sigma_mag.noise$sigma_noise.thresh$thresh.seed$seed.txt";
        
        unless(-e $this_file_name) {
            print "$this_file_name\n" if($DEBUG4);
            next;
        }


        # print "$this_file_name\n" if($DEBUG5);

        open FH, $this_file_name or die $!;
        while(<FH>) {
            chomp;
            my @tmp = split(/, /, $_);
            
            for my $mi (0 .. @tmp-1) {
                if($tmp[$mi] =~ /nan/i) { $tmp[$mi] = 0;  }
                else                    { $tmp[$mi] += 0; }

                push(@{ $rets{METRIC}{$mi}{VAL} }, $tmp[$mi]);

                print "'".$tmp[$mi]."', " if($DEBUG5);
            }
            print "\n" if($DEBUG5);
        }
        close FH;
    }


    ## get avg
    for my $mi (0 .. $num_ret-1) {
        if(exists $rets{METRIC}{$mi}{VAL}) {
            $rets{METRIC}{$mi}{AVG} = MyUtil::median(\@{ $rets{METRIC}{$mi}{VAL} });
        }
        else {
            $rets{METRIC}{$mi}{AVG} = 0;
        }
    }

    return %rets;

}


sub get_trace_property {
    my ($file_name) = @_;

    my $num_frames;
    my $width;
    my $height;
    my $group_size;
    my $rank;
    my $period;


    #############
    ## WiFi
    if($file_name eq "tm_sjtu_wifi.ap_load.all.bin600.top50.txt") {
        $num_frames = 100;
        $width = 50;
        $height = 1;

        $group_size = 100;
        $rank = 8;
        $period = 1;

    }
    ###############
    ## 3G
    elsif($file_name eq "tm_3g.cell.bs.bs3.all.bin10.txt") {
        # $num_frames = 100;
        $num_frames = 144;
        $width = 472;
        $height = 1;

        $group_size = 144;
        $rank = 64;
        $period = 1;

    }
    #############
    ## GEANT
    elsif($file_name eq "tm_totem.") {
        # $num_frames = 100;
        $num_frames = 672;
        $width = 23;
        $height = 23;

        $group_size = 672;
        $rank = 8;
        $period = 1;

    }
    #############
    ## Abilene
    elsif($file_name eq "X") {
        $num_frames = 1008;
        $width = 121;
        $height = 1;

        $group_size = 1008;
        $rank = 8;
        $period = 1;

    }
    elsif($file_name eq "tm_abilene.od.") {
        # $num_frames = 100;
        $num_frames = 1008;
        $width = 11;
        $height = 11;

        $group_size = 1008;
        $rank = 8;
        $period = 1;
    }
    #############
    ## CSI
    elsif($file_name eq "Mob-Recv1run1.dat0_matrix.mat_dB.txt") {
        $num_frames = 1000;
        $width = 90;
        $height = 1;

        $group_size = 1000;
        $rank = 32;
        $period = 1;

    }
    #############
    ## RON
    elsif($file_name eq "tm_ron1.latency.") {
        $num_frames = 494;
        $width = 12;
        $height = 12;

        $group_size = 494;
        $rank = 8;
        $period = 1;

    }
    #############
    ## RSSI - telos
    elsif($file_name eq "tm_telos_rssi.txt") {
        $num_frames = 1000;
        $width = 16;
        $height = 1;

        $group_size = 1000;
        $rank = 8;
        $period = 1;
    }
    #############
    ## RSSI - multi location
    elsif($file_name eq "tm_multi_loc_rssi.txt") {
        $num_frames = 500;
        $width = 895;
        $height = 1;

        $group_size = 500;
        $rank = 32;
        $period = 1;

    }
    else {
        die "no such file: $file_name\n";
    }

    return ($num_frames, $width, $height, $group_size, $rank, $period);
}