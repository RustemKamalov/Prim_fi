#! /bin/sh

# Compile all views in monitor*.cfg files

for pict in $(find /prim_fi/monitor/pict/ -name '*.pict' | sed 's/\.pict//')
do
# with param views
    if grep -q $pict /prim_fi/monitor/cfg/monitor*.cfg

# normal views only
#    if grep -q '^V.*'$pict /prim_fi/monitor/cfg/monitor*.cfg
        then
        /Dmon/bin/dmmonedit -i$pict /prim_fi/config/monx.ini
    fi
done

