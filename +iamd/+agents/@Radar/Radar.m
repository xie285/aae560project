classdef Radar <  publicsim.agents.hierarchical.Child       & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % fixed location. Take measurements at interval. Missile intercept
    % capabilities? Differentiate between types (i.e. type I has missile
    % intercept capability, type II is S&T only), maybe create entirely new
    % missile battery agent
    properties
        
        status  % to be affected by cyber - Possible states: online (normal), online (alert), hacked (slower response), offline 
        
        target_id
        target_location
        
    end
    
    properties (SetAccess=protected)
        radar_location
        radar_id
        range       % to be affected by cyber
        response_time   % to be affected by cyber
        scan_rate
        pDetection
        
        missile_detect_topic
        missile_assign_topic
        missile_broad_topic
        aerial_detect_topic
        aerial_assign_topic
        aerial_broad_topic
        radar_knockout_topic
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
        AERIAL_DETECT_TOPIC_KEY         = 'AERIAL_DETECT';
        AERIAL_ASSIGN_TOPIC_KEY         = 'AERIAL_ASSIGN';
        AERIAL_BROADCAST_TOPIC_KEY      = 'AERIAL_BROADCAST';
        RADAR_KNOCKOUT_TOPIC_KEY        = 'RADAR_KNOCKOUT';
        
    end
    
    methods
        function obj = Radar()
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();
            
            obj.setPlotter();
            
            obj.type = 'radar';
            obj.status = 'normal';
            
            obj.run_interval = 1;
            obj.last_update_time = -1;
            
        end
        
        function init(obj)
            
            % subscription to data topics
            obj.missile_detect_topic = obj.getDataTopic(obj.MISSILE_DETECT_TOPIC_KEY,'','');
            obj.missile_assign_topic = obj.getDataTopic(obj.MISSILE_ASSIGN_TOPIC_KEY,'','');
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');
            obj.aerial_detect_topic = obj.getDataTopic(obj.AERIAL_DETECT_TOPIC_KEY,'','');
            obj.aerial_assign_topic = obj.getDataTopic(obj.AERIAL_ASSIGN_TOPIC_KEY,'','');
            obj.aerial_broad_topic = obj.getDataTopic(obj.AERIAL_BROADCAST_TOPIC_KEY,'','');
            obj.radar_knockout_topic = obj.getDataTopic(obj.RADAR_KNOCKOUT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_detect_topic);
            obj.subscribeToTopic(obj.missile_assign_topic);
            obj.subscribeToTopic(obj.missile_broad_topic);
            obj.subscribeToTopic(obj.aerial_detect_topic);
            obj.subscribeToTopic(obj.aerial_assign_topic);
            obj.subscribeToTopic(obj.aerial_broad_topic);
            obj.subscribeToTopic(obj.radar_knockout_topic);
          
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(0);
            
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time) >= obj.run_interval
                
                
                % detect and report targets
                %obj.detectTargets(time);
                
                % Update Plot
                plot_info.type = obj.type;
                plot_info.range = obj.range;
                plot_info.radar_id = obj.radar_id;
                plot_info.status= obj.status;

                obj.plotter.updatePlot(obj.radar_location,plot_info);
                
                % Update scheduler
                obj.scheduleAtTime(time+1);
                
            end
            
            obj.last_update_time = time;
            
        end
        
%         function detectTargets(obj,time)
%             % any missile/aerial threats within range of radar are
%             % automatically detected
%             obj.readTargetBroadcast(time)
%         end
%         
%         function readTargetBroadcast(obj,time)
%             [topics,msg] = obj.getNewMessages();
%             
%         end
            
                          
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