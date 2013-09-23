import sys
import os
from numpy import array
import numpy
from operator import itemgetter
import locale
# import Gnuplot
from subprocess import call
import re

sys.path.append("../utils")
from data import *
from utils import *
from googlemaps import GoogleMaps


################
## DEBUG
################
DEBUG0 = False       ## Don't show
DEBUG1 = True        ## print for debug
DEBUG2 = True        ## Program Flow
DEBUG3 = False       ## Data hierarchy
DEBUG4 = True        ## Should not happen


################
## Functions
################

################
## process_data
def process_data():
    if len(DATA) == 0:
        return

    if DEBUG3:
        print DATA.keys()
    
    this_user = set([])

    if city == 'Airport' or city == 'SXSW':
        _DATA_ = DATA['VENUE_DATA']
    else:
        _DATA_ = DATA['VENUE_DETAIL']

    for v in _DATA_:

        v_data = _DATA_[v]
        
        if city == 'Airport':
            v_info = DATA_AIR[v]
        else:
            v_info = DATA['VENUE_INFO'][v]

        if DEBUG3:
            #print v_data
            print "  " + str(v_data.keys())

        for u in v_data['checkins']:
            c_data = v_data['checkins'][u]
            
            if DEBUG3:
                print "    " + str(c_data.keys())

            total_user.add(c_data['userid'])
            this_user.add(c_data['userid']) 
            
            if DEBUG3:
                print "  " + str(v_info.keys())
            
            c_data['lat'] = v_info['lat']
            c_data['lng'] = v_info['lng']
        
            if v_info.has_key('name'):
                c_data['venue'] = v_info['name']
                c_data['venue_id'] = v_info['id']
            else:
                if DEBUG4:
                    print "XXX: the venue does not have a name!!!!"
                    sys.exit(1)

                c_data['venue'] = 'airport'
                c_data['venue_id'] = 0

            if not user_hist.has_key(c_data['userid']):
                ci_dict = dict()
                ci_dict[c_data['ts']] = c_data
                user_hist[c_data['userid']] = ci_dict
            else:
                user_hist[c_data['userid']][c_data['ts']] = c_data

    if DEBUG2:
        print 'user len: ' + str(len(this_user))
        print 'total user: ' + str(len(total_user))
## end process_data
################


################
## generate_TM
def generate_TM():
    TM = dict()
    # Airports = dict()
    for uid in user_hist:
        if len(user_hist[uid]) < 2:
            continue

        sort_hist = sorted(user_hist[uid].items(), key=itemgetter(0)) #, reverse=True)
        hl = len(sort_hist)
        for i in range(0,hl-1):
            src = sort_hist[i][1]['venue_id']
            dst = sort_hist[i+1][1]['venue_id']
            
            # TM
            if not TM.has_key(src):
                dests = dict()
                dests[dst] = 1
                TM[src] = dests
            else:
                if not TM[src].has_key(dst):
                    TM[src][dst] = 1
                else:
                    TM[src][dst] += 1
            
            # Airports
            # if not Airports.has_key(src):
            #     Airports[src] = sort_hist[i][1]['lat'] + 90 + sort_hist[i][1]['lng'] + 180
            # if not Airports.has_key(dst):
            #     Airports[dst] = sort_hist[i+1][1]['lat'] + 90 + sort_hist[i+1][1]['lng'] + 180

    # sort_airports = sorted(Airports.items(), key=itemgetter(1))
    f_TM = open(OUTPUT_DIR + 'TM_period' + str(period) + '_' + str(period_cnt) + '.txt', 'w')
    al = len(sort_airports)
    for i in range(al):
        src = sort_airports[i][0]
        if not TM.has_key(src):
            for j in range(al):
                f_TM.write("0, ")
        else:
            for j in range(al):
                dst = sort_airports[j][0]
                if not TM[src].has_key(dst):
                    f_TM.write("0, ")
                else:
                    f_TM.write(str(TM[src][dst]) + ", ")
        f_TM.write("\n")
    f_TM.write("\n") 
    f_TM.close()
## end generate_TM
################


################
## map_lat_lng_to_line
def map_lat_lng_to_line(lat, lng):
    # return lat + 90 + lng + 180
    return (lat + 90) + (lng + 180) * 400
## map_lat_lng_to_line
################


################
## Variables
################
OUTPUT_DIR = '../processed_data/subtask_process_4sq/'
total_user = set([])
user_hist = dict()
period = 1 


################
## Input
################
if DEBUG2:
    print sys.argv
if len(sys.argv) == 2:
    period = int(sys.argv[1])
else:
    print 'wrong number of input: ' + str(len(sys.argv))
    sys.exit(1)


################
## MAIN starts here
################
city = "Airport"
if DEBUG2:
    print "city: " + city
    print "-------------"

force_utf8_hack()

#################
## read Airport Info
#################
FILE_VENUE_DATA = '/4SQ_VENUE_DETAILS_' + city + ".gz"
DATA_AIR = load_data('../data/4sq/Airport_info/4SQ_AIRPORT_INFO')
Airports = []
for i in DATA_AIR:
    Airports.append( (DATA_AIR[i]['id'], map_lat_lng_to_line(float(DATA_AIR[i]['lat']), float(DATA_AIR[i]['lng']) ), i) )
sort_airports = sorted(Airports, key=itemgetter(1))

## write sorted airports to the file
f_airport = open(OUTPUT_DIR + 'airports_sorted.txt', 'w')
al = len(sort_airports)
for i in range(al):
    v = sort_airports[i][2]
    if not ('city' in DATA_AIR[v].keys()):
        if DEBUG1:
            print DATA_AIR[v].keys()
            print "  " + str(DATA_AIR[v]['name'])

        str_tmp = str(DATA_AIR[v]['name']) + ', ' + str(DATA_AIR[v]['lat']) + ", " + str(DATA_AIR[v]['lng'])
    else:
        str_tmp = str(DATA_AIR[v]['city']) + ', ' + str(DATA_AIR[v]['lat']) + ", " + str(DATA_AIR[v]['lng'])
    # print str_tmp
    f_airport.write(str_tmp + '\n')
f_airport.close()

if DEBUG2:
    print "done load airport info: " + str(len(DATA_AIR))


#################
# go over all folders and read files
#################
PATH = '../data/4sq/Airport/'
pre_date = -1
period_timedelta = datetime.timedelta(period)
period_cnt = 0
for folder in sort_listdir(PATH):
    if DEBUG2:
        print
        print folder
        # print os.listdir(PATH + folder)

    m = re.match('(\d+)-(\d+)-(\d+).*(\d+):(\d+):(\d+\.\d+)_Airport', folder)
    if DEBUG0:
        print str(m.group(1)) + "|||" + str(m.group(2)) + "|||" + str(m.group(3)) + "|||" + str(m.group(4)) + "|||" + str(m.group(5)) + "|||" + str(m.group(6))

    if pre_date == -1:
        pre_date = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        if DEBUG0:
            print pre_date
    else:
        new_date = datetime.date(int(m.group(1)), int(m.group(2)), int(m.group(3)))
        diff_time = new_date - pre_date
        if DEBUG0:
            print diff_time
        if diff_time >= period_timedelta:
            if DEBUG1:
                print ">>>>>>>> new period"

            generate_TM()
            period_cnt += 1
            user_hist = dict()
            pre_date = new_date

    DATA = load_data(PATH + folder + FILE_VENUE_DATA)
    process_data()

generate_TM()
period_cnt += 1
    
sys.exit(1)





