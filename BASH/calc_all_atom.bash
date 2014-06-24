#!/bin/bash -l
module load CHARMM
module load MMTSB
for i in *.pdb
do
  enerCHARMM.pl -out sasa -cmd log.cmd -log $i.log $i
  name=`echo $i | awk -F "." '{print $1}'`
  value=`grep 'SURFAC: TOTAL =' $i.log | awk '{print $4}'`
  printf "$name\t$value\n" >> _sasa_all_atom.dat
  rm $i.log
done

sort -n -k 1,1 _sasa_all_atom.dat sasa_all_atom.dat
rm _sasa_all_atom.dat
