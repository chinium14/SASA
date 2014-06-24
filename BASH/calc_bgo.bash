#!/bin/bash
rm sasa_bgo.dat
for i in *.pdb
do
   ./sasa pdb $i
   name=`echo $i | awk -F "." 'sub(FS $NF,x)'`
   content=`cat sasa_bgo_$name.dat`
   printf "$content\n" >> _temp_sasa_bgo.dat
   rm sasa_bgo_$name.dat
done

awk -F '[.\t]' '{print $1 "\t" $3}' _temp_sasa_bgo.dat > _sasa_bgo.dat   
rm _temp_sasa_bgo.dat
sort -n -k 1,1 _sasa_bgo.dat >sasa_bgo.dat
rm _sasa_bgo.dat


