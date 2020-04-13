#!/usr/bin/env python3
import re, argparse, sys
#import numpy as np
import matplotlib.pyplot as plt

INPUT_FILE = 'energies.2h.gammas.dat'
AU2EV = 27.2114

def read_cmd():
   """Read cmdline params"""
   desc = "Script for processing auger spectra"
   parser = argparse.ArgumentParser(description=desc)
   parser.add_argument('--energies', dest = "enfile", default = 'energies.2h.txt', help='file 2h energies')
   parser.add_argument('--gammas', dest = "gamfile", default = None, help='file with experimental data')
   parser.add_argument('--experiment', dest = "expfile", default = None, help='file with experimental data')
   return parser.parse_args()

opts = read_cmd()
# first auger peak position
FIRST_AUGER_PEAK = 500 # eV
ENERGY_FILE = 'energies.2h.txt'

def shift_energies(en, factor, eshift):
   en_shifted = []
   for e in en:
      en_shifted.append(factor*e + eshift)
   return en_shifted

def normalize_peaks(gammas, peak_index, peak_height):
   current_height = gammas[peak_index][0]
   heights = []
   errors = []
   f = peak_height / current_height
   for peak in gammas:
      heights.append(f*peak[0])
      errors.append(f*peak[1])

   return heights, errors


energies_2h = []
partial_gammas = []
with open(opts.enfile, 'r') as f:
   for line in f:
      energies_2h.append(AU2EV*float(line.strip()))

with open(opts.gamfile, 'r') as f:
   for line in f:
      l = line.split()
      if re.search('#', l[0].strip()):
         continue
      if len(l) < 2: # Allow comments as 3rd column
         print("ERROR: invalid data")
      gamma = float(l[0])
      std = float(l[1])
      partial_gammas.append( (gamma, std) )

en_shifted = []
en_shifted = shift_energies(energies_2h, -1, FIRST_AUGER_PEAK+energies_2h[0])

# Normalize first peak to 100 (arb. units) for comparison with article
# The Auger electron spectrum of water vapour
# https://doi.org/10.1016/0009-2614(75)85615-6

normalized_intensities, normalized_errors = normalize_peaks(partial_gammas, 0, 100) 

for i in range(len(en_shifted)):
   print(en_shifted[i], normalized_intensities[i], normalized_errors[i])

plt.bar(en_shifted, normalized_intensities, yerr=normalized_errors, ecolor='black' )
plt.show()

