#! /bin/sh

# $1     struct_file
# $2     old_pipe_file
# stdout new_cdbf_format
#
 cat $2 | sed 's/^[ \t]+//g'    | \
          sed 's/^[/].*$//'     | \
					awk '{cnt=split($0,da,"\""); if (cnt >= 2) { gsub(",","@",da[2]) ; print(da[1] da[2])}else{print($0) } ; }'  | \
					awk -F , '
    BEGIN{
      strfile=  "'$1'" ;
      working = 0;
      lpos=1;
      llen=0;
      arows[0,0]=0;
      while(getline < strfile){
        gsub("[ \t]","");
        if ( $0 ~ /^FIELDS[:]/) {
          working = 1;
        }
        if ( $0 ~ /^ENDFIELDS[:]/) {
          working = 0;
        }

        if (( working == 2 ) && (NF >= 4)) {
          arows[0,0]++;
          arows[arows[0,0],0]=lpos+llen;
          arows[arows[0,0],1]=$3;
          lpos = arows[arows[0,0],0];
          llen = arows[arows[0,0],1]+1;
        }

        if ( working == 1 ) {
          working = 2;
        }
      }
      close(strfile);

#      for ( i=1; i<=arows[0,0]; i++ ) {
#        print(arows[i,0] " >> " arows[i,1]);
#      }

    }
    {
     if ( NF >= 8) {
      outstr = "";
      partstr[1]=$1;
      partstr[2]=$2;
      partstr[4]=$3;


      partstr[3]=$NF;
      gsub("^[ \t]+","",partstr[3]);
      gsub("[ \t]+$","",partstr[3]);
      if ( length(partstr[3]) > arows[3,1]) {
        partstr[3]=substr(partstr[3],1,arows[3,1]);
      }

      for ( i=1 ; i<=5; i++ ) {
        gsub("^[ \t]+","",partstr[i]);
        gsub("[ \t]+$","",partstr[i]);
				scf=gensub( /(.*);.*/, "\\1",1,partstr[i]);
				partstr[i]=scf;
				while(length(partstr[i])<arows[i,1] ){
          partstr[i]=partstr[i]" ";
        }
      }
      print(partstr[1]","partstr[2]","partstr[3]","partstr[4]","partstr[5]",");
#      print(partstr[1]","partstr[2]",valami,"partstr[4]","partstr[5]",");
     }

    }'
