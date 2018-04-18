classdef Command < publicsim.agents.hierarchical.Parent     & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % 
    properties
        
        status % standby, delgate, disrupted standby, disrupted delegate, offline
        % missiles detected by radar
        missile_id
        missile_location 
        missile_vector
        
        % missiles detected by satellite for cueing                
        missile_id_cue
        missile_location_cue
        missile_vector_cue
        
        assigned_missiles
        time_of_assignment
        
        
%         pReceiveCommunications_normal = 100;
%         pReceiveCommunications_hacked = 20;
%         
%         pSendAssignment_normal = 100;
%         pSendAssignment_hacked = 20;
%         
%         assignment_time     % operability
%         
%         pSendCueCommand_normal = 100;
%         pSendCueCommand_hacked = 20;
    
    end
    
    properties (SetAccess=protected)
        command_location
        command_id
        
        self_effectiveness
        pReceiveCommunications
        pSendAssignment
        pSendCueCommand
        
        missile_assign_topic
        missile_broad_topic
        radar_cue_topic
        
        radar_broad_topic
        radar_status_topic
        
        time_of_detect
        time_of_intercept
        
        battery_status_topic
        
        satellite_status_topic
        satellite_broad_topic
        
        last_update_time
        run_interval
               
        plotter
    end
    
    properties (SetAccess=private)
        command_comm_disrupt_topic
        
        radar_id
        radar_status
        radar_location
        radar_range
        
        battery_id
        battery_status
        battery_location
        battery_range
        
        satellite_id
        satellite_status
        satellite_location
        satellite_range
        
        missile_id_assign_list
        time_of_assign_list
    
        type    
        sim_end_time
    end
    
    properties (Constant)
        
        % Topic Subscriptions
        MISSILE_ASSIGN_TOPIC_KEY                    = 'MISSILE_ASSIGN';
        RADAR_BROADCAST_TOPIC_KEY                   = 'RADAR_BROADCAST';
        RADAR_STATUS_TOPIC_KEY                      = 'RADAR_STATUS';
        RADAR_CUE_TOPIC_KEY                         = 'RADAR_CUE';
        BATTERY_STATUS_TOPIC_KEY                    = 'BATTERY_STATUS';
        SATELLITE_STATUS_TOPIC_KEY                  = 'SATELLITE_STATUS';
        SATELLITE_BROADCAST_TOPIC_KEY               = 'SATELLITE_BROADCAST';
        COMMAND_COMMUNICATIONS_DISRUPT_TOPIC_KEY    = 'COMMAND_COMM_DISRUPT';
    end
        
    
    methods
        
        function obj = Command()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();
            
            obj.setPlotter();
            
            
            obj.type = 'command';
            obj.status = 'normal';
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
        end
        
        function init(obj)
            
            obj.selfEffectiveness(obj.self_effectiveness);
            
            obj.missile_assign_topic        = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');     
            obj.radar_broad_topic           = obj.getDataTopic(obj.RADAR_BROADCAST_TOPIC_KEY,'','');
            obj.radar_status_topic          = obj.getDataTopic(obj.RADAR_STATUS_TOPIC_KEY,'','');
            obj.radar_cue_topic             = obj.getDataTopic(obj.RADAR_CUE_TOPIC_KEY,'','');
            obj.battery_status_topic        = obj.getDataTopic(obj.BATTERY_STATUS_TOPIC_KEY,'','');
            obj.satellite_status_topic      = obj.getDataTopic(obj.SATELLITE_STATUS_TOPIC_KEY,'','');
            obj.satellite_broad_topic       = obj.getDataTopic(obj.SATELLITE_BROADCAST_TOPIC_KEY,'','');
            obj.command_comm_disrupt_topic  = obj.getDataTopic(obj.COMMAND_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.radar_broad_topic);
            obj.subscribeToTopic(obj.radar_status_topic);
            obj.subscribeToTopic(obj.battery_status_topic);
            obj.subscribeToTopic(obj.satellite_status_topic);
            obj.subscribeToTopic(obj.satellite_broad_topic);
            obj.subscribeToTopic(obj.command_comm_disrupt_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
            
            
        function runAtTime(obj,time)

            obj.disp_INFO(['Simulation Time is ' num2str(time) '\n'])

            if (time - obj.last_update_time) >= obj.run_interval  
                
                    [topics,msg] = obj.getNewMessages();

                    % receive messages
                    obj.resourceList(topics,msg)
                    if randi(100,1,1) <= obj.pReceiveCommunications
                        obj.receiveBroadcasts(topics,msg);
                    end
                    if ~isempty(obj.missile_id_cue)
                        if randi(100,1,1)<=obj.pSendCueCommand
                            for i = 1:length(obj.missile_id_cue)
                                obj.cueRadar(obj.missile_id_cue(i),i)
                            end
                        end
                    end
                    if ~isempty(obj.missile_id)
                        if randi(100,1,1)<=obj.pSendAssignment
                            for i = 1:length(obj.missile_id)
                                obj.assignBattery(obj.missile_id(i),i)
                                obj.missile_id_assign_list = [obj.missile_id_assign_list, obj.missile_id(i)];
                                obj.time_of_assign_list = [obj.time_of_assign_list, time];
                            end
                        end
                    end                   

                                       
                    plot_info.type = obj.type;
                    plot_info.command_id = obj.command_id;
                    plot_info.status = obj.status;

                    obj.plotter.updatePlot(obj.command_location,plot_info);

                    obj.scheduleAtTime(time+1);
                    
                    % reset
                    obj.radar_id = {};
                    obj.radar_status = {};
                    obj.radar_location = {};
                    obj.radar_range = {};
                    obj.battery_id = {};
                    obj.battery_status = {};
                    obj.battery_location = {};
                    obj.battery_range = {};
                    obj.satellite_id = {};
                    obj.satellite_status = {};
                    obj.satellite_location = {};
                    obj.satellite_range = {};
                    obj.missile_id = {};
                    obj.missile_location = {};
                    obj.missile_vector = {};
                    obj.missile_id_cue = {};
                    obj.missile_vector_cue = {};
                    obj.missile_location_cue = {};

            end

            obj.last_update_time = time;
            
            if time == obj.sim_end_time;
                [obj.assigned_missiles,ia] = unique(cell2mat(obj.missile_id_assign_list),'stable');
                obj.time_of_assignment = [];
                for i = 1:length(obj.time_of_assign_list)
                    for j = 1:length(ia)
                        if ia(j) == i
                            obj.time_of_assignment = [obj.time_of_assignment, obj.time_of_assign_list(i)];
                        end
                    end
                end
                fprintf('Command %d: \n', obj.command_id)
                ids = sprintf('%d ',obj.assigned_missiles);
                tod = sprintf('%d ',obj.time_of_assignment);
                fprintf('Assigned MissileID = %s \n', ids)
                fprintf('Time of Assignment = %s \n',tod)
                
                data = [obj.assigned_missiles; obj.time_of_assignment];
                
                fileID = fopen('+iamd/+models/data/command1.txt','w');
                fprintf(fileID, 'Command 1 Data: Assigned Missile ID and Time of Assignment\r\n\r\n');
                fprintf(fileID,'%d  %d \r\n',data);
                fclose(fileID);
            end
        end
        
        function assignBattery(obj,missileId,index)
            % takes detected missile ID and decides which battery to assign
            % for intercept
            % extrapolate some end point from missile's current location
            % and its cruise vector
            missile_end_extrap = obj.missile_location{index} + 100*obj.missile_vector{index};
            distances = zeros(1,length(obj.battery_id));
            for i = 1:length(obj.battery_id)
                distances(i) = obj.point2line(obj.battery_location{i},obj.missile_location{index},missile_end_extrap);
            end
            
            [closest_dist, ind] = min(distances);
            if closest_dist <= obj.battery_range{ind}
                msg = struct;
                msg.missileId           = missileId;
                msg.assignedBattery     = ind;
                
                obj.publishToTopic(obj.missile_assign_topic,msg);

            else
                obj.disp_INFO(['Missile ' num2str(missileId) ' is out of range of any available batteries!' '\n'])              
            end
            
            
        end
        
        function cueRadar(obj,missileCueId,index)
            if ~isempty(obj.missile_vector_cue)
                missile_cue_end_extrap = obj.missile_location_cue{index} + 100*obj.missile_vector_cue{index};
            end
            distances = zeros(1,length(obj.radar_id));
            for i = 1:length(obj.radar_id)
                distances(i) = obj.point2line(obj.radar_location{i},obj.missile_location_cue{index},missile_cue_end_extrap);
            end
            [closest_dist, ind] = min(distances);
            if closest_dist <= obj.radar_range{ind}
                msg = struct;
                msg.missileCueId    = missileCueId;
                msg.cuedRadar       = ind;

                obj.publishToTopic(obj.radar_cue_topic,msg);
            end
        end
        
        function receiveBroadcasts(obj,topics,msg)           
            kk=1;
            kk2=1;
            
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.RADAR_BROADCAST_TOPIC_KEY)
                      
                    for jj = 1:length(msg{ii}.missile_id)
                        obj.missile_id{kk} = msg{ii}.missile_id{jj};
                        obj.missile_location{kk} = msg{ii}.missile_location{jj};
                        obj.missile_vector{kk} = msg{ii}.missile_vector{jj};
                    end                            
                    obj.missile_id = num2cell(unique(cell2mat(obj.missile_id)));
                    % remove empty cell array contents
                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                    
                    kk = kk + 1;
                elseif isequal(topics{ii}.type,obj.SATELLITE_BROADCAST_TOPIC_KEY)

                    for ll = 1:length(msg{ii}.missile_id_cue);
                        obj.missile_id_cue{kk2} = msg{ii}.missile_id_cue{ll};
                        obj.missile_location_cue{kk2} = msg{ii}.missile_location_cue{ll};
                        obj.missile_vector_cue{kk2} = msg{ii}.missile_vector_cue{ll};
                    end

                    kk2 = kk2 + 1;
                end
       
            end 
            
            % reset
            kk = 1;
            kk2 = 1;
        end
        
        function resourceList(obj,topics,msg)
            kk3 = 1;
            kk4 = 1;
            kk5 = 1;
                for ii = 1:length(topics)

                    if isequal(topics{ii}.type,obj.RADAR_STATUS_TOPIC_KEY)
                        % gets statuses of all radars
                        obj.radar_id{kk3}               = msg{ii}.radar_id;
                        obj.radar_status{kk3}           = msg{ii}.radar_status;
                        obj.radar_location{kk3}         = msg{ii}.radar_location;
                        obj.radar_range{kk3}            = msg{ii}.radar_range;
                        % remove empty cell array contents 
                        obj.radar_id                    = obj.radar_id(~cellfun('isempty',obj.radar_id));
                        obj.radar_status                = obj.radar_status(~cellfun('isempty',obj.radar_status));
                        obj.radar_location              = obj.radar_location(~cellfun('isempty',obj.radar_location));
                        obj.radar_range                 = obj.radar_range(~cellfun('isempty',obj.radar_range));                            

                    elseif isequal(topics{ii}.type,obj.BATTERY_STATUS_TOPIC_KEY)
                        % gets statuses of all missile batteries
                        obj.battery_id{kk4}             = msg{ii}.battery_id;
                        obj.battery_status{kk4}         = msg{ii}.battery_status;
                        obj.battery_location{kk4}       = msg{ii}.battery_location;
                        obj.battery_range{kk4}          = msg{ii}.battery_range;
                        obj.battery_id                  = obj.battery_id(~cellfun('isempty',obj.battery_id));
                        obj.battery_status              = obj.battery_status(~cellfun('isempty',obj.battery_status));
                        obj.battery_location            = obj.battery_location(~cellfun('isempty',obj.battery_location));
                        obj.battery_range               = obj.battery_range(~cellfun('isempty',obj.battery_range));
                    elseif isequal(topics{ii}.type,obj.SATELLITE_STATUS_TOPIC_KEY)
                        obj.satellite_id{kk5}               = msg{ii}.satellite_id;
                        obj.satellite_status{kk5}           = msg{ii}.satellite_status;
                        obj.satellite_location{kk5}         = msg{ii}.satellite_location;
                        obj.satellite_range{kk5}            = msg{ii}.satellite_range;
                        obj.satellite_id                    = obj.satellite_id(~cellfun('isempty',obj.satellite_id));
                        obj.satellite_status                = obj.satellite_status(~cellfun('isempty',obj.satellite_status));
                        obj.satellite_location              = obj.satellite_location(~cellfun('isempty',obj.satellite_location));
                        obj.satellite_range                 = obj.satellite_range(~cellfun('isempty',obj.satellite_range));
                                
                    end
                    kk3 = kk3 + 1;
                    kk4 = kk4 + 1;
                    kk5 = kk5 + 1;
                end
                kk3 = 1;
                kk4 = 1;
                kk5 = 1;
        end
        
        function selfEffectiveness(obj,SE)
            obj.pReceiveCommunications = SE;
            obj.pSendAssignment = SE;
            obj.pSendCueCommand = SE;            
        end
        
        function setSE(obj,SE)
            obj.self_effectiveness = SE;
        end
        
        function setCommandId(obj,id)
            obj.command_id = id;
        end
        
        function setCommandLocation(obj,loc)
            obj.command_location = loc;
        end
        
        function setEndTime(obj,time)
            obj.sim_end_time = time;
        end
        
        function setPlotter(obj)
            obj.plotter = iamd.funcs.Plotter;
        end
    end 
    
    methods (Static)
        function d = point2line(point, v1, v2)
            a = v1 - v2;
            b = point - v2;
            d = norm(cross(a,b)) / norm(a);
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