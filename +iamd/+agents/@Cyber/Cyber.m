classdef Cyber < publicsim.agents.hierarchical.Child        & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    
    properties
        status
    end
    
    properties (SetAccess=protected)
        scheduleTime
        
        radar_comm_disrupt_topic
        satellite_comm_disrupt_topic
        command_comm_disrupt_topic
        
        last_update_time
        run_interval
        
    end
    
    properties (Constant)
        RADAR_COMMUNICATIONS_DISRUPT_TOPIC_KEY      = 'RADAR_COMM_DISRUPT';
        SATELLITE_COMMUNICATIONS_DISRUPT_TOPIC_KEY  = 'SATELLITE_COMM_DISRUPT';
        COMMAND_COMMUNICATIONS_DISRUPT_TOPIC_KEY    = 'COMMAND_COMM_DISRUPT';
    end
    
    methods
        
        function obj = Cyber()
            
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Networked();  
            
            obj.run_interval = 1;
            
        end
        
        function init(obj)
            obj.radar_comm_disrupt_topic = obj.getDataTopic(obj.RADAR_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            obj.satellite_comm_disrupt_topic = obj.getDataTopic(obj.SATELLITE_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            obj.command_comm_disrupt_topic = obj.getDataTopic(obj.COMMAND_COMMUNICATIONS_DISRUPT_TOPIC_KEY,'','');
            
            obj.scheduleAtTime(0)
            obj.last_update_time = -1;
        end
        
        function runAtTime(obj,time)
            
            if (time - obj.last_update_time >= obj.run_interval) 
                
                time_since_update = time - obj.last_update_time;
                
            end
        end
        
        
    end
            
end