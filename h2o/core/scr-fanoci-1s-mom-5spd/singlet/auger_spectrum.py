#!/usr/bin/env python3
import re, argparse, sys

INPUT_FILE = 'energies.2h.gammas.dat'
AU2EV = 27.2114

def read_cmd():
   """Read cmdline params"""
   desc = "Script for processing auger spectra"
   parser = argparse.ArgumentParser(description=desc)
   parser.add_argument('input_file',metavar='INPUT_FILE', help='Input file: energies partial_gammas')
   return parser.parse_args()

opts = read_cmd()
inpfile = opts.input_file
# first auger peak position
FIRST_AUGER_PEAK = 500 # eV

def shift_energies(en, factor, eshift):
   en_shifted = []
   for e in en:
      en_shifted.append(factor*e + eshift)
   return en_shifted

def normalize_peaks(gammas,peak_index, peak_height):
   current_height = gammas[peak_index]
   heights = []
   for peak in gammas:
      heights.append(peak/current_height*peak_height)

   return heights


energies_2h = []
partial_gammas = []
with open(inpfile, 'r') as f:
   for line in f:
      l = line.split()
      if re.search('#', l[0].strip()):
         continue
      if len(l) < 2: # Allow comments as 3rd column
         print("ERROR: invalid data")

      energies_2h.append(float(l[0]) * AU2EV)
      partial_gammas.append(float(l[1]))

en_shifted = []
en_shifted = shift_energies(energies_2h, -1, FIRST_AUGER_PEAK+energies_2h[0])

# Normalize first peak to 100 (arb. units) for comparison with article
# The Auger electron spectrum of water vapour
# https://doi.org/10.1016/0009-2614(75)85615-6

normalized_intensities = normalize_peaks(partial_gammas, 0, 100) 

for i in range(len(en_shifted)):
   print(en_shifted[i], normalized_intensities[i])

