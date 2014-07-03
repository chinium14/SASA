#!/usr/bin/env perl

# converts and renumbers PDB files
#
# http://mmtsb.scripps.edu/doc/convpdb.pl.html
# 2000, Michael Feig, Brooks group, TSRI

sub usage {
  printf STDERR "usage:   convpdb.pl [options] [PDBfile]\n";
  printf STDERR "options: [-center] [-translate dx dy dz]\n";
  printf STDERR "         [-rotate m11 m12 m13 m21 m22 m23 m31 m32 m33]\n";
  printf STDERR "         [-rotatex phi] [-rotatey phi] [-rotatez phi]\n";
  printf STDERR "         [-scale factor] [-diff PDBfile] [-difflsqfit] [-add PDBFile]\n";
  printf STDERR "         [-nmode file amplitude weight]\n";
  printf STDERR "         [-nmodesample file prefix from to delta] [-skipzero]\n";
  printf STDERR "         [-sel list] [-exclude list]\n";
  printf STDERR "         [-chain id] [-model num] [-firstmodel] [-nohetero]\n";
  printf STDERR "         [-selseq abbrev]\n";
  printf STDERR "         [-nsel Selection]\n";
  printf STDERR "         [-merge pdbfile]\n";
  printf STDERR "         [-renumber start] [-addres value]\n";
  printf STDERR "         [-renumwatersegs]\n";
  printf STDERR "         [-match pdbfile]\n";
  printf STDERR "         [-setchain id]\n";
  printf STDERR "         [-readseg] [-chainfromseg]\n";
  printf STDERR "         [-charmm19] [-amber]\n";
  printf STDERR "         [-out charmm19 | charmm22 | amber | generic]\n";
  printf STDERR "         [-crd] [-crdext]\n";
  printf STDERR "         [-segnames]\n";
  printf STDERR "         [-fixcoo]\n";
  printf STDERR "         [-ssbond res1:res2[=res1:res2]] [-nossbond]\n";
  printf STDERR "         [-solvate] [-cutoff value]\n";
  printf STDERR "         [-octahedron] [-cubic]\n";
  printf STDERR "         [-ions NAME:num[=NAME:num]]\n"; 
  printf STDERR "         [-info]\n";
  printf STDERR "         [-fill inx:seq]\n";
  printf STDERR "         [-mol2]\n";
  printf STDERR "         [-cleanaux] [-removeclashes]\n";
	printf STDERR "         [-icode] [-alt]\n";
  exit 1;
}

use vars qw ( $perllibdir );

BEGIN {
  $perllibdir="$ENV{MMTSBDIR}/perl" if (defined $ENV{MMTSBDIR});
  ($perllibdir=$0)=~s/[^\/]+$// if (!defined $perllibdir);
}

use lib $perllibdir;
use strict;
use Molecule;
use Analyze;

my $renumber;
my $addres;
my $fname="-";
my $inmode="";
my $outmode="CHARMM22";
my $center=0;
my $sellist;
my $chain;
my $segnames;
my $matchpdb;
my $mergepdb;
my $setchain;
my $ignoreseg=1;
my $chainfromseg=0;
my $fixcoo=0;
my $scale;
my $dx=0.0;
my $dy=0.0;
my $dz=0.0;
my $selmodel=undef;
my $firstmodel=0;
my $selseq;
my $nsel;
my $solvate;
my $shape;
my $cutoff=9.0;
my $excllist;
my $hetero=1;
my $ssbonds=();
my $nossbond=0;
my $rotate;
my $m11=1.0;
my $m12=0;
my $m13=0;
my $m21=0;
my $m22=1.0;
my $m23=0;
my $m31=0;
my $m32=0;
my $m33=1.0;
my $ions=();
my $info=0;
my $fillinx;
my $fillseq;
my $nmodefile=undef;
my $nmodeamplitude=0.0;
my $nmodeweight=1;
my $nmodesampleprefix;
my $nmodesamplefrom;
my $nmodesampleto;
my $nmodesampledelta;
my $diffpdbfile;
my $difflsqfit=0;
my $addFlag=0;
my $skipzero=0;
my $mol2=0;
my $cleanaux=0;
my $removeclashes=0;
my $renumwatersegs=0;
my $crd=0;
my $crdext=0;
my $icode=undef;
my $alt=undef;

while ($#ARGV>=0) {
  if ($ARGV[0] eq "-help" || $ARGV[0] eq "-h") {
    &usage();
  } elsif ($ARGV[0] eq "-renumber") {
    shift @ARGV;
    $renumber=shift @ARGV;
  } elsif ($ARGV[0] eq "-addres") {
    shift @ARGV;
    $addres=shift @ARGV;
  } elsif ($ARGV[0] eq "-setchain") {
    shift @ARGV;
    $setchain=shift @ARGV;
  } elsif ($ARGV[0] eq "-readseg") {
    shift @ARGV;
    $ignoreseg=0;
  } elsif ($ARGV[0] eq "-chainfromseg") {
    shift @ARGV;
    $chainfromseg=1;
    $ignoreseg=0;
  } elsif ($ARGV[0] eq "-nmode") {
    shift @ARGV;
    $nmodefile=shift @ARGV;
    $nmodeamplitude=shift @ARGV;
    $nmodeweight=shift @ARGV;
  } elsif ($ARGV[0] eq "-skipzero") {
    shift @ARGV;
    $skipzero=1;
  } elsif ($ARGV[0] eq "-nmodesample") {
    shift @ARGV;
    $nmodefile=shift @ARGV;
    $nmodesampleprefix=shift @ARGV;
    $nmodesamplefrom=shift @ARGV;
    $nmodesampleto=shift @ARGV;
    $nmodesampledelta=shift @ARGV;
  } elsif ($ARGV[0] eq "-ions") {
    shift @ARGV;
    foreach my $in ( split(/=/,shift @ARGV) ) {
      my $trec={};
      ($trec->{name},$trec->{num})=split(/:/,$in);
      push(@{$ions},$trec);
    }
  } elsif ($ARGV[0] eq "-ssbond") {
    shift @ARGV;
    foreach my $s (split(/=/,shift @ARGV)) {
      my @l=split(/:/,$s);
      my $trec={};
      my ($tc1,$tr1)=($l[0]=~/([A-Za-z]*)([\-0-9]*)/);
      $trec->{chain1}=$tc1;
      $trec->{resnum1}=$tr1;
      my ($tc2,$tr2)=($l[1]=~/([A-Za-z]*)([\-0-9]*)/);
      $trec->{chain2}=(defined $tc2 && $tc2 ne "")?$tc2:$tc1;
      $trec->{resnum2}=$tr2;
      push (@{$ssbonds},$trec);
    }
  } elsif ($ARGV[0] eq "-nossbond") {
    shift @ARGV;
    $nossbond=1;
  } elsif ($ARGV[0] eq "-charmm19") {
    $inmode="CHARMM19";
    shift @ARGV;
  } elsif ($ARGV[0] eq "-amber") {
    $inmode="AMBER";
    shift @ARGV;
  } elsif ($ARGV[0] eq "-fixcoo") {
    shift @ARGV;
    $fixcoo=1;
  } elsif ($ARGV[0] eq "-out") {
    shift @ARGV;
    $outmode=uc shift @ARGV;
  } elsif ($ARGV[0] eq "-center") {
    shift @ARGV;
    $center=1;
  } elsif ($ARGV[0] eq "-translate") {
    shift @ARGV;
    $dx=shift @ARGV;
    $dy=shift @ARGV;
    $dz=shift @ARGV;
  } elsif (($ARGV[0] eq "-diff") || ($ARGV[0] eq "-add")) { #note that (in diff) subtrahend is before minuend
    if ($ARGV[0] eq "-add"){$addFlag=1;}
    shift @ARGV;
    $diffpdbfile=shift @ARGV;
  } elsif ($ARGV[0] eq "-difflsqfit") {
    shift @ARGV;
    $difflsqfit=1;  
  } elsif ($ARGV[0] eq "-scale") {
    shift @ARGV;
    $scale=shift @ARGV;
  } elsif ($ARGV[0] eq "-rotate") {
    shift @ARGV;
    my $tm11=shift @ARGV;
    my $tm12=shift @ARGV;
    my $tm13=shift @ARGV;
    my $tm21=shift @ARGV;
    my $tm22=shift @ARGV;
    my $tm23=shift @ARGV;
    my $tm31=shift @ARGV;
    my $tm32=shift @ARGV;
    my $tm33=shift @ARGV;
    my $nm11=$m11*$tm11+$m12*$tm21+$m13*$tm31;
    my $nm12=$m11*$tm12+$m12*$tm22+$m13*$tm32;
    my $nm13=$m11*$tm13+$m12*$tm23+$m13*$tm33;
    my $nm21=$m21*$tm11+$m22*$tm21+$m23*$tm31;
    my $nm22=$m21*$tm12+$m22*$tm22+$m23*$tm32;
    my $nm23=$m21*$tm13+$m22*$tm23+$m23*$tm33;
    my $nm31=$m31*$tm11+$m32*$tm21+$m33*$tm31;
    my $nm32=$m31*$tm12+$m32*$tm22+$m33*$tm32;
    my $nm33=$m31*$tm13+$m32*$tm23+$m33*$tm33;
    ($m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33)=
      ($nm11,$nm12,$nm13,$nm21,$nm22,$nm23,$nm31,$nm32,$nm33);
    $rotate=1;
  } elsif ($ARGV[0] eq "-rotatex") {
    shift @ARGV;
    my $phi=shift @ARGV;
    $phi=$phi/180.0*3.141592654;
    my $tm11=1;
    my $tm12=0;
    my $tm13=0;
    my $tm21=0;
    my $tm22=cos($phi);
    my $tm23=sin($phi);
    my $tm31=0;
    my $tm32=-sin($phi);
    my $tm33=cos($phi);
    my $nm11=$m11*$tm11+$m12*$tm21+$m13*$tm31;
    my $nm12=$m11*$tm12+$m12*$tm22+$m13*$tm32;
    my $nm13=$m11*$tm13+$m12*$tm23+$m13*$tm33;
    my $nm21=$m21*$tm11+$m22*$tm21+$m23*$tm31;
    my $nm22=$m21*$tm12+$m22*$tm22+$m23*$tm32;
    my $nm23=$m21*$tm13+$m22*$tm23+$m23*$tm33;
    my $nm31=$m31*$tm11+$m32*$tm21+$m33*$tm31;
    my $nm32=$m31*$tm12+$m32*$tm22+$m33*$tm32;
    my $nm33=$m31*$tm13+$m32*$tm23+$m33*$tm33;
    ($m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33)=
      ($nm11,$nm12,$nm13,$nm21,$nm22,$nm23,$nm31,$nm32,$nm33);
    $rotate=1;
  } elsif ($ARGV[0] eq "-rotatey") {
    shift @ARGV;
    my $phi=shift @ARGV;
    $phi=$phi/180.0*3.141592654;
    my $tm11=cos($phi);
    my $tm12=0;
    my $tm13=-sin($phi);
    my $tm21=0;
    my $tm22=1;
    my $tm23=0;
    my $tm31=sin($phi);
    my $tm32=0;
    my $tm33=cos($phi);
    my $nm11=$m11*$tm11+$m12*$tm21+$m13*$tm31;
    my $nm12=$m11*$tm12+$m12*$tm22+$m13*$tm32;
    my $nm13=$m11*$tm13+$m12*$tm23+$m13*$tm33;
    my $nm21=$m21*$tm11+$m22*$tm21+$m23*$tm31;
    my $nm22=$m21*$tm12+$m22*$tm22+$m23*$tm32;
    my $nm23=$m21*$tm13+$m22*$tm23+$m23*$tm33;
    my $nm31=$m31*$tm11+$m32*$tm21+$m33*$tm31;
    my $nm32=$m31*$tm12+$m32*$tm22+$m33*$tm32;
    my $nm33=$m31*$tm13+$m32*$tm23+$m33*$tm33;
    ($m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33)=
      ($nm11,$nm12,$nm13,$nm21,$nm22,$nm23,$nm31,$nm32,$nm33);
    $rotate=1;
  } elsif ($ARGV[0] eq "-rotatez") {
    shift @ARGV;
    my $phi=shift @ARGV;
    $phi=$phi/180.0*3.141592654;
    my $tm11=cos($phi);
    my $tm12=sin($phi);
    my $tm13=0;
    my $tm21=-sin($phi);
    my $tm22=cos($phi);
    my $tm23=0;
    my $tm31=0;
    my $tm32=0;
    my $tm33=1;
    my $nm11=$m11*$tm11+$m12*$tm21+$m13*$tm31;
    my $nm12=$m11*$tm12+$m12*$tm22+$m13*$tm32;
    my $nm13=$m11*$tm13+$m12*$tm23+$m13*$tm33;
    my $nm21=$m21*$tm11+$m22*$tm21+$m23*$tm31;
    my $nm22=$m21*$tm12+$m22*$tm22+$m23*$tm32;
    my $nm23=$m21*$tm13+$m22*$tm23+$m23*$tm33;
    my $nm31=$m31*$tm11+$m32*$tm21+$m33*$tm31;
    my $nm32=$m31*$tm12+$m32*$tm22+$m33*$tm32;
    my $nm33=$m31*$tm13+$m32*$tm23+$m33*$tm33;
    ($m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33)=
      ($nm11,$nm12,$nm13,$nm21,$nm22,$nm23,$nm31,$nm32,$nm33);
    $rotate=1;
  } elsif ($ARGV[0] eq "-segnames") {
    shift @ARGV;
    $segnames=1;
  } elsif ($ARGV[0] eq "-sel") {
    shift @ARGV;
    $sellist=&GenUtil::fragListFromOption(shift @ARGV);
  } elsif ($ARGV[0] eq "-selseq") {
    shift @ARGV;
    $selseq=shift @ARGV;
  } elsif ($ARGV[0] eq "-nsel") {
    shift @ARGV;
    $nsel=shift @ARGV;
  } elsif ($ARGV[0] eq "-exclude") {
    shift @ARGV;
    $excllist=&GenUtil::fragListFromOption(shift @ARGV);
  } elsif ($ARGV[0] eq "-nohetero") {
    shift @ARGV;
    $hetero=0;
  } elsif ($ARGV[0] eq "-chain") {
    shift @ARGV;
    $chain=shift @ARGV;
  } elsif ($ARGV[0] eq "-model") {
    shift @ARGV;
    $selmodel=shift @ARGV;
  } elsif ($ARGV[0] eq "-firstmodel") {
    shift @ARGV;
    $firstmodel=1;
  } elsif ($ARGV[0] eq "-match") {
    shift @ARGV;
    $matchpdb=shift @ARGV;
  } elsif ($ARGV[0] eq "-merge") {
    shift @ARGV;
    $mergepdb=shift @ARGV;
  } elsif ($ARGV[0] eq "-solvate") {
    shift @ARGV;
    $solvate=1;
  } elsif ($ARGV[0] eq "-cubic") {
    shift @ARGV;
    $shape="cubic";
  } elsif ($ARGV[0] eq "-octahedron") {
    shift @ARGV;
    $shape="octahedron";
  } elsif ($ARGV[0] eq "-cutoff" ) {
    shift @ARGV;
    $cutoff=shift @ARGV;
  } elsif ($ARGV[0] eq "-info") {
    shift @ARGV;
    $info=1;
  } elsif ($ARGV[0] eq "-fill") {
    shift @ARGV;
    ($fillinx,$fillseq)=split(/:/,shift @ARGV);
  } elsif ($ARGV[0] eq "-mol2") {
    shift @ARGV;
    $mol2=1;
  } elsif ($ARGV[0] eq "-cleanaux") {
    shift @ARGV;
    $cleanaux=1;
	} elsif ($ARGV[0] eq "-icode") {
		shift @ARGV;
		$icode=1;
	} elsif ($ARGV[0] eq "-alt") {
		shift @ARGV;
		$alt=1;
  } elsif ($ARGV[0] eq "-removeclashes") {
    shift @ARGV;
    $removeclashes=1;
  } elsif ($ARGV[0] eq "-renumwatersegs") {
    shift @ARGV;
    $renumwatersegs=1;
  } elsif ($ARGV[0] eq "-crd") {
    shift @ARGV;
    $crd=1;
    $ignoreseg=0;
  } elsif ($ARGV[0] eq "-crdext") {
    shift @ARGV;
    $crd=1;
    $crdext=1;
    $ignoreseg=0;
  } else {
    $fname = shift @ARGV;
  }
}

my $nmodesampleindex;

if (defined $nmodesampleprefix) {
  $nmodesampleindex=1;
  $nmodeamplitude=$nmodesamplefrom;
  $nmodeweight=0;
}

do {

my $mol=Molecule::new();
if ($mol2) {
  $mol->readMol2($fname);
} else {
  $mol->readPDB($fname,translate=>$inmode,ignoreseg=>$ignoreseg,
		chainfromseg=>$chainfromseg,model=>$selmodel,firstmodel=>$firstmodel,
		icode=>$icode,alt=>$alt);
}

if ($removeclashes) {
  $mol->markClashes();
  my $imol=$mol->clone(1);
  $mol=$imol;
}

$mol->setSSBonds($ssbonds);

if (defined $nsel) {
  $mol->setValidSelection($nsel);
} else {
  $mol->selectChain($chain) if (defined $chain);

  $mol->setValidResidues($sellist) if (defined $sellist);
  $mol->setValidResidues($excllist,1,1) if (defined $excllist); 

  $mol->setValidChain("+",1,1) if (!$hetero);

  if (defined $selseq) {
    my $foundany=$mol->setValidSequence($selseq);
    die "sequence not found" unless ($foundany);
  }
}

$mol=$mol->clone(1) if (defined $sellist || defined $excllist || !$hetero || defined $selseq || defined $chain || defined $nsel);

$mol->setChain($setchain) if (defined $setchain);

if (defined $matchpdb) {
  my $refmol=Molecule::new($matchpdb);
  $mol->match($refmol);
}

if (defined $mergepdb) {
  my $refmol=Molecule::new($mergepdb);
  $mol->merge($refmol);
}

if (defined $fillseq && defined $fillinx) {
  my $nmol=Molecule::new();
  $nmol->fromSequence($fillinx,"CA",$fillseq); 
  $nmol->merge($mol);
  $mol=$nmol->clone(1);
} 

$mol->center() if ($center);
$mol->move($dx,$dy,$dz);
if (defined $nmodefile && -r $nmodefile) {
  my $nmodearr=();
  open INP,"$nmodefile";
  while (<INP>) {
    s/^ +//;
    my @f=split(/ +/);
    my $rec={};
    $rec->{x}=$f[0];
    $rec->{y}=$f[1];
    $rec->{z}=$f[2];
    push(@{$nmodearr},$rec); 
  } 
  close INP;
  $mol->displace($nmodearr,$nmodeamplitude,$nmodeweight);
}
$mol->rotate($m11,$m12,$m13,$m21,$m22,$m23,$m31,$m32,$m33) if (defined $rotate);
$mol->scale($scale) if (defined $scale);
$mol->renumber($renumber) if (defined $renumber);
$mol->shiftResNumber($addres)  if (defined $addres);
$mol->generateSegNames() if (defined $segnames);
$mol->fixCOO() if ($fixcoo);
if (defined $solvate && $solvate) {
  my $err=$mol->solvate($cutoff,$shape);
  print STDERR $err;
}

if ($#{$ions}>=0) {
  $mol->replaceIons($ions);
  $mol=$mol->clone(1);
}

$mol->renumberWaterSegments() if ($renumwatersegs);

if (defined $diffpdbfile) { #note that subtrahend is given as argument before minuend
    my $cmp=&Molecule::new();
    $cmp->readPDB($diffpdbfile);
    $cmp->readPDB($diffpdbfile,translate=>$inmode,ignoreseg=>$ignoreseg,
		  chainfromseg=>$chainfromseg,model=>$selmodel,
			icode=>$icode,alt=>$alt);

    $cmp->selectChain($chain) if (defined $chain);

    $cmp->setValidResidues($sellist) if (defined $sellist);
    $cmp->setValidResidues($excllist,1,1) if (defined $excllist); 

    $cmp->setValidChain("+",1,1) if (!$hetero);


    $cmp=$cmp->clone(1) if (defined $sellist || defined $excllist || !$hetero || defined $selseq || defined $chain);

    $cmp->setChain($setchain) if (defined $setchain);

    $cmp->renumber($renumber) if (defined $renumber);
    $cmp->shiftResNumber($addres)  if (defined $addres);
    $cmp->generateSegNames() if (defined $segnames);
    $cmp->fixCOO() if ($fixcoo);

    if (defined $difflsqfit && $difflsqfit) {
       my $analyze=Analyze::new($mol);
       $analyze->lsqfit($cmp,"cab",1,0);
    }
    if ($addFlag){$mol->add($cmp);}
    else {$mol->subtract($cmp);}
}

if ($info) {
  $mol->info();
} else {
  if (defined $nmodesampleprefix) {
    if ($nmodeamplitude>0.001 || $nmodeamplitude<-0.001 || !$skipzero) {
      $mol->writePDB(sprintf("%s.%d.pdb",$nmodesampleprefix,$nmodesampleindex++),
		     translate=>$outmode,ssbond=>!$nossbond,dohetero=>$hetero);
    }
    $nmodeamplitude+=$nmodesampledelta;
  } else {
    if ($crd) {
      $mol->writeCRD("-",translate=>$outmode,extend=>$crdext);
    } else {
      $mol->writePDB("-",translate=>$outmode,ssbond=>!$nossbond,cleanaux=>$cleanaux,dohetero=>$hetero);
    }
  }
}

} while (defined $nmodesampleprefix && $nmodeamplitude<=$nmodesampleto+0.0001);

1;

