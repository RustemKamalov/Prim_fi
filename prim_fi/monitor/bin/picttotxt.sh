#! /bin/sh

# $1: pict file with or without .pict ending
FILE=$(echo $1 | sed 's/\.pict//' | sed 's%/%\\%')
PICT_FILE=$FILE.pict
TXTDYN_FILE=$FILE.txt

echo /Dmon/utils/dmpicttotxt $PICT_FILE $PICT_FILE.txt
/Dmon/utils/dmpicttotxt $PICT_FILE $PICT_FILE.txt 2>$PICT_FILE.err >$PICT_FILE.res

