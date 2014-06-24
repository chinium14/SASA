#!/bin/bash 
#PBS -l nodes=1:ppn=1
#PBS -l walltime=100:00:00
#PBS -N sasa_all_atom

loglog=${PBS_O_WORKDIR}/${PBS_JOBNAME}.log
echo "WORKDIR  ${PBS_O_WORKDIR}" >> $loglog
echo "PBSDIR   ${PBSREMOTEDIR}"  >> $loglog
echo "JOBID    ${PBS_JOBID}" >> $loglog
echo start date=`date` >> $loglog


echo start date=`date`


cp -a ${PBS_O_WORKDIR}/* ${PBSREMOTEDIR}
cd ${PBSREMOTEDIR}
#touch .keep

./calc_all_atom.bash

#(mpirun -np 24 ./charmm < 1j5em_p27u_fa08_1bp_anti_b_-30_60.inp >! 1j5em_p27u_fa08_1bp_anti_b_-30_60.out) >&! 1j5em_p27u_fa08_1bp_anti_b_-30_60.err

rsync -vrultp $PBSREMOTEDIR/* ${PBS_O_WORKDIR}/
echo end date=`date` >> $loglog

#if ($status == 0) rm -f .keep

echo end date=`date`




