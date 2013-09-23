#!/bin/bash


for period in 1 2 5 10 20 30 ; do
    date
    echo "  "${period}
    python generate_Human_TM.py ${period}
done
