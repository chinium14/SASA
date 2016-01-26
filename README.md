# SASA
This folder contains the main software, job submit scripts, and data analysis tools 
for calculating protein solvent accessible surface area with C_alpha only.
Shuai Wei 6/24/2014


Basic use:
Example:
./sasa crd 7LZM.crd
./sasa pdb 2PGB.pdb

with 7LZM.crd and 2PGB.pdb in the same folder.

Large pdb data set:
cp cal_sasa_<bgo/all_atom>.bash <WORKING_DIR>
cp submit.bash <WORKING_DIR>
cp sasa <WORKING_DIR>

Modify submit.bash to fit your system.

qsub submit.bash

NOTE: For calculating SASA with all atom, MMTSB tools and CHARMM are required.

Fitting and calculate corelation:
matlab < fitting_sasa_bgo_to_all.m
matlab < sasa_corelation.m
