classdef Radar <  publicsim.agents.hierarchical.Child       & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % Radar Agent detects missiles within its range with a probability. Any
    % detects will be sent to command for interceptor battery assignment.
    % Sending messages occurs with a probability.
    % Nominal performance: radar detects with 80% success rate, unless it
    % has been previously cued by command from a satellite detection, then
    % its is 100%. Sends messages with 100% success rate.
    % Hacked performance : radar detects at lower rate of success and
    % is able to communicate with command at a lower success rate.

    properties
        
        status  % to be affected by cyber - Possible states: online (normal), online (alert), hacked (slower response), offline, online and intercept capable 
        
        missile_id
        missile_location
        missile_vector
        
        detected_missiles
        time_of_detect

%         pDetect_normal = 100;
%         pDetect_alert = 100;
%         pDetect_hacked = 10;
%         pDetect_offline = 0;
%         
%         pBroadcast_normal = 100;
%         pBroadcast_hacked = 20;
%         
%         pReceiveCommunications_normal = 100;
%         pReceiveCommunications_hacked = 20;
        
    end
    
    properties (SetAccess=protected)
        radar_location
        radar_id
        range       % to be affected by cyber, typical range goes up to ~300 mi
        
        self_effectiveness
        pDetect_normal
        pDetect_alert
        pBroadcast
        pReceiveCommunications
        
        missile_detect_topic
        missile_assign_topic
        missile_broad_topic
        radar_broad_topic
        radar_status_topic
        radar_cue_topic
        
        last_update_time
        run_interval 
        
        plotter
        
    end
    
    properties (SetAccess=private)
        radar_comm_disrupt_topic
        isCued
        
        end_cue
        
        type
        
        time_of_detect_list
        detected_missiles_list
        
        sim_end_time
    end
    
    properties (Constant)
        
        % Topic Subscriptions
        MISSILE_DETECT_TOPIC_KEY                    = 'MISSILE_DETECT';
        MISSILE_ASSIGN_TOPIC_KEY                    = 'MISSILE_ASSIGN';
        MISSILE_BROADCAST_TOPIC_KEY                 = 'MISSILE_BROADCAST';
        RADAR_BROADCAST_TOPIC_KEY                   = 'RADAR_BROADCAST';
        RADAR_STATUS_TOPIC_KEY                      = 'RADAR_STATUS';
        RADAR_CUE_TOPIC_KEY                         = 'RADAR_CUE';
        RADAR_COMMUNICATIONS_DISRUPT_TOPIC_KEY      = 'RADAR_COMM_DISRUPT';
        
    end
    
    methods
        function obj = Radar()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();           
            
            obj.setPlotter();
            
            obj.type = 'radar';
            obj.status = 'normal';
            obj.isCued = 0;
            obj.end_cue = 0;
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
            
        end
        
        function init(obj)
            
            obj.selfEffectiveness(obj.self_effectiveness);
            
            % subscription to data topics
            obj.missile_detect_topic = obj.getDataTopic(obj.MISSILE_DETECT_TOPIC_KEY,'','');
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');

            obj.radar_broad_topic = obj.getDataTopic(obj.RADAR_BROADCAST_TOPIC_KEY,'','');
            obj.radar_status_topic = obj.getDataTopic(obj.RADAR_STATUS_TOPIC_KEY,'',''); 
            obj.radar_cue_topic = obj.getDataTopic(obj.RADAR_CUE_TOPIC_KEY,'','');
            
            obj.radar_comm_disrupt_topic = obj.getDataTopic(obj.RADAR_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_detect_topic);
            obj.subscribeToTopic(obj.radar_cue_topic);
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);

            obj.subscribeToTopic(obj.radar_cue_topic);
            
            obj.subscribeToTopic(obj.radar_comm_disrupt_topic);
          
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval

                % check cue status
                obj.endCueSequence(time);
                % get messages
                [topics,msg] = obj.getNewMessages();
                
                if obj.isCued == 1
                    obj.status = 'alert';               
                elseif obj.isCued == 0
                    obj.status = 'normal';
                end

                obj.broadcastRadarStatus()
                if randi(100,1,1) <= obj.pReceiveCommunications
                    obj.getCue(topics,msg,time)
                end

                % detect and report targets
                obj.detectMissiles(topics,msg,time)

                % Update Plot
                plot_info.type = obj.type;
                plot_info.range = obj.range;
                plot_info.radar_id = obj.radar_id;
                plot_info.status = obj.status;

                obj.plotter.updatePlot(obj.radar_location,plot_info);
                obj.missile_id = {}; 
                obj.missile_location = {}; 

                % Update scheduler
                obj.scheduleAtTime(time+1);
            end            
            obj.last_update_time = time;
            
            % output detection data to command window
            if time == obj.sim_end_time
                [obj.detected_missiles,ia] = unique(obj.detected_missiles_list,'stable');
                obj.time_of_detect = [];
                for i = 1:length(obj.time_of_detect_list)
                    for j = 1:length(ia)
                        if ia(j) == i
                            obj.time_of_detect = [obj.time_of_detect,obj.time_of_detect_list(i)];
                        end
                    end
                end
%                 fprintf('Radar %d: \n', obj.radar_id)
%                 ids = sprintf('%d ',obj.detected_missiles);
%                 tod = sprintf('%d ',obj.time_of_detect);
%                 fprintf('Detected MissileID = %s \n', ids)
%                 fprintf('Fastest Detect Time = %s \n',tod)
                
                data_radar = [obj.detected_missiles' obj.time_of_detect'];
                filename = '+iamd/test_data.xlsx';
                text = {'Missile ID','Detect Times','Missile ID','Detect Times','Missile ID','Detect Times'};
                xlswrite(filename,text,'Radar Data','A1')
                switch obj.radar_id
                    case 1
                        if ~isempty(data_radar)
                            xlswrite(filename,data_radar,'Radar Data','A2')
                        end
                    case 2
                        if ~isempty(data_radar)
                            xlswrite(filename,data_radar,'Radar Data','C2')
                        end
                    case 3
                        if ~isempty(data_radar)
                            xlswrite(filename,data_radar,'Radar Data','E2')
                        end
                end

            end
            
        end       
        
        function detectMissiles(obj,topics,msg,time)
           
            kk=1;
            
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.MISSILE_BROADCAST_TOPIC_KEY)
                    if norm(obj.radar_location - msg{ii}.missile_location) <= obj.range
                        switch obj.status
                            case {'normal'}
                                if randi(100,1,1) <= obj.pDetect_normal
                                    obj.missile_location{kk}    = msg{ii}.missile_location;
                                    obj.missile_id{kk}          = msg{ii}.missile_id;
                                    obj.missile_vector{kk}      = msg{ii}.missile_vector;
                                    
                                    obj.time_of_detect_list = [obj.time_of_detect_list, time];                  
                                    obj.detected_missiles_list = [obj.detected_missiles_list, obj.missile_id{kk}];


                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                    obj.broadcastDetectedMissiles()
                                    if randi(100,1,1) <= obj.pBroadcast
                                        obj.broadcastDetectedMissiles()
                                    end
                                end
                            case {'alert'}
                                if randi(100,1,1) <= obj.pDetect_alert
                                    obj.missile_location{kk}    = msg{ii}.missile_location;
                                    obj.missile_id{kk}          = msg{ii}.missile_id;
                                    obj.missile_vector{kk}      = msg{ii}.missile_vector;
                                    
                                    obj.time_of_detect_list = [obj.time_of_detect_list, time];                  
                                    obj.detected_missiles_list = [obj.detected_missiles_list, obj.missile_id{kk}];
                                    
                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
%                                     obj.broadcastDetectedMissiles()
                                    if randi(100,1,1) <= obj.pBroadcast
                                        obj.broadcastDetectedMissiles()
                                    end
                                            
                                end

                        end
                        kk = kk+1;
                    end
                end
            end
            kk = 1; % reset
            
        end
        
        function broadcastDetectedMissiles(obj)
            % send detected signals to command
            msg = struct;
            msg.missile_location            = obj.missile_location;
            msg.missile_id                  = obj.missile_id;
            msg.missile_vector              = obj.missile_vector;

            obj.publishToTopic(obj.radar_broad_topic,msg);
       
        end
        
        function broadcastRadarStatus(obj)
            % continuously send status of radar to command
            msg = struct;
            msg.radar_id                = obj.radar_id;
            msg.radar_status            = obj.status;
            msg.radar_location          = obj.radar_location;
            msg.radar_range             = obj.range;
            
            obj.publishToTopic(obj.radar_status_topic,msg);
        end
        
        function getCue(obj,topics,msg,time)
            % see if command notifies of any incoming missiles detected by
            % satellite            
            for ii = 1:length(topics)               
                if isequal(topics{ii}.type,obj.RADAR_CUE_TOPIC_KEY)
                    if msg{ii}.cuedRadar == obj.radar_id
                        obj.isCued = 1;
                        obj.end_cue = time + 10; % cueing lasts for 10 seconds after
                    end
                end
            end
        end
        
        function endCueSequence(obj,time)
            if time < obj.end_cue
                % nothing happens
            else
                % reset radar to uncued non-alert status
                obj.isCued = 0;
            end
        end
        
        function selfEffectiveness(obj,SE)
            obj.pDetect_normal = 0.5 * SE;
            obj.pDetect_alert = SE;
            obj.pBroadcast = SE;
            obj.pReceiveCommunications = SE;
        end
        
        function setSE(obj,SE)
            obj.self_effectiveness = SE;
        end
                          
        function status = getRadarStatus(obj)
            status = obj.status;
        end
        
        function setRadarRange(obj,range)
            obj.range = range;
        end
        
        function setRadarId(obj,id)
            obj.radar_id = id;
        end
        
        function setRadarLocation(obj,radar_position)
            obj.radar_location = radar_position;
        end       
        
        function setEndTime(obj,time)
            obj.sim_end_time = time;
        end
        
        function setPlotter(obj)
            obj.plotter = iamd.funcs.Plotter();
        end
        
    end
    
    %%%% TEST METHODS %%%%
    
    methods (Static, Access = {?publicsim.tests.UniversalTester})
        function tests = test()
            % Run all tests TODO Make gooder
            tests = {};
            %tests{1} = 'publicsim.tests.agents.base.MovableTest.test_Movable';
        end
    end
    
end