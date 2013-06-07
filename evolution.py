'''
Kevin Fronczak
evolution.py
Genetic Algorithm
2013-06-07
'''

from random import uniform
import netformat
import ngpy

class GA():
    ''' Genetic Algorithm for circuit creation '''
    def __init__(self, n, nodeCount):
        self.nodeCount = nodeCount
        self.n = n

    def initialPop(self, popNum, bounds):
        ''' Initializes circuit with random values '''
        ''' bounds variable should be list of tuples with organization:
            [(Rup, Rlow), (Cup, Clow), (Lup, Llow), (MW, ML)]
        '''
        population = []
        for i in range(0, popNum):
            ''' Need to randomize number of components and randomize values'''
            pass
            

    def fitness(self):
        pass

    def selectBest(self):
        pass

    def crossover(self):
        pass

    def mutate(self):
        pass

    def shouldTerminate(self):
        pass


def main():
    n = netformat.Netlist()
    g = GA(n)
    
    g.initialPop()
    while not shouldTerminate(currentGen):
        '''
        Run fitness on current generation
        choose two best netlists -> save them
        Re-randomize and choose two best netlists -> save them
        From four best, run fitness again and choose two best -> save
        Create random mask to choose what characteristics will be passed to children
        If masks overlap, randomly mutate that gene
        '''
