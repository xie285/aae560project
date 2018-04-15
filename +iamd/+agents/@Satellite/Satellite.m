classdef Satellite <  publicsim.agents.hierarchical.Child   & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    
    properties
        
        status
        
        missile_id_cue
        missile_location_cue
        
        pDetect_normal = 100;
        pDetect_alert = 100;
        pDetect_hacked = 20;
        pDetect_offline = 0;
         
    end
    
    properties (SetAccess=protected)
        
        sat_location
        sat_id
        range
        
        missile_assign_topic
        missile_broad_topic
        satellite_broad_topic
        satellite_knockout_topic
        last_update_time
        run_interval
        
        plotter
    end
    
    properties (SetAccess=private)
        type
    end
    
    properties (Constant)
        
        % Topic subscriptions
        MISSILE_BROADCAST_TOPIC_KEY         = 'MISSILE_BROADCAST';
        MISSILE_ASSIGN_TOPIC_KEY            = 'MISSILE_ASSIGN';
        SATELLITE_BROADCAST_TOPIC_KEY       = 'SATELLITE_BROADCAST';
        SATELLITE_KNOCKOUT_TOPIC_KEY        = 'SAT_KNOCKOUT';
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
            
            % subscription to data topics
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'',''); 
            obj.satellite_broad_topic = obj.getDataTopic(obj.SATELLITE_BROADCAST_TOPIC_KEY,'','');
            obj.satellite_knockout_topic = obj.getDataTopic(obj.SATELLITE_KNOCKOUT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);
            obj.subscribeToTopic(obj.satellite_knockout_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval
                
                
                % detect and report targets
                obj.detectMissiles()
                
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
            
        end
        
        function detectMissiles(obj)
            [topics,msg] = obj.getNewMessages();
            
            kk=1;
            
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.MISSILE_BROADCAST_TOPIC_KEY)
                    if norm(obj.sat_location - msg{ii}.missile_location) <= obj.range
                        switch obj.status
                            case {'normal'}
                                if randi(100,1,1) <= obj.pDetect_normal
                                    obj.missile_location_cue{kk}        = msg{ii}.missile_location;
                                    obj.missile_id_cue{kk}              = msg{ii}.missile_id;
                                    
                                    % remove empty cell array contents
                                    obj.missile_location_cue = obj.missile_location_cue(~cellfun('isempty',obj.missile_location_cue));
                                    obj.missile_id_cue = obj.missile_id_cue(~cellfun('isempty',obj.missile_id_cue));

                                    obj.broadcastDetectedMissiles()
                                end
                            case {'offline'}
                        end
                        kk = kk+1;
                    end
                end
            end
            kk = 1; % reset
        end
        
        function broadcastDetectedMissiles(obj)
            % send detected signals to command for cueing
            msg = struct;
            msg.missile_location_cue        = obj.missile_location_cue;
            msg.missile_id_cue              = obj.missile_id_cue;
            msg.satellite_id                = obj.sat_id;
            
            obj.publishToTopic(obj.satellite_broad_topic,msg);
            
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