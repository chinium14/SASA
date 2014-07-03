open unit 10 read form name "/export/apps/CHARMM/toppar/top_all27_prot_na.rtf"
read rtf card unit 10
close unit 10
open unit 10 read form name "/export/apps/CHARMM/toppar/par_all27_prot_na.prm"
read para card unit 10 
close unit 10
faster on
open unit 10 read form name "gollum-pdb5997-PRO0"
read sequ pdb unit 10
generate   PRO0 setup warn
close unit 10
auto angle dihe
open unit 10 read form name "gollum-pdb5997-PRO0"
read coor pdb unit 10 resi
close unit 10
bomlev -2
ic param
set tmpNIC ?NIC
coor copy comp
ic build comp
coor copy select .not. hydrogen end
hbuild atom cdie eps 80.0 cutnb 10.0 ctofnb 7.5 ctonnb 6.5 shift vshift bygr
faster on
update atom CDIE eps 1 cutnb 20 ctofnb 18 ctonnb 16 shift vshift   bygr
open unit 78 read form name "gollum-stream5997"
stream unit 78
energy
stop
