


cat Fi3_bunk_sorted_2.wrk | awk '{tag=$1; num=$2; if(num >=64){num-=63;}; print(tag " " num);}'

