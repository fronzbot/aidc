*** Voltage Divider ***
*** NETLIST Description ***
R1 vdd vout 1000
R2 vout 0 1000
VDD vdd 0 5

*** SIMULATION Commands ***
.control
dc VDD 0 10 0.1
print V(vout)>> out/temp/voltage_divide.sp_0.txt
.endc

.END
