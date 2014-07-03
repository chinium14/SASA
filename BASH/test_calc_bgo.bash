#!/bin/bash

if [ -a test_sasa_bgo.dat ]
then
   rm test_sasa_bgo.dat
fi
for i in $(cat test_list.txt)
do
   ./sasa pdb $i.pdb
   content=`cat sasa_bgo_$i.dat`
   printf "$content\n" >> _test_sasa_bgo.dat
   rm sasa_bgo_$i.dat
done

sort -n -k 1,1 _test_sasa_bgo.dat > test_sasa_bgo.dat
sed -i -e '/^$/d' test_sasa_bgo.dat
rm _test_sasa_bgo.dat


