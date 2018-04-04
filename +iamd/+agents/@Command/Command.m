classdef Command < publicsim.agents.hierarchical.Parent     & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    % 
    properties
        
        target_id
        target_alloc_ac_id
        
    end
    
    properties (SetAccess=private)
        location      
    end
    
    properties (SetAccess=protected)
        last_update_time
        run_interval
    end
    
    properties (Constant)
        
        % Topic Subscriptions
        MISSILE_DETECT_TOPIC_KEY        = 'MISSILE_DETECT';
        MISSILE_ASSIGN_TOPIC_KEY        = 'MISSILE_ASSIGN';
        MISSILE_BROADCAST_TOPIC_KEY     = 'MISSILE_BROADCAST';
        AERIAL_DETECT_TOPIC_KEY         = 'AERIAL_DETECT';
        AERIAL_ASSIGN_TOPIC_KEY         = 'AERIAL_ASSIGN';
        INTERCEPTOR_STATUS_TOPIC_KEY    = 'INT_STATUS';
        RADAR_STATUS_TOPIC_KEY          = 'RAD_STATUS';
        SATELLITE_STATUS_TOPIC_KEY      = 'SAT_STATUS';
        
    end
        
    
    methods
        
        function init(obj)
            
            obj.subscribeToTopic(obj.target_detect_topic);
            obj.subscribeToTopic(obj.target_assign_topic);
            
        end
            
            
        function runAtTime(obj,time)

            obj.disp_INFO(['Simulation Time is ' num2str(time) '\n'])

            if (time - obj.last_update_time) >= obj.run_interval

                    % receive radar messages
                    obj.readDetectionBroadcast(time);

                    % broadcast aircraft allocations to targets
                    obj.broadcastTargetAlloc();

                    obj.scheduleAtTime(time+1);

            end

            obj.last_update_time = time;
        end
    end               
end