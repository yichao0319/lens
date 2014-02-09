#!/bin/perl

use strict;


######################################################################################
## Traffic 
######################################################################################
my @num_anomalies = (0.05, 0.1);
my @sigma_mags     = (0.4, 0.8);

foreach my $num_anomaly (@num_anomalies) {
    foreach my $sigma_mag (@sigma_mags) {
        print "# anomalies = $num_anomaly, size = $sigma_mag\n";
        my $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 672, 23, 23, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        # $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.rnc.all.bin10.txt', 144, 13, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        # print $cmd."\n";
        # `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 110, 50, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;



        $cmd = "sed 's/NUM_ANOM/$num_anomaly/g; s/SIGMA_MAG/$sigma_mag/g;' plot.cdf.traffic.plot > tmp.cdf.plot";
        `$cmd`;

        $cmd = "gnuplot tmp.cdf.plot";
        `$cmd`;
    }
}


######################################################################################
## RSSI 
######################################################################################
@num_anomalies = (0.05, 0.1);
@sigma_mags    = (2, 4);

foreach my $num_anomaly (@num_anomalies) {
    foreach my $sigma_mag (@sigma_mags) {
        print "# anomalies = $num_anomaly, size = $sigma_mag\n";
        
        my $cmd = "matlab -r \"analyze_low_rank_2d('../condor_data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 10000, 16, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;

        $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
        print $cmd."\n";
        `$cmd`;


        $cmd = "sed 's/NUM_ANOM/$num_anomaly/g; s/SIGMA_MAG/$sigma_mag/g;' plot.cdf.rssi.plot > tmp.cdf.plot";
        `$cmd`;

        $cmd = "gnuplot tmp.cdf.plot";
        `$cmd`;
    }
}






######################################################################################
## all 
######################################################################################
my $num_anomaly = 0;
my $sigma_mag = 0;
my $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_totem/tm/', 'tm_totem.', 672, 23, 23, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../condor_data/subtask_parse_abilene/tm/', 'tm_abilene.od.', 1008, 11, 11, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.bs.bs3.all.bin10.txt', 144, 472, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

# $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_huawei_3g/bs_tm/', 'tm_3g.cell.rnc.all.bin10.txt', 144, 13, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
# print $cmd."\n";
# `$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_sjtu_wifi/tm/', 'tm_sjtu_wifi.ap_load.all.bin600.top50.txt', 110, 50, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../condor_data/csi/mobile/', 'Mob-Recv1run1.dat0_matrix.mat_dB.txt', 1000, 90, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

# $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_sensor/tm/', 'tm_sensor.temp.bin600.txt', 144, 54, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
# print $cmd."\n";
# `$cmd`;

# $cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_sensor/tm/', 'tm_sensor.light.bin600.txt', 144, 54, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
# print $cmd."\n";
# `$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_ron/tm/', 'tm_ron1.latency.', 494, 12, 12, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_telos_rssi/tm/', 'tm_telos_rssi.txt', 10000, 16, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "matlab -r \"analyze_low_rank_2d('../processed_data/subtask_parse_multi_loc_rssi/tm/', 'tm_multi_loc_rssi.txt', 500, 895, 1, 0.01, $num_anomaly, $sigma_mag);exit;\"";
print $cmd."\n";
`$cmd`;

$cmd = "sed 's/NUM_ANOM/$num_anomaly/g; s/SIGMA_MAG/$sigma_mag/g;' plot.cdf.plot > tmp.cdf.plot";
`$cmd`;

$cmd = "gnuplot tmp.cdf.plot";
`$cmd`;

