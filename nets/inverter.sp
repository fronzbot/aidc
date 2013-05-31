*** Inverter ***

*** MODEL Description ***
.model nm NMOS level=2 VT0=0.7 KP=120e-6 LAMBDA=0.1
.model pm PMOS level=2 VT0=-0.7 KP=40e-6 LAMBDA=0.1

*** NETLIST Description ***
M1 out in vdd vdd pm W=5u L=1u
M2 out in 0 0 nm W=5u L=1u
C1 out 0 1e-12
VDD vdd 0 DC 5
VIN in 0 DC 1
