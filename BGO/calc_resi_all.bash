#!/bin/bash -l 

module add R

./sasa pdb 2PBG.pdb 0 1 2.8
#awk '/RDCMND/' sasa_per_resi.log | awk '/STOT/' | awk -F '"' '{print $4}' > sasa_resi_all.txt
paste sasa_bgo_2PBG_resi.dat sasa_resi_all.dat | awk '{print $1 , '\t',$4, '\t', $2}' >sasa_resi_both.dat

R --save < correlate_sasa.R
