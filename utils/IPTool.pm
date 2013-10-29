
package IPTool;

use strict;


######################################
## ip2geo
##   http://freegeoip.net/
## - input
##   1. ip
## - output
##   $ret_ip, $CountryCode, $CountryName, $RegionCode, $RegionName, $city, $zip, $lat, $lng, $MetroCode, $AreaCode
######################################
sub ip2geo {
    my ($ip) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 0;

    my $result = `curl -s freegeoip.net/{csv}/{$ip}`;
    print $result if($DEBUG1);

    my @tmp = split(/,/, $result);
    my @ret;
    foreach my $ele (@tmp) {
        if($ele =~ /^"(.*)"$/) {
            push(@ret, $1);
        }
    }
    print join("|", @ret)."\n" if($DEBUG1);

    return @ret;
}


######################################
## ip2asn
##   http://www.team-cymru.org/Services/ip-to-asn.html
## - input
##   1. ip
##   2. time
## - output
##   ($asn, $query_ip, $bgp_prefix, $country, $registry
######################################
sub ip2asn {
    my ($ip, $time) = @_;

    my $DEBUG0 = 0;
    my $DEBUG1 = 0;

    # whois -h whois.cymru.com " -v 216.90.108.31 2005-12-25 13:23:01 GMT"
    my $result = `whois -h whois.cymru.com " -c -r -p -u -w -f -o -b $ip $time"`;
    print $result if($DEBUG1);

    my @tmp = split(/\|/, $result);
    my @ret;
    foreach my $ele (@tmp) {
        if($ele =~ /\s*([\w\d\.-\/]*)\s+/) {
            push(@ret, $1);
        }
    }
    print join("|", @ret)."\n" if($DEBUG1);

    return @ret;
}

1;
