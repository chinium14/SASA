#!/bin/bash -l
module load CHARMM

if [ -f sasa_all_resi_all.dat ]
then
   
fi

for i in *.pdb
do
   name=`echo $i | awk -F '.' '{print $1}'`
   mv $i $name.PDB
   sed -i -e 's/HIS/HSD/g' $name.PDB
   charmm pdb=$name.PDB <charmm_sasa_resi.inp >_sasa_all_$name_resi.log
   grep 'RDCMND substituted energy or value "?STOT"' _sasa_all_$name_resi.log | awk -F '"' '{print $4}' > sasa_all_$name_resi.dat
   if [ -f sasa_all_$name_resi.dat ]
   then
      paste sasa_bgo_$name_resi.dat sasa_all_$name_resi.dat | awk '{print $1, '\t', $3, '\t', $2}' >sasa_both_$name_resi.dat
   fi
#   cat sasa_all_$name_resi.log >> sasa_all_resi_all.dat
done

