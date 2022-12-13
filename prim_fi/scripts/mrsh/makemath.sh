#!/bin/sh

awk -f makemath.awk -v tmpl=math_mrsh_gv.tmpl -v out=math_mrsh.gv gvmap

cat math_mrsh.head math_mrsh.gv >math_mrsh.txt
