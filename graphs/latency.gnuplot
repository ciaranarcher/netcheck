# See README for instructions on how to run.

set datafile separator ','
set xdata time # tells gnuplot the x axis is time data
set timefmt "%Y-%m-%dT%H:%M:%SZ" # specify our time string format
set format x "%d/%m %H:%M" # otherwise it will show only MM:SS
set xlabel "time"
set ylabel "latency (ms)"
set xtics rotate

plot csv using 1:4 w lp title 'min', \
'' using 1:5 w lp title 'avg', \
'' using 1:6 w lp title 'max', \
