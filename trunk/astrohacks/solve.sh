#!/bin/sh
/usr/local/astrometry/bin/solve-field --continue --radius 180 \
        --sigma 5 --no-plots -N none -r --objs 100 --cpulimit 10 \
        -L 0.2 -H 10 -u degwidth -z 2 -D /tmp $1
