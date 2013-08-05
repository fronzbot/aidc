aidc
====
Program to optimize the design of DC-DC converter controllers via transfer function parameters.

Usage
-----
In MATLAB, run aidc([opts]) in order to run default settings.  Optional argument is a structure of option parameters described below with the default setting in paranethses:

1. mode (DCM): selects the desired Boost Converter operating mode (either CCM, or DCM).
2. Algoritm (GA): selects the desired algorithm to run (either GA or PSO).
3. Iter (20): Maximum allowed iterations.
4. Size (30): Number of drones for GA or swarm size for PSO.
5. PSOType (Constrict): Type of PSO Algorithm to run (if PSO selected in Algorithm option).  This can be Contrict, for a constrcition algorithm, CDIW (chaotic descending inertial weight) or CRIW (Chaotic random inertial weight).
6. L (18e-6 for DCM; 180e-6 for CCM): Inductance of boost converter inductor.
7. C (4.7e-6 for DCM and CCM): Capacitance of boost converter output filter capacitor.
8. R (300 for DCM, 10 for CCM): Load Resistance of boost converter.
9. Vo (5.5 for DCM and CCM): Output Voltage of boost converter.
10. Vs (2.75 for DCM, 3.5 for CCM): Input Voltage of boost converter.
11. Fs (350e3 for DCM and CCM): Switching Frequency of boost converter.
12. Print (false): Selects whether to print the step response of the current solution every [PrintNum] iterations (prints to file at 600 dpi in png format).
13. PrintNum (5): Frequency of step response prints.
14. Plot (true): Selects whether to plot the current solution every iteration.
