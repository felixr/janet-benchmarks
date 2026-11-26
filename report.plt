# vim: set ft=gnuplot:
stats "report.dat" using 2 nooutput
N = STATS_blocks - 1
ymax = STATS_max

# Scale y-offset so all versions fit cleanly within each benchmark band
step = (N > 1) ? 0.75 / (N - 1) : 0.0

set terminal pngcairo size 1400,1000 enhanced font 'DM Mono,10'
set output 'report.png'

set key noenhanced
set xtic noenhanced
set ytic noenhanced

set grid ytics lw 2
set key outside right

set xlabel "seconds"
set ylabel "benchmark"
set border 2

set yrange [0.5:ymax+1]
set xrange [2:20]
set logscale x 10

# (x, y, xlow, xhigh),
# http://www.gnuplot.info/docs_4.2/node140.html
plot "report.dat" using 6:2:4:5:ytic(3) \
     index 0 with xerrorbars linecolor 1 pointtype 9 title columnhead(1), \
     for [i=1:N-1] "report.dat" using 6:($2 + i*step):4:5 \
        index i with xerrorbars linecolor (i+1) pointtype 9 title columnhead(1)
