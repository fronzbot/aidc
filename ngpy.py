'''
Kevin Fronczak
ngpy.py
Python->ngspice interface
2013-05-30
'''

from subprocess import PIPE, Popen
import os

class Spice():
    ''' Spice class is used to interface with ngspice by calling netlists,
        and performing simulations.  The netlists is complied, simulated,
        and the output is printed to a file.  The command-line screen is
        also dumped to a text file for every run cycle in order to allow
        for quick debugging'''
    def __init__(self):
        self.iter = 0   # Current iteration of process - used for file labeling

    def sim(self, netlist, operation, output):
        '''Takes a netlist, appends the desired operation, creates new netlist
           and then calls ngspice for simulation.  The output is piped to a temp
           file and then converted to a csv file.'''
        self.netlist    = netlist
        self.netname    = os.path.basename(self.netlist)
        self.outfile    = 'out/temp/'+self.netname+'_'+str(self.iter)+'.txt'
        self.append_command(operation, output)
        self.net_string = 'source out/netlists/'+self.netname+'_'+str(self.iter)+'.sp\n'

        self.command = bytes(self.net_string,'UTF-8')
        self.ngspice = Popen(['bin/ngspice-25_64_mc.exe','-n','-p'], stdin=PIPE, stdout=PIPE, stderr=PIPE)
        self.outdump = self.ngspice.communicate(self.command)[0]
        self.dump(self.outdump)

        self.convert_to_csv()
        return 0

    def append_command(self,operation,output):
        nettext = []
        with open(self.netlist,'r') as f:
            for line in f.readlines():
                nettext.append(line)

        # Delete output file if it exists - we only want the most current
        # simulation result in the file.
        if os.path.isfile(self.outfile):
            os.remove(self.outfile)

        # Likewise, delete output file if it exists - we only want the most current
        # simulation result in the file.
        if os.path.isfile('out/netlists/'+self.netname+'_'+str(self.iter)+'.sp'):
            os.remove('out/netlists/'+self.netname+'_'+str(self.iter)+'.sp')
            
        with open('out/netlists/'+self.netname+'_'+str(self.iter)+'.sp', 'w') as f:
            for line in nettext:
                f.write(line)
            f.write('\n*** SIMULATION Commands ***\n')
            f.write('.control\n')
            f.write(operation+'\n')
            f.write(output+'>> '+self.outfile+'\n')
            f.write('.endc\n')
            f.write('\n.END\n')

        return 0
        
    def dump(self,text_to_dump):
        ''' Takes screen information from ngspice and dumps it to a text file'''
        with open('out/dump/'+self.netname+str(self.iter)+'_dump.txt','w') as f:
            f.write(str(text_to_dump, 'UTF-8'))

        return 0

    def convert_to_csv(self):
        ''' Converts SPICE output to CSV file '''
        data_raw = []
        with open(self.outfile, 'r') as f:
            for line in f.readlines():
                data_raw.append(line)

        # Check if the first value of the data list is an integer
        # Since the format of SPICE outputs is to have an index number
        # before each data entry, only lines with an index should contain
        # valid data
        data = []
        for line in data_raw:
            data_list = line.split('\t')
            try:
                int(data_list[0])
                data.append(','.join(data_list[1:]))
            except ValueError:
                pass

        with open('out/'+self.netname+'_'+str(self.iter)+'.csv', 'w') as f:
            for line in data:
                f.write(line)
        
    def end(self):
        '''Kills the ngspice subprocess'''
        self.ngspice.kill()

        return 0

if __name__ == '__main__':
    sp = Spice()
    sp.sim('bin/voltage_divide.sp', 'dc VDD 0 10 0.1', 'print V(vout)')
    sp.end()
