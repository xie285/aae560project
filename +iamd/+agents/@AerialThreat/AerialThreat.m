classdef AerialThreat < publicsim.agents.base.Detectable    &...
        publicsim.agents.base.Movable                       &...
        publicsim.agents.base.Periodic                      &...
        publicsim.agents.physical.Impactable                &...
        publicsim.agents.physical.Destroyable
    
    properties
        location
    end
    
    properties (SetAccess=protected)
        id
        heatSig
        origin
        destination
    end
    
    properties (Constant)
        AERIAL_BROADCAST_TOPIC_KEY      = 'AERIAL_DETECT';
        RADAR_KNOCKOUT_TOPIC_KEY        = 'RADAR_KNOCKOUT';       
    end
    
end