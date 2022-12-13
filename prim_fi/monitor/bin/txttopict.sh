#! /bin/sh

# $1: pict file with or without .pict ending
FILE=$(echo $1 | sed 's/\.pict//' | sed 's%/%\\%')
PICT_FILE=$FILE.pict
TXTDYN_FILE=$FILE.txt

echo /Dmon/utils/dmtxttopict $PICT_FILE.new.txt $PICT_FILE
#/Dmon/utils/dmtxttopict $PICT_FILE.new.txt $PICT_FILE
/Dmon/utils/dmtxttopict $PICT_FILE.new.txt $PICT_FILE 2>$PICT_FILE.err >$PICT_FILE.res

