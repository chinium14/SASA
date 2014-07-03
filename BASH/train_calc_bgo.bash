#!/bin/bash

if [ -a _train_sasa_bgo.dat ]
then
   rm _train_sasa_bgo.dat
fi

if [ -a train_sasa_bgo.dat ]
then
   rm train_sasa_bgo.dat
fi
for i in $(cat train_list.txt)
do
   ./sasa pdb $i.pdb
   content=`cat sasa_bgo_$i.dat`
   printf "$content\n" >> _train_sasa_bgo.dat
   rm sasa_bgo_$i.dat
done

sort -n -k 1,1 _train_sasa_bgo.dat > train_sasa_bgo.dat
rm _train_sasa_bgo.dat

sed -i -e '/^$/d' train_sasa_bgo.dat

./merge_sasa.bash
