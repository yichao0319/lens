#!/bin/bash

# perl plot_TM.pl ../processed_data/subtask_parse_huawei_3g/signaling_tm/tm.select_matrix_for_id-Assignment.txt.60 60 900
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.country.txt.3600 900 3000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.gps.1.sub_CN.txt.3600 900 3000  
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.gps.5.txt.3600 900 3000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.bgp.8.txt.3600 900 3000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.bgp.10.sub_CN.txt.3600 900 3000  