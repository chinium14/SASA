#!/bin/bash

for i in $(cat remove_list.txt)
do
   rm $i.pdb $i.log
done
