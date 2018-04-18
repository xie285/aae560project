classdef Satellite <  publicsim.agents.hierarchical.Child   & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % Satellite Agent that detects missiles within its range with a
    % probability. Any detects will be sent to command for radar cueing.
    % Sending messages occurs with a probability. Nominal performance,
    % satellite detects threats with 100% probability and sends messages
    % with 100% probability. Under cyber-attack, satellite will experience
    % smaller probabilities of detection and being able to successfully
    % transmit any messages to command.
    properties
        
        status
        
        missile_id_cue
        missile_location_cue
        missile_vector_cue
        
        % probabilities of detection under satellite status
%         pDetect_normal = 95;
%         pDetect_hacked = 20;
%         pDetect_offline = 0;
        
        % probabilities of sending signal to command under status
%         pBroadcast_normal = 100;
%         pBroadcast_hacked = 20;
         
    end
    
    properties (SetAccess=protected)
        
        sat_location
        sat_id
        range
        
        self_effectiveness
        pDetect
        pBroadcast
        
        missile_assign_topic
        missile_broad_topic
        satellite_broad_topic
        satellite_status_topic
        satellite_knockout_topic
        last_update_time
        run_interval
        
        plotter
    end
    
    properties (SetAccess=private)
        type
        time_of_broadcast_list 
        num_cues
        running_missile_id_cue_list
        satellite_comm_disrupt_topic
        
        sim_end_time
    end
    
    properties (Constant)
        
        % Topic subscriptions
        MISSILE_BROADCAST_TOPIC_KEY                 = 'MISSILE_BROADCAST';
        MISSILE_ASSIGN_TOPIC_KEY                    = 'MISSILE_ASSIGN';
        SATELLITE_BROADCAST_TOPIC_KEY               = 'SATELLITE_BROADCAST';
        SATELLITE_STATUS_TOPIC_KEY                  = 'SATELLITE_STATUS';
        SATELLITE_KNOCKOUT_TOPIC_KEY                = 'SAT_KNOCKOUT';
        SATELLITE_COMMUNICATIONS_DISRUPT_TOPIC_KEY  = 'SATELLITE_COMM_DISRUPT';
    end
    
    methods
        
        function obj = Satellite()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();
            
            obj.setPlotter();
            
            obj.type = 'satellite';
            obj.status = 'normal';
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
            
        end
        
        function init(obj)
            obj.selfEffectiveness(obj.self_effectiveness);
            
            % subscription to data topics
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'',''); 
            obj.satellite_broad_topic = obj.getDataTopic(obj.SATELLITE_BROADCAST_TOPIC_KEY,'','');
            obj.satellite_status_topic  = obj.getDataTopic(obj.SATELLITE_STATUS_TOPIC_KEY,'','');
            obj.satellite_comm_disrupt_topic = obj.getDataTopic(obj.SATELLITE_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);
            obj.subscribeToTopic(obj.satellite_comm_disrupt_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval
                
                obj.broadcastSatelliteStatus();
                % detect and report targets
                if randi(100,1,1) <= obj.pDetect
                    obj.detectMissiles()
                end
                if randi(100,1,1) <= obj.pBroadcast
                    obj.broadcastDetectedMissiles()
                    obj.num_cues = [obj.num_cues, length((unique(cell2mat(obj.running_missile_id_cue_list))))];
                    obj.time_of_broadcast_list = [obj.time_of_broadcast_list, time];                   
                end
                
                % Update Plot
                plot_info.type  = obj.type;
                plot_info.range = obj.range;
                plot_info.sat_id = obj.sat_id;
                plot_info.status= obj.status;
                
                obj.plotter.updatePlot(obj.sat_location,plot_info);
                
                obj.missile_location_cue = {};
                obj.missile_id_cue = {};  
                
                % Update scheduler
                obj.scheduleAtTime(time+1);
                               
            end
            
            obj.last_update_time = time;
            
            if time == obj.sim_end_time
                data = [obj.time_of_broadcast_list; obj.num_cues];
                fileID = fopen('+iamd/+models/data/satellite.txt','w');
                fprintf(fileID, 'Satellite 1 Data: Time vs Number of Cues Successfully sent\r\n\r\n');
                fprintf(fileID,'%d  %d \r\n',data);
                fclose(fileID);
            end
            
        end
        
        function detectMissiles(obj)
            [topics,msg] = obj.getNewMessages();
            
            kk=1;
            
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.MISSILE_BROADCAST_TOPIC_KEY)
                    if norm(obj.sat_location - msg{ii}.missile_location) <= obj.range
%                         if randi(100,1,1) <= obj.pDetect
                            obj.missile_location_cue{kk}        = msg{ii}.missile_location;
                            obj.missile_id_cue{kk}              = msg{ii}.missile_id;
                            obj.missile_vector_cue{kk}          = msg{ii}.missile_vector;

                            % remove empty cell array contents
                            obj.running_missile_id_cue_list = [obj.running_missile_id_cue_list,obj.missile_id_cue];
                            obj.missile_location_cue = obj.missile_location_cue(~cellfun('isempty',obj.missile_location_cue));
                            obj.missile_id_cue = obj.missile_id_cue(~cellfun('isempty',obj.missile_id_cue));
                            obj.missile_vector_cue = obj.missile_vector_cue(~cellfun('isempty',obj.missile_vector_cue));

%                             obj.broadcastDetectedMissiles()
%                         end
%                         switch obj.status
%                             case {'normal'}
%                                 if randi(100,1,1) <= obj.pDetect_normal
%                                     obj.missile_location_cue{kk}        = msg{ii}.missile_location;
%                                     obj.missile_id_cue{kk}              = msg{ii}.missile_id;
%                                     obj.missile_vector_cue{kk}          = msg{ii}.missile_vector;
%                                     
%                                     % remove empty cell array contents
%                                     obj.missile_location_cue = obj.missile_location_cue(~cellfun('isempty',obj.missile_location_cue));
%                                     obj.missile_id_cue = obj.missile_id_cue(~cellfun('isempty',obj.missile_id_cue));
%                                     obj.missile_vector_cue = obj.missile_vector_cue(~cellfun('isempty',obj.missile_vector_cue));
% 
%                                     obj.broadcastDetectedMissiles()
%                                 end
%                             case {'hacked'}
%                                 if randi(100,1,1) <= obj.pDetect_hacked
%                                     obj.missile_location_cue{kk}        = msg{ii}.missile_location;
%                                     obj.missile_id_cue{kk}              = msg{ii}.missile_id;
%                                     obj.missile_vector_cue{kk}          = msg{ii}.missile_vector;
%                                     
%                                     % remove empty cell array contents
%                                     obj.missile_location_cue = obj.missile_location_cue(~cellfun('isempty',obj.missile_location_cue));
%                                     obj.missile_id_cue = obj.missile_id_cue(~cellfun('isempty',obj.missile_id_cue));
%                                     obj.missile_vector_cue = obj.missile_vector_cue(~cellfun('isempty',obj.missile_vector_cue));
%                                     if randi(100,1,1) <= obj.pBroadcast_hacked
%                                         obj.broadcastDetectedMissiles()
%                                     end
%                                 end
%                         end
                        kk = kk+1;
                    end
                end
            end
            kk = 1; % reset
        end
        
        function broadcastDetectedMissiles(obj)
            % send detected signals to command for cueing
            msg = struct;
            msg.satellite_id                = obj.sat_id;
            msg.missile_location_cue        = obj.missile_location_cue;
            msg.missile_id_cue              = obj.missile_id_cue;
            msg.missile_vector_cue          = obj.missile_vector_cue;
            
%             switch obj.status
%                 case 'normal'
            if randi(100,1,1) <= obj.pBroadcast
                obj.publishToTopic(obj.satellite_broad_topic,msg);
            end
%                     if randi(100,1,1) <= obj.pBroadcast_normal
%                         obj.publishToTopic(obj.satellite_broad_topic,msg);
%                     end
%                 case 'hacked'
%                     if randi(100,1,1) <= obj.pBroadcast_hacked
%                         obj.publishToTopic(obj.satellite_broad_topic,msg);
%                     end
%             end
            
        end
        
        function broadcastSatelliteStatus(obj)
            % continuously send status of radar to command
            msg = struct;
            msg.satellite_id                = obj.sat_id;
            msg.satellite_status            = obj.status;
            msg.satellite_location          = obj.sat_location;
            msg.satellite_range             = obj.range;
            
            obj.publishToTopic(obj.satellite_status_topic,msg);
        end
        
        function selfEffectiveness(obj,SE)
            obj.pDetect = SE;
            obj.pBroadcast = SE;
        end
        
        function setSE(obj,SE)
            obj.self_effectiveness = SE;
        end
            
        function setSatelliteId(obj,id)
            obj.sat_id = id;
        end
        
        function setSatelliteLocation(obj,location)
            obj.sat_location = location;
        end
        
        function setSatelliteRange(obj,range)
            obj.range = range;
        end
               
        function setPlotter(obj)
            obj.plotter = iamd.funcs.Plotter;           
        end
        
        function setEndTime(obj,time)
            obj.sim_end_time = time;
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