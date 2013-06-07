'''
Kevin Fronczak
netformat.py
Netlist Formatter
2013-06-07
'''

import os

class Netlist():
    ''' Class used to create netlists and handle
        allowable ciruit components for genetic algorithm
    '''
    def __init__(self):
        pass
    
    def createHeader(self,netname,netpath,generation,iteration,extra):
        if not os.path.exists(netpath):
            os.makedirs(netpath)
        with open(netpath+netname+'gen_'+generation+'iter_'+iteration+'.sp') as f:
            f.write('*** '+netname+' ***\n')
            f.write('\n*** MODEL Description ***\n')
            f.write('.model nm NMOS level=2 VT0=0.7 KP=120e-6 LAMBDA=0.1\n')
            f.write('.model pm PMOS level=2 VT0=-0.7 KP=40e-6 LAMBDA=0.1\n')
            f.write('\n*** NETLIST Description ***\n')
            f.write(extra)

    def setCkts(self, ckts):
        self.ckt = {}
        if 'R' in allowedCkts:
            self.ckt['R'] = {'num':0, 'n1':0, 'n2':0, 'val':0}
        if 'C' in allowdCkts:
            self.ckt['C'] = {'num':0, 'n1':0, 'n2':0, 'val':0}
        if 'L' in allowdCkts:
            self.ckt['L'] = {'num':0, 'n1':0, 'n2':0, 'val':0}
        if 'M' in allowdCkts:
            self.ckt['M'] = {'num':0, 'd':0, 'g':0, 's':0, 'b':0, 'type':nm, 'W':0, 'L':0}

    
