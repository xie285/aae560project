function parsedData = parseLogs(logPath,batteryAgents,duration)
    logger = publicsim.sim.Logger(logPath);
    logger.restore();
    parsedData = struct();
    
    batteryData         = publicsim.sim.Loggable.readParamsByClass(logger,'IAMD.agents.Battery',{'getStatus'})
    
%     battery_data = parseBatteryData(batteryData,batteryAgents,duration);
%     
%     parsedData.battery_data = battery_data;
end
% 
% function battery_data = parseBatteryData(unparsed_battery_data,batteryAgents,duration)
%     status_data = [unparsed_battery_data.getStatus];
%     missile_id_intercept_data = [status_data.intercepted_missiles];
%     time_of_intercept_data = [status_data.time_of_intercept];
%     
%     allIds       = [missile_id_intercept_data.intercepted_missiles];
%     allTimes     = [time_of_intercept_data.time_of_intercept];
%     
%     battery_count   = 1;
%     battery_data    = cell(size(batteryAgents));
%     
%     for ref = 1:(duration+1):length(allTimes)
%         data_temp = struct();
%         data_temp.id = allIds(ref);
%         if data_temp.id~=batteryAgents{battery_count}.id
%             keyboard
%         end
%         data_temp.modes  = allModes(ref:ref+duration);
%         data_temp.times = allTimes(ref:ref+duration);
%         
%         battery_data{battery_count} = data_temp;
%         battery_count = battery_count+1;
%     end
% end