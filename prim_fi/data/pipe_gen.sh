#! /bin/ksh

# Fill in /prim_fi/data/pipe_txts all pipe_xx.txt files according to Makefile
# If found newer pipe_xx.txt than pipe.dbf
# moving pipe.dbf, pipe.mdx, pipe.txt to *.ori
# making pipe.dbf
# touching newer pipe_xx.txt, pipe.txt, pipe.dbf, pipe.mdx for pipe.dbf.ori

PIPE_DBF=/prim_fi/data/pipe.dbf
PIPE_MDX=/prim_fi/data/pipe.mdx
PIPE_TXT=/prim_fi/data/txt/pipe.txt

PIPE_TXTS=`cat /prim_fi/data/pipe_txts`

NEWER=0

for PIPE_TXT_ACT in $PIPE_TXTS
do
    if test $PIPE_TXT_ACT -nt $PIPE_DBF
    then
        echo $PIPE_TXT_ACT newer than $PIPE_DBF
        NEWER=1
    fi
done

if test $NEWER -eq 0
    then echo nothing to do: no newer pipe_xx.txt than $PIPE_DBF
        exit
fi

mv -v $PIPE_DBF $PIPE_DBF.ori
mv -v $PIPE_DBF.cdb $PIPE_DBF.cdb.ori
mv -v $PIPE_TXT $PIPE_TXT.ori
mv -v $PIPE_MDX $PIPE_MDX.ori

make -f /prim_fi/Makefile $PIPE_DBF

for PIPE_TXT_ACT in $PIPE_TXTS
do
    if test $PIPE_TXT_ACT -nt $PIPE_DBF.ori
    then
        echo $PIPE_TXT_ACT newer than $PIPE_DBF.ori
        echo touch -r $PIPE_DBF.ori $PIPE_TXT_ACT
        touch -r $PIPE_DBF.ori $PIPE_TXT_ACT
    fi
done

echo touch -r $PIPE_DBF.ori $PIPE_TXT
touch -r $PIPE_DBF.ori $PIPE_TXT
echo touch -r $PIPE_DBF.ori $PIPE_DBF
touch -r $PIPE_DBF.ori $PIPE_DBF
echo touch -r $PIPE_DBF.ori $PIPE_MDX
touch -r $PIPE_DBF.ori $PIPE_MDX

