function [network,agentMgr,obsMgr] = buildModel(simInst,simTimes,numAgents,agentClasses) %#ok<INUSD>
    % buildModel
    
    import publicsim.*;
    
    % Network characteristics
    bandwidth    = inf;
    latency     = 0;
    
    obsMgr       = funcs.groups.ObjectManager(simTimes.startTime);
    agentMgr     = funcs.groups.TopicGroup();
    network      = funcs.comms.Network();
    dataService  = funcs.comms.DataService();
    
    % Level 1: Create generic network paths from IDS unit to targets
    upSwitch   = network.createSwitch();
    downSwitch = network.createSwitch();
    simInst.AddCallee(upSwitch);
    simInst.AddCallee(downSwitch);
    network.createP2PLink(upSwitch,downSwitch,bandwidth,latency);
    
    % Derive agent class "short name"
    % (mainly for network visualization - not essential here)
    for ii=1:length(agentClasses)
        agentShortClass{ii} = strsplit(agentClasses{ii},'.');%#ok<*AGROW>
        agentShortClass{ii} = agentShortClass{ii}{end}; %#ok<*AGROW>
    end
    
    % Level 2: Add agent(s) with client switches 
    %          (this generated fully connected network)
    
    for ii=1: length(numAgents)
        for jj=1:numAgents(ii)
            
            clientSwitch = network.createSwitch();                          % Create switch for agent
            simInst.AddCallee(clientSwitch);                                % Add switch to sim
            eval(['newAgent = ' agentClasses{ii}]);%#ok<*AGROW>             % Create agent
            simInst.AddCallee(newAgent);                                    % Add agent to sim
            newAgent.setNetworkName([agentShortClass{ii} ':' num2str(newAgent.id)]); % Label for network graph (was: agentClass)
            agentMgr.appendToTopic([agentShortClass{ii} '/'],newAgent);     % For finding agents (was: [newAgent.netName'/' num2str(newAgent.id)])  
            newAgent.addToNetwork(clientSwitch,dataService);                % Add to network

            % Connect to "a" and "b": agent-->a, b-->agent 
            network.createP2PLink(newAgent.clientSwitch,upSwitch              ,bandwidth,latency);%#ok<*AGROW>
            network.createP2PLink(downSwitch            ,newAgent.clientSwitch,bandwidth,latency);%#ok<*AGROW>
 
        end
    end
end