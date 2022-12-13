#!/bin/sh

# $1     dyn1.txt
# stdout dyn2 version

 cat $1 | awk '
            BEGIN{newBase=0 ; oldBase=-1; Offset = 0; } {

            gsub("[[:space:]]"," ");

            if (( oldBase == -1 ) && ( $0 ~ /^[ ]*[#][ ]*[@][ ]*Address[ ]*[:]/ )) {
              NumPos = match($0,/[[:digit:]]+/);
              if ( NumPos ) {
                newBase = substr($0,RSTART,RLENGTH);
                oldBase = 0;
                Offset  = 0;
              }
            }

            if (( oldBase == 0 ) && ( $0 ~ /^[ ]*[M][ ]*[:].*r[ ]*=[ ]*[[:digit:]]+/ )) {
              NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
              if ( NumPos ) {
                oldBase = substr($0,RSTART,RLENGTH);
                NumPos  = match(oldBase,/[[:digit:]]+/);
                oldBase = substr(oldBase,RSTART,RLENGTH);
                Offset  = newBase - oldBase ;
              }

            }

            if (( oldBase > 0 ) && ( $0 ~ /^[ ]*[M][ ]*[:].*r[ ]*=[ ]*[[:digit:]]+/ )) {
              NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
              if ( NumPos ) {
                oldAddr_r = substr($0,RSTART,RLENGTH);
                NumPos    = match(oldAddr_r,/[[:digit:]]+/);
                oldAddr   = substr(oldAddr_r,RSTART,RLENGTH);
                newAddr   = oldAddr + Offset;
                sub(oldAddr_r,"r=" newAddr);
              }
            }

            if (( oldBase > 0 ) && ( $0 ~ /^[ ]*[#][ ]*[@][ ]*End/ ))  {
              newBase=0 ;
              oldBase=-1;
              Offset = 0;
            }

            print($0);

          }'




