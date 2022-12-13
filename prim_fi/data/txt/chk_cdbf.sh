#! /bin/sh
#check pipe.txt (cdbf.txt, new cdbf format) on tag dublication

PIPE_TXT=$1

echo "--- Checking pipe.txt on tag duplication... "
awk -F, '{ print $1 } ' $PIPE_TXT | sort | uniq -d |tee tagdupl.err

if test -s tagdupl.err
then
    echo "!!! Error in pipe.txt: recurring signal. See tagdupl.err file "
    exit -1
fi
rm tagdupl.err
echo "--- Checking pipe.txt (ready) "
exit 0

