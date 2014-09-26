#!/bin/bash -l

module add R
if [ -a _train_sasa_bgo.dat ]
then
   rm _train_sasa_bgo.dat
fi

if [ -a train_sasa_bgo.dat ]
then
   rm train_sasa_bgo.dat
fi


for k in `seq 5 10`
do

param_b=$(echo "1+$k/100" | bc -l)
for j in `seq 0 20`
do

for i in $(cat train_list.txt)
do
   param_a=$(echo "$j/10" | bc -l)
   ./sasa pdb $i.pdb $param_a $param_b
   content=`cat sasa_bgo_$i.dat`
   printf "$content\n" >> _train_sasa_bgo.dat
   rm sasa_bgo_$i.dat
done

sort -n -k 1,1 _train_sasa_bgo.dat > train_sasa_bgo.dat
rm _train_sasa_bgo.dat

sed -i -e '/^$/d' train_sasa_bgo.dat

#Merge bgo and all-atom SASA into a file: train_sasa_both.dat
./train_merge_sasa.bash
./train_merge_sasa_resi.bash
echo "$param_a" >> param_a.out
echo "$param_b" >> param_b.out
grep '\[1\]' train_correlate_sasa.R.out | awk '{print $2}' >> train_search.out
grep '\[1\]' train_correlate_sasa_resi.R.out | awk '{print $2}' >> train_search_resi.out
#rm train_correlate_sasa.R.out train_correlate_sasa_resi.R.out
# Calc the coorelation of bgo and all-atom SASA.    
#sed -e 's/sasa_both_all_resi/train_sasa_both/g' correlate_sasa.R > train_correlate_sasa.R
#sed -i -e 's/bgo<-ca$V3/bgo<-ca$V4/' train_correlate_sasa.R
#RBIN=`which R`
#mv Rplots.pdf train_correlate_sasa.pdf
#module load Matlab
#matlab -nodisplay < fitting_sasa_bgo_to_all.m > junk.out
#module rm Matlab
#echo $param_a $param_b >> fitting_bgo2.out
#cat _fitting.out >> fitting_bgo2.out
done
done

paste param_a.out param_b.out train_search.out train_search_resi.out | awk '{print $1 "\t" $2 "\t" $3 "\t" $4 "\t" $4+$3}' > train_search_summary.out

sed -i "1 i \param_a \t param_b \t R2_p \t R2_r \n" train_search_summary.out
