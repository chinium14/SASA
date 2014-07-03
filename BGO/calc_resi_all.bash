#!/bin/bash

#awk '/RDCMND/' sasa_per_resi.log | awk '/STOT/' | awk -F '"' '{print $4}' > sasa_resi_all.txt
paste sasa_bgo_2PBG_resi.dat sasa_resi_all.txt | awk '{print $1 , '\t',$3, '\t', $2}' >sasa_resi_both.txt
