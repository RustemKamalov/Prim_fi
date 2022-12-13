#!/bin/sh

# $1     old_mbtcp_dyn_txt file
# stdout mbtcp_dyn_txt format, missing QuestionMarks (?) inserted

 cat $1 | awk '
            BEGIN{ cmpAddr=-1; LineBuff[0]=0;} {

            gsub("[[:space:]]"," ");


            if ( cmpAddr > 0 ) {
              if ( $0 ~ /^[ ]*[M][ ]*[:].*r[ ]*=[ ]*[[:digit:]]+/ ) {

                  NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
                  BAddr = substr($0,RSTART,RLENGTH);
                  NumPos  = match(BAddr,/[[:digit:]]+/);
                  BAddr = substr(BAddr,RSTART,RLENGTH);

                  NumPos = match($0,/f[ ]*=[ ]*[[:alpha:]]/);
                  n_dtType = substr($0,RSTART+RLENGTH-1,1);

                  NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
                  n_MBPath = substr($0,RSTART,RLENGTH);
                  NumPos  = match(n_MBPath,/[[:digit:]]+/);
                  n_MBPath = substr(n_MBPath,RSTART,RLENGTH);



                  if (( n_dtType != dtType) || ( n_MBPath != MBPath)) {
                      cmpAddr = BAddr;
                  }


                  if ( BAddr == cmpAddr) {
                    if (LineBuff[0]>0 ) {
                      for(i=1;i<=LineBuff[0];i++){
                        print(LineBuff[i]);
                      }
                      LineBuff[0]=0;
                    }
                    print($0);
                  } else {

                    if ( BAddr > cmpAddr) {
                      SCnt = (BAddr - cmpAddr)/dtLen;
                      SStr = "?"
                      for ( i = 1 ; i < SCnt ; i++ ) {
                        SStr = SStr ",?";
                      }
                      print(rawLine " r="cmpAddr " S="SStr);
                      if (LineBuff[0]>0 ) {
                        for(i=1;i<=LineBuff[0];i++){
                          print(LineBuff[i]);
                        }
                        LineBuff[0]=0;
                      }
                      print($0);

                    } else {
                      print("Expecting " cmpAddr " but " BAddr " was the address (going backwards)...") >> "/dev/stderr";
                      print("Uhh check this and the previous line: "$0) >> "/dev/stderr";
                      exit(-1);
                    }

                  }
                  MBPath = n_MBPath;
                  dtType = n_dtType;
                  dtLen  = dtType;

                  sub(/[DF]/,"2",dtLen);
                  sub(/[W]/,"1",dtLen);
                  sub(/[B]/,"0.0625",dtLen);

                  NumPos = match($0,/S[ ]*=[ ]*[^ ]+/);
                  tagStr = substr($0,RSTART,RLENGTH);
                  tagCnt  = gsub(/,/,"",tagStr)+1;

                  cmpAddr= BAddr+(dtLen*tagCnt);

                  rawLine = $0;
                  sub(/d[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/s[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/r[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/S[ ]*=[ ]*[[:graph:]]+/,"",rawLine);
                  sub(/[ ]+$/,"",rawLine);



              } else {
                LineBuff[0]=LineBuff[0]+1;
                LineBuff[LineBuff[0]]=$0;
              }
            }

            if ( cmpAddr == 0 ) {
              if ( $0 ~ /^[ ]*[M][ ]*[:].*r[ ]*=[ ]*[[:digit:]]+/ ) {

                  NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
                  BAddr = substr($0,RSTART,RLENGTH);
                  NumPos  = match(BAddr,/[[:digit:]]+/);
                  BAddr = substr(BAddr,RSTART,RLENGTH);

                  NumPos = match($0,/f[ ]*=[ ]*[[:alpha:]]/);
                  dtType = substr($0,RSTART+RLENGTH-1,1);

                  NumPos = match($0,/r[ ]*=[ ]*[[:digit:]]+/);
                  MBPath = substr($0,RSTART,RLENGTH);
                  NumPos  = match(MBPath,/[[:digit:]]+/);
                  MBPath = substr(MBPath,RSTART,RLENGTH);


                  dtLen  = dtType;
                  sub(/[DF]/,"2",dtLen);
                  sub(/[W]/,"1",dtLen);
                  sub(/[B]/,"0.0625",dtLen);

                  NumPos = match($0,/S[ ]*=[ ]*[^ ]+/);
                  tagStr = substr($0,RSTART,RLENGTH);
                  tagCnt  = gsub(/,/,"",tagStr)+1;

                  cmpAddr= BAddr+(dtLen*tagCnt);


                  rawLine = $0;
                  sub(/d[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/s[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/r[ ]*=[ ]*[[:digit:]]+/,"",rawLine);
                  sub(/S[ ]*=[ ]*[[:graph:]]+/,"",rawLine);
                  sub(/[ ]+$/,"",rawLine);


                  print($0);


              }
            }



            if (( $0 ~ /^[ ]*OBJ[ ]*:/ )) {
              cmpAddr = 0;
              if (LineBuff[0]>0 ) {
# endre               for(i=1;i<=LineBuff[0];i++){
                for(i=1;i<LineBuff[0];i++){
                  print(LineBuff[i]);
                }
                LineBuff[0]=0;
              }

            }





            if ( cmpAddr <= 0 )  {
              print($0);
            }


          }
          END{
            if (LineBuff[0]>0 ) {
              for(i=1;i<=LineBuff[0];i++){
                print(LineBuff[i]);
              }
              LineBuff[0]=0;
            }
          }'

