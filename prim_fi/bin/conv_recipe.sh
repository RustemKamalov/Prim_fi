#! /bin/sh

# $1     old_pipe_file
# stdout recipe_data_init_txt format

 cat $1 | sed 's/^[/].*$//'     | \
          awk '{cnt=split($0,da,"\""); if (cnt >= 2) { gsub(",","@",da[2]) ; print(da[1] da[2])}else{print($0) } ; }'  | \
          awk -F , '
    {

     gsub("[[:space:]]","");

     if ( NF == 9 ) {
        if ( $4 ~ /;/) {
          NumPos = match($4,/.+;/);
          if (NumPos) {
            print ($1 " " substr($4,RSTART,RLENGTH-1));
          }
        } else {
          print($1 " "$4);
        }

     }

    }'
