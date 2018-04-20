classdef Missile < publicsim.agents.hierarchical.Child  &...        
        publicsim.agents.base.Periodic                  &...
        publicsim.agents.base.Networked                 &...
        publicsim.agents.base.Movable                 
%         publicsim.agents.physical.Destroyable
    % TODO: randomized origin 
    
    properties
        initial_speed
        cruise_speed
        location
        status
    end
    
    properties (SetAccess=protected)
        isDestroyed
        scheduleTime
        missile_id
        heatSig
        origin
        destination
        direction
        
        missile_broad_topic
        missile_destroy_topic

        last_update_time
        run_interval
        
        plotter
    end
    
    properties (SetAccess=private)
        type
    end
    
    properties (Constant)
        MISSILE_BROADCAST_TOPIC_KEY     = 'MISSILE_BROADCAST';
        MISSILE_DESTROY_TOPIC_KEY       = 'MISSILE_DESTROY';
        % possible to add command knockout at some point
    end
 
    
    methods
        
        function obj = Missile()
            
            obj = obj@publicsim.agents.base.Periodic ();
            obj = obj@publicsim.agents.base.Movable();
            obj = obj@publicsim.agents.base.Networked();            
       
            
            obj.type = 'missile';
            obj.status = 'cruising';
            obj.cruise_speed = 20;            
            
            obj.setPlotter();
            obj.run_interval = 1;
            
        end
                
        function init(obj)
                        
            obj.setMovementManager(obj)
            obj.setLocation(obj.origin)
            
            obj.isDestroyed = 0;
            obj.location = obj.origin;
            obj.setDirection(obj.destination)            
            
            obj.missile_broad_topic = obj.getDataTopic(obj.MISSILE_BROADCAST_TOPIC_KEY,'','');
            obj.missile_destroy_topic = obj.getDataTopic(obj.MISSILE_DESTROY_TOPIC_KEY,'','');

            obj.setLogLevel(publicsim.sim.Logger.log_INFO);

            obj.scheduleAtTime(obj.scheduleTime)
            
            obj.last_update_time = obj.scheduleTime - 1;


        end
        
        function runAtTime(obj,time)
            
            if time == obj.scheduleTime  
                obj.disp_INFO(['Missile Launched at ' num2str(time) ' s!' '\n'])
            end
            
            if (time - obj.last_update_time >= obj.run_interval) 
                
                time_since_update = time - obj.last_update_time;
                obj.subscribeToTopic(obj.missile_destroy_topic);               
                % check if missile has been shot down by battery
                obj.isIntercepted();
                
                % if missile has reached other sid eof map, remove it 
                if obj.location(1) >= obj.destination(1)
                    obj.isDestroyed = 1;
                end
                
                if obj.isDestroyed == 0
                    obj.detectable();

                    plot_info.type = obj.type;
                    plot_info.missile_id = obj.missile_id;
                    plot_info.status = obj.status;
                    obj.plotter.updatePlot(obj.location,plot_info);
                
                    updateLocation(obj,time_since_update)
                    
                    obj.scheduleAtTime(time+1)
                end
                                                          
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
        
        function detectable(obj)
            % function that broadcasts current position of missile for any
            % radar or satellite to detect
            msg = struct;
            msg.missile_id = obj.missile_id;
            msg.missile_location = obj.location;
            msg.missile_cruise_speed = obj.cruise_speed;
            msg.missile_vector = obj.direction;

            obj.publishToTopic(obj.missile_broad_topic,msg);
            
        end
        
        function isIntercepted(obj)
            [topics,msg] = obj.getNewMessages();
  
            for ii = 1:length(topics)
                
                if isequal(topics{ii}.type,obj.MISSILE_DESTROY_TOPIC_KEY)
                    if ~isempty(msg{ii}.missile_destroy_id)
                        if obj.missile_id == msg{ii}.missile_destroy_id
                            obj.isDestroyed = 1;
                            obj.status = 'intercepted';
%                             obj.location = [-1 -1 0];
%                             obj.cruise_speed = 0;
%                             obj.direction = 0;
                        end
                    end
                end
            end            
        end
        
        function setScheduleTime(obj,spawn_time)
            obj.scheduleTime = spawn_time;
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
        
        function setPlotter(obj)
            obj.plotter = iamd.funcs.Plotter();
        end
        
    end    
            
    %%%% TEST METHODS %%%%
    
    methods (Static, Access = {?publicsim.tests.UniversalTester})
        function tests = test()
            
            tests = {};
            
        end
    end
end