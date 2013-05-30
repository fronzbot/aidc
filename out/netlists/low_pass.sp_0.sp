*** Low Pass Filter ***

*** NETLIST Description ***
R1 vin vout 1000
C1 vout 0 1e-09
VIN vin 0 AC 1

*** SIMULATION Commands ***
.control
pz vin 0 vout 0 VOL PZ
print all>> out/temp/low_pass.sp_0.txt
.endc

.END
