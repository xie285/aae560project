classdef Missile < publicsim.agents.hierarchical.Child  &...        
        publicsim.agents.base.Periodic                  &...
        publicsim.agents.base.Networked                 &...
        publicsim.agents.base.Movable                   &...
        publicsim.agents.physical.Destroyable          
    
    properties
        initial_speed
        cruise_speed
        location
    end
    
    properties (SetAccess=protected)
        scheduleTime
        missile_id
        heatSig
        origin
        destination
        direction
        
        missile_broad_topic
        radar_knockout_topic
        last_update_time
        run_interval
    end
    
    properties (Constant)
        MISSILE_BROADCAST_TOPIC_KEY     = 'MISSILE_BROADCAST';
        RADAR_KNOCKOUT_TOPIC_KEY        = 'RADAR_KNOCKOUT';
        % possible to add command knockout at some point
    end
 
    
    methods
        
        function obj = Missile()
            
            obj = obj@publicsim.agents.base.Periodic ();
            %obj = obj@publicsim.agents.base.Detectable();
            obj = obj@publicsim.agents.base.Movable();
            %obj = obj@publicsim.agents.physical.Impactable();
            obj = obj@publicsim.agents.physical.Destroyable();
            obj = obj@publicsim.agents.base.Networked();
            
            
            obj.initial_speed = 0;
            obj.cruise_speed = 10;
        end
                
        function init(obj)
                        
            obj.setMovementManager(obj)
            %obj.setLocation(obj.origin)
            
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');
            obj.radar_knockout_topic = obj.getDataTopic(obj.RADAR_KNOCKOUT_TOPIC_KEY,'','');
            
            obj.subscribeToTopic(obj.missile_broad_topic);
            obj.subscribeToTopic(obj.radar_knockout_topic);
            
            obj.setLogLevel(publicsim.sim.Logger.log_INFO);
            obj.scheduleAtTime(obj.scheduleTime)            
        end
        
        function runAtTime(obj,time)
            
            obj.disp_INFO(['Missile Launched at ' num2str(time) ' s!' '\n'])

            if (time - obj.last_update_time >= obj.run_interval)
                
                time_since_update = time - obj.last_update_time;
                
                % update movement based on orders
                updateLocation(obj,time_since_update)
                          
%                 % plot update
%                 plot_info.type              = obj.type;
%                 plot_info.ac_radar_range    = obj.ac_radar_range;
%                 obj.plotter.updatePlot(obj.location,plot_info);
%                 obj.scheduleAtTime(time+1);
                
            end
            
            % record last time step stamp
            obj.last_update_time = time;
        end
        
        function updateLocation(obj,time_since_update)
            obj.setDirection(obj.destination)
            dist_hit = obj.cruise_speed*time_since_update;
            obj.setLocation(obj.location + dist_hit*obj.direction)
        end
        
        function setDirection(obj,destination)
            obj.direction = (destination - obj.location) / norm(destination - obj.location);
        end
        
        function setScheduleTime(obj,time)
            obj.scheduleTime = time;
        end
        
        function setMissileId(obj,id)
            obj.missile_id = id;
        end
        
        function setOrigin(obj,position)
            obj.origin = position;
        end
        
        function setDestination(obj,position)
            obj.destination = position;
        end
        
        function setLocation(obj,location)
            obj.location = location;
        end
        
        function location = getLocation(obj)
            location =obj.location;
        end
        
        function speed = getSpeed(obj)
            speed = obj.cruise_speed;
        end
        
        function s = getPosition(obj)
            s = obj.location;
        end
        
        function a = getAcceleration(obj) %#ok
            a = [];
        end
        
        function v = getVelocity(obj)
            v = obj.cruise_speed;
        end
        
    end
    
    %%%% TEST METHODS %%%%
    
    methods (Static, Access = {?publicsim.tests.UniversalTester})
        function tests = test()
            
            tests = {};
            
        end
    end
end