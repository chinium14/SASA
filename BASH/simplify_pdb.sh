#!/bin/bash

for i in *.pdb
do
   name=`echo $i | awk -F '.' '{print $1}'`
   value=`awk '/^ATOM/' "$name.pdb"`
   printf "$value" >> "./PDB_ATOM/$name.pdb"
   printf "\nTER" >> "./PDB_ATOM/$name.pdb"
   printf "\nEND" >> "./PDB_ATOM/$name.pdb"
done
