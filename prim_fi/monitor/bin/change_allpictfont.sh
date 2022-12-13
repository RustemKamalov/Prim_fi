#! /bin/sh

# Change font for all views in monitor*.cfg files

for pict in $(find /prim_fi/monitor/pict/ -name '*.pict' | sed 's/\.pict//')
do
# with param views
    if grep -q $pict /prim_fi/monitor/cfg/monitor*.cfg

# normal views only
#    if grep -q '^V.*'$pict /prim_fi/monitor/cfg/monitor*.cfg
        then
        echo sh /prim_fi/monitor/bin/change_pictfont.sh $pict
        sh /prim_fi/monitor/bin/change_pictfont.sh $pict
    fi
done

