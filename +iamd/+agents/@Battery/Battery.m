classdef Battery < publicsim.agents.hierarchical.Child   & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    
    properties
        
        status
        
        missile_id
        missile_location
        missile_vector
        
        assigned_missile_ids
        
        intercepted_missiles
        time_of_intercept
        
        intercept_data
        
        num_intercepts
    end
    
    properties (SetAccess=protected)
        
        battery_location
        battery_id
        range           % thaad range is 125 mi
        
        battery_status_topic
        
        missile_assign_topic
        missile_broad_topic
        missile_destroy_topic
        
        self_effectiveness
        
        pDetect_normal = 100;
        pDetect_alert = 100;
        pDetect_hacked = 20;
        pDetect_offline = 0;
        
        last_update_time
        run_interval
   
        plotter
        
    end
    
    properties (SetAccess=private)
        type
        sim_end_time
    end
    
    properties (Constant)
        
        % Topic subscriptions
        BATTERY_STATUS_TOPIC_KEY            = 'BATTERY_STATUS';
%         BATTERY_BROADCAST_TOPIC_KEY         = 'BATTERY_BROADCAST';
        MISSILE_BROADCAST_TOPIC_KEY         = 'MISSILE_BROADCAST';
        MISSILE_ASSIGN_TOPIC_KEY            = 'MISSILE_ASSIGN';
        MISSILE_DESTROY_TOPIC_KEY           = 'MISSILE_DESTROY';
        
    end
    
    methods
        
        function obj = Battery()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();
            
            obj.setPlotter();
            
            obj.type = 'battery';
            obj.status = 'normal';
            obj.num_intercepts = 0;
            obj.assigned_missile_ids = [];
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
        end
        
        function init(obj)
            obj.battery_status_topic = obj.getDataTopic(obj.BATTERY_STATUS_TOPIC_KEY,'','');
%             obj.battery_broad_topic = obj.getDataTopic(obj.BATTERY_BROAD_TOPIC_KEY,'','');
            
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');
            obj.missile_destroy_topic = obj.getDataTopic(obj.MISSILE_DESTROY_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
        end
            
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval
                
                [topics,msg] = obj.getNewMessages();
                
                % find any missiles in range
                obj.detectMissiles(topics,msg)
                
                obj.broadcastBatteryStatus()
                % receive any missile target assignments from command
                obj.getInterceptOrders(topics,msg)
                
                % destroy any assigned missiles in range 
                obj.interceptMissile(time);

                % Update Plot
                plot_info.type  = obj.type;
                plot_info.range = obj.range;
                plot_info.battery_id = obj.battery_id;
                plot_info.status= obj.status;
                
                obj.plotter.updatePlot(obj.battery_location,plot_info);
                
                % Update scheduler
                obj.scheduleAtTime(time+1);
                
                % reset
                obj.missile_id = {};
                obj.missile_location = {};
                obj.missile_vector = {};
                obj.assigned_missile_ids = {};
               
            end
            
            obj.last_update_time = time;
            if time == obj.sim_end_time
                % output intercept results to command window at end of sim
                number_of_intercepts = length(unique(obj.intercepted_missiles));
                fprintf('Battery %d: \n', obj.battery_id)
                fprintf('Number of Intercepts  = %d \n',number_of_intercepts)               
                [unq,ia] = unique(obj.intercepted_missiles,'stable');
                unqt = [];
                for i = 1:length(obj.time_of_intercept)
                    for j = 1:length(ia)
                        if i == ia(j)
                            unqt = [unqt,obj.time_of_intercept(i)];
                        end
                    end
                end
                ids = sprintf('%d ',unq);
                toi = sprintf('%d ',unqt);
                fprintf('Intercepted MissileID = %s \n',ids)
                fprintf('Interception Times = %s \n', toi)
            end
        end
        
        function getInterceptOrders(obj,topics,msg)
            % reads messages from commands on orders to intercept missile.
            % If the order's battery_id matches with that of the agents,
            % then that agent is responsible for calling the
            % interceptMissile function on the missileId

             for ii = 1:length(topics)
                 
                 if isequal(topics{ii}.type,obj.MISSILE_ASSIGN_TOPIC_KEY)
                     if msg{ii}.assignedBattery == obj.battery_id
                         if isempty(obj.assigned_missile_ids)
                            obj.assigned_missile_ids = (cell2mat(msg{ii}.missileId));
                         else 
                             % should add on to list of missiles that
                             % battery is responsible for
                            n = length(obj.assigned_missile_ids);
                            obj.assigned_missile_ids(n+1) = (cell2mat(msg{ii}.missileId));
                         end
                         obj.assigned_missile_ids = unique(obj.assigned_missile_ids);
                     end
                 end

             end
                
        end
        
        function interceptMissile(obj,time)

            if ~isempty(obj.assigned_missile_ids) && ~isempty(obj.missile_id)
                    for i = 1:length(obj.assigned_missile_ids)
                        for j = 1:length(obj.missile_id)
                            if obj.assigned_missile_ids(i) == obj.missile_id{j}
                                msg = struct;
                                msg.missile_destroy_id          = obj.missile_id{j};

                                obj.publishToTopic(obj.missile_destroy_topic,msg);
                                
                                obj.intercepted_missiles = [obj.intercepted_missiles, obj.missile_id{j}];
%                                 [obj.intercepted_missiles,ia] = unique(obj.intercepted_missiles,'stable');
%                                 obj.num_intercepts = length(obj.intercepted_missile_list);                            
                                obj.time_of_intercept = [obj.time_of_intercept,time];
%                                 for k = 1:length(obj.time_of_intercept)
%                                     if k == ia
%                                         obj.intercept_data = [obj.intercepted_missiles; obj.time_of_intercept(k)]
%                                     end
%                                 end
                                
                                
                            end
                        end
                    end
                    
            end
            
        end
        
        function detectMissiles(obj,topics,msg)
%             [topics,msg] = obj.getNewMessages();
            
            kk=1;
            
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.MISSILE_BROADCAST_TOPIC_KEY)
                    if norm(obj.battery_location - msg{ii}.missile_location) <= obj.range
                        switch obj.status
                            case {'normal'}
                                if randi(100,1,1) <= obj.pDetect_normal
                                    obj.missile_location{kk}    = msg{ii}.missile_location;
                                    obj.missile_id{kk}          = msg{ii}.missile_id;
                                    obj.missile_vector{kk}      = msg{ii}.missile_vector;
                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                end
                            case {'alert'}
                                if randi(100,1,1) <= obj.pDetect_alert
                                    obj.missile_location{kk}    = msg{ii}.missile_location;
                                    obj.missile_id{kk}          = msg{ii}.missile_id;
                                    obj.missile_vector{kk}      = msg{ii}.missile_vector;
                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                end
                            case {'hacked'}
                                if randi(100,1,1) <= obj.pDetect_hacked
                                    obj.missile_location{kk}    = msg{ii}.missile_location;
                                    obj.missile_id{kk}          = msg{ii}.missile_id;
                                    obj.missile_vector{kk}      = msg{ii}.missile_vector;
                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                end
                            case {'offline'}
                                % do nothing
                        end
                        kk = kk+1;
                    end
                end
            end
            kk = 1; % reset
            
        end
        
        
        function broadcastBatteryStatus(obj)
            % continuously send status of radar to command
            msg = struct;
            msg.battery_id          = obj.battery_id;
            msg.battery_status      = obj.status;
            msg.battery_location    = obj.battery_location;
            msg.battery_range       = obj.range;
            
            obj.publishToTopic(obj.battery_status_topic,msg);
        end
        
        function setBatteryId(obj,id)
            obj.battery_id = id;
        end
        
        function setBatteryLocation(obj,loc)
            obj.battery_location = loc;
        end
        
        function setBatteryRange(obj,range)
            obj.range = range;
        end

        function setPlotter(obj)
            obj.plotter = iamd.funcs.Plotter;
        end
        
        function number_of_intercepts = getNumberOfIntercepts(obj)
            number_of_intercepts = obj.num_intercepts;
        end
        
        function status = getStatus(obj)
            status = obj.status;
        end
        
        function setEndTime(obj,time)
            obj.sim_end_time = time;
        end
    end
    
    methods (Static)
        function addPropertyLogs(obj)
            
            obj.addPeriodicLogItems({'getStatus'});
            
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