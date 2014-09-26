#!/bin/bash

for i in {"ALA","ARG","ASN","ASP","CYS","GLN","GLU","GLY","HIS","ILE","LEU","LYS","MET","PHE","PRO","SER","THR","TRP","TYR","VAL"}
do
   awk '/'$i'/{print $0}' sasa_both_all_resi.dat > "$i"_sasa.dat
done
