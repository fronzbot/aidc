from random import uniform

class PSO():
    ''' PSO algorithm for optimizing circuit topologies '''
    def __init__(self):
        self.swarm      = 0     # Number of particles in swarm
        self.params     = []    # List of parameters (dimensions)
        self.pos        = {}    # Position of particles (dictionary)
        self.vel        = {}    # Velocity of particles (dictionary)
        self.bestPos    = {}    # Dictionary of best known particle positions
        self.swarmBest  = []    # Best swarm position in each dimension
        self.maxIter    = 0     # Maximum number of iterations allowed
        self.bound      = []    # Bound Limits for PSO
        self.thresh     = 0     # Maximum fitting value to allow

        with open('pso.csv', 'w') as f:
            f.write('iteration,val1,val2,fit\n')
        
    def initialize(self):
        for particle in range(0,self.swarm):
            for dim in self.params:
                self.pos[dim,particle]      = round(uniform(self.bound[0], self.bound[1]),3)
                self.bestPos[dim,particle]  = self.pos[dim,particle]
                self.vel[dim,particle]      = round(uniform(-10, 10),3)
            
            if not self.swarmBest:
                self.swarmBest.append(self.pos[0,particle])
                self.swarmBest.append(self.pos[1,particle])
                
            if self.fit(self.pos[0,particle], self.pos[1,particle]) < self.fit(self.swarmBest[0], self.swarmBest[1]):
                self.swarmBest[0] = self.pos[0,particle]
                self.swarmBest[1] = self.pos[1,particle]
    
    def fit(self,p1,p2):
        ''' Fitting function for Voltage Divider '''
        mod_v = 1
        mod_p = 1
        V = p1/(p1+p2)
        P = V*V*100/(p1+p2) # Vin = 10

        Vfit = 100*(V-0.5)*(V-0.5)
        
        return round(Vfit + P,5)

    def run(self):
        iteration = 0
        while (iteration < self.maxIter):
            for particle in range(0,self.swarm):
                for dim in self.params:
                    rp = uniform(0,1)
                    rg = uniform(0,1)

                    currentPos  = self.pos[dim,particle]
                    currentVel  = self.vel[dim,particle]
                    currentBest = self.bestPos[dim,particle]

                    self.vel[dim,particle] = round(currentVel + rp*(currentBest - currentPos) + rg*(self.swarmBest[dim]-currentPos),3)
                    self.pos[dim,particle] = round(currentPos + self.vel[dim,particle],3)

                    
                    # Constrain particle positions to boundry
                    if self.pos[dim,particle] < self.bound[0] or self.pos[dim,particle] > self.bound[1]:
                        self.pos[dim,particle] = round(uniform(self.bound[0], self.bound[1]),3)
                    '''
                    # Constrain particle velocities to boundry
                    if self.vel[dim,particle] < -10 or self.vel[dim,particle] > 10:
                        self.vel[dim,particle] = round(uniform(-1, 10),3)
                    '''
                currentP1 = self.pos[0,particle]
                currentP2 = self.pos[1,particle]
                bestP1    = self.bestPos[0,particle]
                bestP2    = self.bestPos[1,particle]
                if self.fit(currentP1, currentP2) < self.fit(bestP1, bestP2):
                    self.bestPos[0,particle] = currentP1
                    self.bestPos[1,particle] = currentP2

                    if self.fit(currentP1, currentP2) < self.fit(self.swarmBest[0], self.swarmBest[1]):
                        self.swarmBest[0] = currentP1
                        self.swarmBest[1] = currentP2
                
            iteration = iteration + 1
            self.debug(iteration,self.fit(self.swarmBest[0], self.swarmBest[1]))
            if not iteration%10:
                print('Iteration = '+str(iteration))
                
    def debug(self,i,fitting):
        '''Prints output of current iteration as well as best parameter values'''
        with open('pso.csv', 'a') as f:
            f.write(str(i)+','+str(self.swarmBest[0])+','+str(self.swarmBest[1])+','+str(fitting)+'\n')
                    
if __name__ == '__main__':
    p = PSO()
    p.swarm   = 500
    p.params  = [0,1]
    p.maxIter = 200
    p.bound   = [1,1000]
    p.thresh  = 0.001
    p.initialize()
    p.run()
    print('DONE!')






















        
