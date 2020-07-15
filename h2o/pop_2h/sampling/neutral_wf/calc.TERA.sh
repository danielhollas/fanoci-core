#!/bin/bash
# Script for creating TeraChem inputs.
# Called within script RecalcGeoms.sh
# Three arguments are passed to this script: 
#  1. input geometry 
#  2. name of the input file that this script needs to create
#  3. number of processors

geometry=$1
input=$2
nproc=$3              # number of processors

cp $geometry  $input.xyz

cat > $input <<EOF
coordinates	$input.xyz	
scrdir          scr_$input
basis		cc-pvdz
method          rhf
charge          0
spinmult	1
gpus 		$nproc

# AES params
run		auger
aes_pop       yes
core_atom     0
core_mo       0

casci         yes
cassinglets   10
castriplets   6
closed        1
active        4

precision      double
threall        1.0e-20
convthre       1.0e-7

mom           no # Neutral WF for now
end
EOF



