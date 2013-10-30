#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.10.29 @ UT Austin
##
## - input:
##   1. --sjtu: for SJTU machines
##      a) gps: group by lat lng
##         --res: resolution
##      b) ap: group by AP
##      c) ip: group by ip
##         --mask: IP mask
##      d) bgp: group by BGP prefix
##   2. --other: for other machines
##      a) gps: group by lat lng
##         --res: resolution
##      b) ip: group by ip
##         --mask: IP mask
##      c) bgp: group by BGP prefix
##      d) zip: group by zip
##      e) region: group by region code
##      f) country: group by country code
##
## - output:
##
## - e.g.
##      perl sort_ips.pl -sjtu gps -other gps -res 0.01
##
##########################################

use strict;
use Getopt::Long;

use lib "../utils";

use IPTool;
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


#############
# Variables
#############
my $input_trace_dir  = "../processed_data/subtask_parse_sjtu_wifi/text";
my $all_ips_dir      = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $table_dir        = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $invalid_dir      = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $account_dir      = "../data/sjtu_wifi/RADIUS";
my $ap_dir           = "../data/sjtu_wifi";
my $output_dir       = "../processed_data/subtask_parse_sjtu_wifi/sort_ips";

my $table_file   = "ip_geo_as_table.txt";
my $invalid_file = "ip_geo_as_invalid.txt";
my $all_ips_file = "all_ips.txt";
my $ap_file      = "AP_Location.csv";


my $sjtu;
my $other;
my $res;
my $mask;

my %ip_table_info = ();
my %invalid_info = ();
my %account_info = ();
my %ap_info = ();
my %ip_info = ();
my %group_info = ();


my $cnt_sjtu = 0;
my $cnt_missing_sjtu = 0;


#############
# check input
#############
GetOptions ('sjtu=s'  => \$sjtu, 
            'other=s' => \$other,
            'res:s'   => \$res, 
            'mask=s'  => \$mask);
$res += 0; $mask += 0;
if($DEBUG0) {
    print "sjtu=$sjtu, other=$other\n";
    print "res=$res, mask=$mask\n";
}
if($sjtu eq "gps" or $other eq "gps") {
    die "Group by gps, res should not be 0\n" if($res == 0);
}


#############
# Main starts
#############

#############
## Read RADIUS account data
#############
print "Read RADIUS account data: $account_dir\n" if($DEBUG2);
%account_info = IPTool::read_account_info($account_dir);
print "  size=".scalar(keys %{ $account_info{USER_IP} })."\n" if($DEBUG1);


#############
## Read AP location
#############
print "Read AP location: $ap_dir/$ap_file\n" if($DEBUG2);
%ap_info = IPTool::read_ap_info("$ap_dir/$ap_file");
print "  size=".scalar(keys %{ $ap_info{AP_MAC} })."\n" if($DEBUG1);


#############
# read IP GEO/AS Info
#############
print "read IP GEO/AS Info\n" if($DEBUG2);
%ip_table_info = IPTool::read_geo_as_table("$table_dir/$table_file");


#############
# read invalid IPs
#############
print "read invalid IPs\n" if($DEBUG2);

open FH, "$invalid_dir/$invalid_file" or die $!;
while(<FH>) {
    chomp;
    
    my $ip = $_;
    next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);

    print "- ".$ip."\n" if($DEBUG0);
    $invalid_info{IP}{$ip} = 1;
}
close FH;


#############
## get all ips
#############
print "get all ips\n" if($DEBUG2);

open FH, "$all_ips_dir/$all_ips_file" or die $!;
while(<FH>) {
    chomp;
    my $ip = $_;
    next unless($ip =~ /\d+\.\d+\.\d+\.\d+/);
    

    ###################
    ## skip invalid IPs and unknown IPs
    ###################
    next if(exists $invalid_info{IP}{$ip});
    next unless(exists $ip_table_info{IP}{$ip});
    die "should not have duplicate IP\n" if(exists $ip_info{IP}{$ip});

    $ip_info{IP}{$ip} = $ip_table_info{IP}{$ip};


    ###################
    ## SJTU machines
    ###################
    if(exists $account_info{USER_IP}{$ip}) {
        $cnt_sjtu ++;

        print "  $ip\n" if($DEBUG0);
        if($sjtu eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            print "($lat, $lng) = $group\n" if($DEBUG0);

            $group_info{START_GRP} = $group unless(exists $group_info{START_GRP});
            $group_info{GROUP}{$group}{LAT} = $lat;
            $group_info{GROUP}{$group}{LNG} = $lng;
        }
    }
    else {

        ## this IP is supposed to be SJTU machine but cannot find it in Account info
        if($ip =~ /111\.186\.\d+\.\d+/) {
            $cnt_missing_sjtu ++;
        }

        if($other eq "gps") {
            my $lat = $ip_info{IP}{$ip}{LAT} + 0;
            my $lng = $ip_info{IP}{$ip}{LNG} + 0;

            my $group = "".(int($lat / $res)).";".(int($lng / $res));
            print "($lat, $lng) = $group\n" if($DEBUG0);

            $group_info{GROUP}{$group}{LAT} = $lat;
            $group_info{GROUP}{$group}{LNG} = $lng;
        }
    }
}
close FH;


print "# sjtu devices: $cnt_sjtu\n";
print "# sjtu missing devices: $cnt_missing_sjtu\n";
print "# group: ".scalar(keys %{ $group_info{GROUP} } )."\n";


################
## start to sort
################
my $cur_ind = 1;
if($sjtu eq "gps") {
    my @tmp_grps = keys %{ $group_info{GROUP} };

    my $cur_grp = $group_info{START_GRP};
    my $cur_lat = $group_info{GROUP}{$cur_grp}{LAT};
    my $cur_lng = $group_info{GROUP}{$cur_grp}{LNG};
    $group_info{GROUP}{$cur_grp}{IND} = $cur_ind;

    @tmp_grps = grep { $_ != $cur_grp } @tmp_grps;

    while(scalar(@tmp_grps) > 0) {
        
        my $min_dist = -1;
        my $min_grp;
        foreach my $this_grp (@tmp_grps) {
            my $this_lat = $group_info{GROUP}{$this_grp}{LAT};
            my $this_lng = $group_info{GROUP}{$this_grp}{LNG};

            my $this_dist = MyUtil::pos2dist($cur_lat, $cur_lng, $this_lat, $this_lng);
            if($this_dist < $min_dist or $min_dist == -1) {
                $min_dist = $this_dist;
                $min_grp = $this_grp;
            }
        }

        @tmp_grps = grep { $_ != $min_grp } @tmp_grps;
        $cur_grp = $min_grp;
        $cur_lat = $group_info{GROUP}{$min_grp}{LAT};
        $cur_lng = $group_info{GROUP}{$min_grp}{LNG};

        $cur_ind ++;
        $group_info{GROUP}{$cur_grp}{IND} = $cur_ind;
    }
}



################
## output ip => index (start from 1)
################
if($sjtu eq "gps") {
    open FH, "> $output_dir/sort_ips.$sjtu.$other.$res.txt" or die $!;
    foreach my $ip (sort {$a cmp $b} (keys %{ $ip_info{IP} })) {
        my $lat = $ip_info{IP}{$ip}{LAT} + 0;
        my $lng = $ip_info{IP}{$ip}{LNG} + 0;

        my $group = "".(int($lat / $res)).";".(int($lng / $res));
        my $index = $group_info{GROUP}{$group}{IND};

        print FH "$ip, $index\n";
    }
    close FH;
}


