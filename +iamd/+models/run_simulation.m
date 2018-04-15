function run_simulation(log_path)

clear all; close all; clc;
import publicsim.*;

logpath = './tmp/scenario';
simInst = publicsim.sim.Instance(logpath);
simTimes.startTime  = xlsread('+iamd/+models/inputs2.xlsx','Simulation','A2','basic');
simTimes.endTime    = xlsread('+iamd/+models/inputs2.xlsx','Simulation','B2','basic');

obsMgr       = funcs.groups.ObjectManager(0);%#ok<*AGROW>
agentMgr     = funcs.groups.TopicGroup();%#ok<*AGROW>
network      = funcs.comms.Network();%#ok<*AGROW>
dataService  = funcs.comms.DataService();%#ok<*AGROW>

num_rad = 3;    % fixed
num_sat = 1;    % fixed, have one overhead persistent satellite
num_com = 1;    % fixed
num_mis = 10;
num_bat = 4;

num_systems = [num_rad num_sat num_com num_mis num_bat];

% instantiate agents
[~,agentMgr,obsMgr] = iamd.models.buildModel(simInst,simTimes,...
    num_systems,{'iamd.agents.Radar','iamd.agents.Satellite','iamd.agents.Command','iamd.agents.Missile','iamd.agents.Battery'});

% get agent lists
radarAgents         = agentMgr.getChildObjects('Radar');
satelliteAgents     = agentMgr.getChildObjects('Satellite');
commandAgents       = agentMgr.getChildObjects('Command');
missileAgents       = agentMgr.getChildObjects('Missile');
batteryAgents       = agentMgr.getChildObjects('Battery');

% setup the scenario
iamd.models.setupScenario(radarAgents,satelliteAgents,commandAgents,missileAgents,batteryAgents);

% simulate the scenario
simInst.runUntil(simTimes.startTime,simTimes.endTime);

% access log files for data from simulation
logger = publicsim.sim.Logger(logpath);
logger.restore()
% 
% duration = simTimes.endTime - simTimes.startTime;
% parsed_data = iamd.funcs.parseLogs(logpath,batteryAgents,duration);
% iamd.models.processData(parsed_data,batteryAgents)

end
