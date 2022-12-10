# vim: set ft=gnuplot:
set terminal pngcairo size 1200,500 enhanced font 'DM Mono,10'
set output 'report.png'

set key noenhanced
set xtic noenhanced
set ytic noenhanced

set grid ytics lw 2
set key above

set xlabel "seconds"
set ylabel "benchmark"
set border 2 

set yrange [0:10]
set logscale x 10

# (x, y, xlow, xhigh),
# http://www.gnuplot.info/docs_4.2/node140.html
plot "report.dat" using 6:2:4:5:ytic(3) \
     index 0 with xerrorbars linecolor 1  pointtype 9  title columnhead(1), \
     for [i=1:6] "report.dat" using 6:($2+i*0.1):4:5  \
        index i with xerrorbars linecolor (i+1) pointtype 9 title columnhead(1)
