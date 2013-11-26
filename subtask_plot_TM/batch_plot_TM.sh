#!/bin/bash

ns=400
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.country.txt.3600.top${ns} ${ns} 2000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.country.txt.3600.top${ns} ${ns} 2000

perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.bgp.sub_CN.txt.3600.top${ns} ${ns} 3000  
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.bgp.sub_CN.txt.3600.top${ns} ${ns} 3000  

perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.gps.1.sub_CN.txt.3600.top${ns} ${ns} 3000  
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.gps.1.sub_CN.txt.3600.top${ns} ${ns} 3000  

perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_download.sort_ips.ap.gps.5.txt.3600.top${ns} ${ns} 3000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm_upload.sort_ips.ap.gps.5.txt.3600.top${ns} ${ns} 3000

#######################

perl plot_TM.pl /v/filer4b/v27q002/ut-wireless/yichao/anomaly_compression/subtask_mpeg/tmp_output/tmp 600 120
