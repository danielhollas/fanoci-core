coordinates	h2o-aes.1.com.xyz	
scrdir         scr_h2o-aes.1.com
basis		cc-pvdz
method          rhf
charge          0
spinmult	1
gpus 		1

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
