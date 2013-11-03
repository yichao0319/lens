#!/bin/bash

perl plot_TM.pl ../processed_data/subtask_parse_huawei_3g/signaling_tm/tm.select_matrix_for_id-Assignment.txt.60 60 900
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.country.txt.3600 600 3000
perl plot_TM.pl ../processed_data/subtask_parse_sjtu_wifi/tm/tm.sort_ips.ap.gps.4.txt.3600 800 2000