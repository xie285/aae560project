classdef Analysis < publicsim.agents.hierarchical.Child   & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked
    
    properties
        battery_broad_topic
        missile_destroy_topic
    end
    
    properties (Constant)
        BATTERY_BROADCAST_TOPIC_KEY         = 'BATTERY_BROADCAST';
        MISSILE_DESTROY_TOPIC_KEY           = 'MISSILE_DESTROY';
    end
    
    methods
        function obj = Analysis()
            
        end
        
        function init(obj)
            obj.battery_broad_topic = obj.getDataTopic(obj.BATTERY_BROAD_TOPIC_KEY,'','');
            obj.missile_destroy_topic = obj.getDataTopic(obj.MISSILE_DESTROY_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_destroy_topic);
            obj.subscribeToTopic(obj.battery_broad_topic);
            
            obj.scheduleAtTime(0);
        end
    end
    
end