classdef Satellite <  publicsim.agents.hierarchical.Child   & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    
    properties
        
        status
        
        target_id
        target_location
        
        threshold_sig
         
    end
    
    properties (SetAccess=protected)
        
        sat_location
        sat_id
        range
        
        missile_detect_topic
        missile_assign_topic
        missile_broad_topic
        aerial_detect_topic
        aerial_assign_topic
        aerial_broad_topic
        satellite_knockout_topic
        last_update_time
        run_interval
               
    end
    
    properties (Constant)
        
        % Topic subscriptions
        MISSILE_DETECT_TOPIC_KEY        = 'MISSILE_DETECT';
        MISSILE_ASSIGN_TOPIC_KEY        = 'MISSILE_ASSIGN';
        MISSILE_BROADCAST_TOPIC_KEY     = 'MISSILE_BROADCAST';
        AERIAL_DETECT_TOPIC_KEY         = 'AERIAL_DETECT';
        AERIAL_ASSIGN_TOPIC_KEY         = 'AERIAL_ASSIGN';
        AERIAL_BROADCAST_TOPIC_KEY      = 'AERIAL_BROADCAST';
        SATELLITE_KNOCKOUT_TOPIC_KEY    = 'SAT_KNOCKOUT';
    end
    
    methods
        
        function obj = Satellite()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();
            
            obj.status = 'online';
            
        end
        
        function init(obj)
            
            % subscription to data topics
            obj.missile_detect_topic = obj.getDataTopic(obj.MISSILE_DETECT_TOPIC_KEY,'','');
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');
            obj.aerial_detect_topic = obj.getDataTopic(obj.AERIAL_DETECT_TOPIC_KEY,'','');
            obj.aerial_assign_topic = obj.getDataTopic(obj.AERIAL_ASSIGN_TOPIC_KEY,'','');
            obj.aerial_broad_topic = obj.getDataTopic(obj.AERIAL_BROADCAST_TOPIC_KEY,'','');
            obj.satellite_knockout_topic = obj.getDataTopic(obj.SATELLITE_KNOCKOUT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_detect_topic);
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);
            obj.subscribeToTopic(obj.aerial_detect_topic);
            obj.subscribeToTopic(obj.aerial_assign_topic);
            obj.subscribeToTopic(obj.aerial_broad_topic);
            obj.subscribeToTopic(obj.satellite_knockout_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval
                
                
%                 % detect and report targets
%                 obj.detectTargets(time);
%                 
%                 % Update Plot
%                 plot_info.type  = obj.type;
%                 plot_info.range = obj.range;
%                 plot_info.radar_id = obj.radar_id;
%                 plot_info.operation_mode= obj.operation_mode;
%                 
%                 obj.plotter.updatePlot(obj.radar_location,plot_info);
                
                % Update scheduler
                obj.scheduleAtTime(time+1);
                
            end
            
            obj.last_update_time = time;
            
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
        
        function p_D = probDetection(obj,heatSig)
            
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