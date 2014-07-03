#!/bin/bash

for i in *.pdb
do
   rand=`shuf -i 1-100 -n 1`
   if [ $rand -lt 20 ]
   then
      echo $i | awk -F '.' '{print $1}' >>test_list.txt
   else
      echo $i | awk -F '.' '{print $1}' >>train_list.txt
   fi
done
