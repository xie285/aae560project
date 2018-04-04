function run_simulation(log_path)

clear all; close all; clc;
import publicsim.*;

logpath = './tmp/scenario';
simInst = publicsim.sim.Instance(logpath);
simTimes.startTime  = 0;
simTimes.endTime    = 200;

obsMgr       = funcs.groups.ObjectManager(0);%#ok<*AGROW>
agentMgr     = funcs.groups.TopicGroup();%#ok<*AGROW>
network      = funcs.comms.Network();%#ok<*AGROW>
dataService  = funcs.comms.DataService();%#ok<*AGROW>

num_rad = 4;    % fixed
num_sat = 1;    % fixed, have one overhead persistent satellite
num_mis = 2;

num_systems = [num_rad num_sat num_mis];

% instantiate agents
[~,agentMgr,obsMgr] = iamd.models.buildModel(simInst,simTimes,...
    num_systems,{'iamd.agents.Radar','iamd.agents.Satellite','iamd.agents.Missile'});

% get agent lists
radarAgents         = agentMgr.getChildObjects('Radar');
satelliteAgents     = agentMgr.getChildObjects('Satellite');
missileAgents       = agentMgr.getChildObjects('Missile');

% setup the scenario
iamd.models.setupScenario(radarAgents,satelliteAgents,missileAgents);

% simulate the scenario
simInst.runUntil(simTimes.startTime,simTimes.endTime);

% access log files for data from simulation
logger = publicsim.sim.Logger(logpath);
logger.restore()

duration = simTimes.endTime - simTimes.startTime;

end
