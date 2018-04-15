classdef Radar <  publicsim.agents.hierarchical.Child       & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % fixed location. Take measurements at interval. Missile intercept

    properties
        
        status  % to be affected by cyber - Possible states: online (normal), online (alert), hacked (slower response), offline, online and intercept capable 
        
        missile_id
        missile_location
        missile_vector
        
        self_effectiveness
        
        pDetect_normal = 100;
        pDetect_alert = 100;
        pDetect_hacked = 2;
        pDetect_offline = 0;
        
    end
    
    properties (SetAccess=protected)
        radar_location
        radar_id
        range       % to be affected by cyber, typical range goes up to ~300 mi
        response_time   % to be affected by cyber
        scan_rate
        num_interceptors
        
        missile_detect_topic
        missile_assign_topic
        missile_broad_topic
        radar_broad_topic
        radar_status_topic
        
        last_update_time
        run_interval 
        
        plotter
        
    end
    
    properties (SetAccess=private)
        type       
    end
    
    properties (Constant)
        
        % Topic Subscriptions
        MISSILE_DETECT_TOPIC_KEY        = 'MISSILE_DETECT';
        MISSILE_ASSIGN_TOPIC_KEY        = 'MISSILE_ASSIGN';
        MISSILE_BROADCAST_TOPIC_KEY     = 'MISSILE_BROADCAST';
        RADAR_BROADCAST_TOPIC_KEY       = 'RADAR_BROADCAST';
        RADAR_STATUS_TOPIC_KEY          = 'RADAR_STATUS';
        
    end
    
    methods
        function obj = Radar()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();           
            
            obj.setPlotter();
            
            obj.type = 'radar';
            obj.status = 'normal';
            obj.num_interceptors = 0;
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
            
        end
        
        function init(obj)
            
            % subscription to data topics
            obj.missile_detect_topic = obj.getDataTopic(obj.MISSILE_DETECT_TOPIC_KEY,'','');
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');

            obj.radar_broad_topic = obj.getDataTopic(obj.RADAR_BROADCAST_TOPIC_KEY,'','');
            obj.radar_status_topic = obj.getDataTopic(obj.RADAR_STATUS_TOPIC_KEY,'',''); 
            
            obj.subscribeToTopic(obj.missile_detect_topic);
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);

%             obj.subscribeToTopic(obj.radar_knockout_topic);
          
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            switch obj.status
                case 'normal'
            
                    if (time - obj.last_update_time) >= obj.run_interval
                
                        obj.broadcastRadarStatus()

                        % detect and report targets
                        obj.detectMissiles()

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
                
                case 'hacked'
                    
                    % do something
                    
                
            end
            
            obj.last_update_time = time;
            
        end       
        
        function detectMissiles(obj)
            [topics,msg] = obj.getNewMessages();
            
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
                                    % remove empty cell array contents
                                    obj.missile_location = obj.missile_location(~cellfun('isempty',obj.missile_location));
                                    obj.missile_id = obj.missile_id(~cellfun('isempty',obj.missile_id));
                                    obj.missile_vector = obj.missile_vector(~cellfun('isempty',obj.missile_vector));
                                    obj.broadcastDetectedMissiles()
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
                                    obj.broadcastDetectedMissiles()
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
                                    obj.broadcastDetectedMissiles()
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
        
        function broadcastDetectedMissiles(obj)
            % send detected signals to command
            msg = struct;
            msg.missile_location            = obj.missile_location;
            msg.missile_id                  = obj.missile_id;
            msg.missile_vector              = obj.missile_vector;
            
            obj.publishToTopic(obj.radar_broad_topic,msg);
           
            % rest messages
%             obj.missile_id = {}; 
%             obj.missile_location = {};          
        end
        
        function broadcastRadarStatus(obj)
            % continuously send status of radar to command
            msg = struct;
            msg.radar_id                = obj.radar_id;
            msg.radar_status            = obj.status;
            msg.radar_num_interceptors  = obj.num_interceptors;
            
            obj.publishToTopic(obj.radar_status_topic,msg);
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
        
        function augmentArsenal(obj,num)
            obj.num_interceptors = obj.num_interceptors + num;
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