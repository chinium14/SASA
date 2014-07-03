#!/bin/bash -l
module load CHARMM
module load MMTSB
for i in $(cat ./test_list.txt)
do
#  enerCHARMM.pl -out sasa -cmd log.cmd -log $i.log $i.pdb
  value=`grep 'SURFAC: TOTAL =' $i.log | awk '{print $4}'`
  printf "$i\t$value\n" >> _test_sasa_all_atom.dat
#  rm $i.log
done

sort -n -k 1,1 _test_sasa_all_atom.dat > test_sasa_all_atom.dat
#rm _test_sasa_all_atom.dat
