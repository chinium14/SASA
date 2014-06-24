#!/bin/bash

cat ./sasa_all_atom.dat | awk -F '_' '{print $2}' >_tmp_all
cat ./sasa_bgo.dat | awk -F '_' '{print $2}' >_tmp_bgo

sort -n -k 1 _tmp_all >_temp_all
sort -n -k 1 _tmp_bgo >_temp_bgo
paste _temp_all _temp_bgo | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $4/$2}' > sasa_both.dat

rm _temp_* _tmp_*
