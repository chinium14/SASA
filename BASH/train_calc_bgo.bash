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
   ./sasa pdb $i.pdb -0.5 1.05
   content=`cat sasa_bgo_$i.dat`
   printf "$content\n" >> _train_sasa_bgo.dat
   rm sasa_bgo_$i.dat
done

sort -n -k 1,1 _train_sasa_bgo.dat > train_sasa_bgo.dat
rm _train_sasa_bgo.dat

sed -i -e '/^$/d' train_sasa_bgo.dat

#Merge bgo and all-atom SASA into a file: train_sasa_both.dat
./train_merge_sasa.bash

# Calc the coorelation of bgo and all-atom SASA.    
sed -e 's/sasa_both_all_resi/train_sasa_both/g' correlate_sasa.R > train_correlate_sasa.R
sed -i -e 's/bgo<-ca$V3/bgo<-ca$V4/' train_correlate_sasa.R
RBIN=`which R`
$RBIN --save < train_correlate_sasa.R > train_correlate_sasa.R.out
mv Rplots.pdf train_correlate_sasa.pdf

