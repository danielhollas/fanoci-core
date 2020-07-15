#!/bin/bash

# Driver script for spectra simulation using the reflection principle.
# One can also add gaussian and/or lorentzian broadening.

# It works both for UV/VIS spectra and photoionization spectra.

# REQUIRED FILES:
# calc_spectrum.py
# extractG09.sh or similar

########## SETUP #####
name=aes_1s_neutral_vdz    # name of the job
states=16      # number of excited states
               # (ground state does not count)
istart=1       # Starting index
imax=1      # number of calculations
grep_function="grep_TERA_AES" # this function parses the outputs of the calculations
               # It is imported e.g. from extractG09.sh
filesuffix="inp.out" # i.e. "com.out" or "log"
indices=""	# file with indices of geometries to use. Leave empty for using all geometries from istart to imax

## SETUP FOR SPECTRA GENERATION ## 
gauss=1.0 # Uncomment for Gaussian broadening parameter in eV, set to 0 for automatic setting
#lorentz=0.2  # Uncomment for Lorentzian broadening parameter in eV
de=0.05     # Energy bin for histograms
ioniz=false # Set to "true" for ionization spectra (i.e. no transition dipole moments)
aes=true 
##############

# Import grepping functions
source extractTERA_FranckCondon.sh

i=$istart
samples=0
rawdata="$name.rawdata.$imax.dat"
rm -f $rawdata

function getData {
   index=$1
   file=$name.$index.$filesuffix
   if  [[ -f $file ]];then
      $grep_function $file $rawdata $states

      if [[ $? -eq "0" ]];then
         if [[ ! -z $subset ]] && [[ $subset > 0 ]];then
                echo $file >> $rawdata
         fi
         let samples++
         echo -n "$i "
      fi
   fi
}
if [[ -n $indices ]] && [[ -f $indices ]]; then
   mapfile -t subsamples < $indices
   for i in "${subsamples[@]}"
   do
      getData $i
   done
else
   while [[ $i -le $imax ]]
   do
      getData $i
      let i++
   done
fi

echo
echo Number of samples: $samples
if [[ $samples == 0 ]];then
	exit 1
fi

options=" --de $de "
if [[ ! -z $gauss ]];then
   options=" -s $gauss "$options
fi
if [[ ! -z $lorentz ]];then
   options=" -t $lorentz "$options
fi
if [[ ! -z $subset ]] && (( $subset > 0 ));then
   options=" -S $subset "$options
   if [[ ! -z $cycles ]] && (( $cycles > 0 ));then
      options=" -c $cycles "$options
   fi
   if [[ ! -z $ncores ]] && (( $ncores > 0 ));then
      options=" -j $ncores "$options
   fi
   if [[ ! -z $jobs_per_core ]] && (( $jobs_per_core > 0 ));then
      options=" -J $jobs_per_core "$options
   fi
fi
if [[ $ioniz = "true" ]];then
   options=" --notrans "$options
fi

if [[ $aes = "true" ]];then
   options="--arbunits "$options
fi

./calc_spectrum.py -n $samples $options $rawdata

