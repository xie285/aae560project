classdef Interceptor < publicsim.agents.base.Movable        & ...
        publicsim.agents.base.Periodic                      & ...
        publicsim.agents.base.Networked                     & ...
        publicsim.agents.hierarchical.Child                 
    
    properties
        id
        location
        speed
        
        target_id
        target_location
        target_heading
        cruise_speed
        intercept_speed       
    end
    
    properties (SetAccess=protected)
        range
    end
    
    properties (Constant)
        
        % Topic Subscriptions
        AERIAL_DETECT_TOPIC_KEY         = 'TARGET_DETECT';
        AERIAL_ASSIGN_TOPIC_KEY         = 'TARGET_ASSIGN';
        AERIAL_BROADCAST_TOPIC_KEY      = 'TARGET_BROADCAST';
        INTERCEPTOR_STATUS_TOPIC_KEY    = 'INT_STATUS';
    end
        
end