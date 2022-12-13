# /bin/sh -c
#ifdef __USAGE
# Usage:
#%C <mb_txt_file> <pipe_txt_file> [<out_file>]
#%C changes asyncron o=Iw writes to o=O in <mb_txt_file>
#   resulting <out_file>.
#   If not specified <out_file>=<mb_txt_file>.Iw2O
#
#   Rectrictions: Clock and chain writes should be done before.
#       An object could contain maximum one #@Address: #@End: pair,
#       if one of them exist alone: warning.
#       Only o=Iw objects are checked (eg. o=IW, o=Iiw,... not)
#       Each object checked for Mx_MB_Enable tag,
#       if not found Mx_Enable tag in row PARL: ... : warning and then Mx derived from the tag
#       Only first tag looked after S=
#       S=? and ,? tags are ignored at o=O
#       n= handled: tagnames are created from S=Tagxxx and xxx incremented
#         if #database keyword exist in line n= then tagnames are searched in pipe_txt_file
#       #@Address: and #@End labels should be in pairs in an Object containing o=Iw
#endif

if test $# -lt 2
then
    echo 'Usage: mbtIw2O <mb_txt_file> <pipe_txt_file> [<out_file>]'
    echo 'Changes asyncron o=Iw writes to o=O in <mb_txt_file>'
    exit -1
fi

txt_file=$1
pipe_file=$2

if test $# -gt 2
then
  out_file=$3
else
  out_file="$txt_file".Iw2O
fi

awk -v pipefile=$pipe_file -v outfile=$out_file -f mbtIw2O.awk $txt_file | tee mbtIw2O.res

