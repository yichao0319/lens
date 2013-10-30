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
my $input_dir   = "../processed_data/subtask_parse_sjtu_wifi/text";
my $table_dir   = "../processed_data/subtask_parse_sjtu_wifi/ip_info";
my $output_dir = "";

my $table_file   = "ip_geo_as_table.txt";

my $sjtu;
my $other;
my $res;
my $mask;

my %ip_table_info = ();


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
# read IP GEO/AS Info
#############
print "read IP GEO/AS Info\n" if($DEBUG2);
%ip_table_info = IPTool::read_geo_as_table("$table_dir/$table_file");


#############
## search all traces
#############
print "search all traces\n" if($DEBUG2);

opendir(DIR, "$input_dir") or die $!;
while (my $file = readdir(DIR)) {
    next if($file =~ /^\.+/);  ## don't show "." and ".."
    next if(-d "$input_dir/$file");  ## don't show directories
    next unless($file =~ /gz$/);

    print "$file\n";
    

    #############
    ## open file
    #############
}
closedir(DIR);