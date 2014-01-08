#!/bin/perl

##########################################
## Author: Yi-Chao Chen
## 2013.12.23 @ UT Austin
##
## - input:
##
## - output:
##
## - e.g.
##
##########################################

use strict;
use POSIX;
use List::Util qw(first max maxstr min minstr reduce shuffle sum);
use lib "../utils";

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
my $input_dir  = "";
my $output_dir = "";


#############
# check input
#############

#############
# Main starts
#############

my @seeds = (1 .. 5);
my @opt_types = ("lens", "srmf", "lens_knn", "srmf_knn", "lens_knn2");

foreach my $type (@opt_types) {
   foreach my $seed (@seeds) {
      my $cmd = "rm tmp*$type*seed$seed.sh";
      print $cmd."\n";
      `$cmd`;

      $cmd = "rm tmp*$type*seed$seed.*";
      print $cmd."\n";
      `$cmd`;

   }
}
