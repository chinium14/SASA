#!/bin/bash -l
module load CHARMM
module load MMTSB

if [ -f _sasa_all_atom.dat ]
then
   rm _sasa_all_atom.dat
fi
if [ -f sasa_all_atom.dat ]
then
   rm sasa_all_atom.dat
fi

for i in *.pdb
do
  name=`echo $i | awk -F '.' '{print $1}'`
  enerCHARMM.pl -cmd log.cmd -custom sasa_custom_enerCHARMM.str -log $name.log $i
  value=`grep 'SURFAC: TOTAL =' $name.log | awk '{print $4}'`
  printf "$name\t$value\n" >> _sasa_all_atom.dat
  mv temp_resi.dat sasa_all_"$name"_resi.dat
done

sort -n -k 1,1 _sasa_all_atom.dat > sasa_all_atom.dat
#rm _sasa_all_atom.dat
