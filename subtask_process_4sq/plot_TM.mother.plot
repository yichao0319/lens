reset
set terminal postscript eps enhanced color 28
#set terminal jpeg enhanced font helvetica 20
filename="XXX"

set output "../figures/subtask_process_4sq/TM/" . filename . ".eps"
#set output "../figures/subtask_process_4sq/TM/jpeg/" . filename . ".jpeg"

set tic scale 0
# Color runs from white to green
#set palette rgbformula -7,2,-7
set cbrange [0:YYY]
#set cblabel "Score"
#unset cbtics

set xrange [0:500]
set yrange [0:500]

#set view map
plot '../processed_data/subtask_process_4sq/TM/' . filename . '.txt' matrix w image notitle
