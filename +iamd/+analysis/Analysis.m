function [avgTTD, avgTTA, numIntercepts, numCues] =  Analysis(num_missiles)
% avgTTD: average time for radar to detect since launch of missile
% avgTTI: average time for battery to intercept missile 
% avgTTA: average time for command to issue out target assignments
    
    % import radar data
    radar1_data     = xlsread('+iamd/test_data.xlsx','Radar Data','A:B','basic');
    radar2_data     = xlsread('+iamd/test_data.xlsx','Radar Data','C:D','basic');
    radar3_data     = xlsread('+iamd/test_data.xlsx','Radar Data','E:F','basic');
    % import command data
    command_data    = xlsread('+iamd/test_data.xlsx','Command Data','A:B','basic');
    % import battery data
    battery1_data   = xlsread('+iamd/test_data.xlsx','Battery Data','A:B','basic');
    battery2_data   = xlsread('+iamd/test_data.xlsx','Battery Data','C:D','basic');
    battery3_data   = xlsread('+iamd/test_data.xlsx','Battery Data','E:F','basic');
    battery4_data   = xlsread('+iamd/test_data.xlsx','Battery Data','G:H','basic');
    % import satellite data
    satellite_data  = xlsread('+iamd/test_data.xlsx','Satellite Data','A:B','basic');    
    
    radar_data = [radar1_data; radar2_data; radar3_data];
    battery_data = [battery1_data; battery2_data; battery3_data; battery4_data];
    
    numIntercepts = batteryPerformance(battery_data);
    avgTTD = radarPerformance(radar_data,num_missiles);
    avgTTA = commandPerformance(command_data,num_missiles);
    numCues = satellitePerformance(satellite_data);
    batteryOP = 100 * numIntercepts/num_missiles;
    satelliteOP = 100 * numCues/num_missiles;
              
end

function average_TTD = radarPerformance(radar_data,num_missiles)      
        sorted_radar_data = sortrows(radar_data);
        
    if ~isempty(sorted_radar_data)    
        [~,ia] = unique(sorted_radar_data(:,1),'stable');
        sorted_radar_data = sorted_radar_data(ia,:);
        num_detects = size(sorted_radar_data,1);
        missile_launch_times = zeros(length(sorted_radar_data),1)';
        for i = 1:length(sorted_radar_data)
            missile_launch_times(i) = 10*sorted_radar_data(i,1)-10;
        end
        time_to_detect = sorted_radar_data(:,2) - missile_launch_times';
    else
        num_detects = 0;
        time_to_detect = [];
    end
    
    % add penalty time of 70.71 calculated as max time for missile to
    % travel from one corner of map to the other
    if num_detects < num_missiles
        for n = 1:num_missiles-num_detects
            time_to_detect = [time_to_detect;70.71];
        end
    end
%     time_to_detect'
    average_TTD = mean(time_to_detect); % average Time To Detect
%     best_average = 16.1; % calculated from run with ideal SEs
%     radar_operability = 100 * (average_TTD - maxTraverseTime)/(best_average - maxTraverseTime);
    %100 * mean((time_to_detect - traverseTime') ./ (best_times_to_detect - traverseTime'));
  
end

function number_of_intercepts = batteryPerformance(battery_data)
    battery_data = sortrows(battery_data);

    if ~isempty(battery_data)
        missile_launch_times = zeros(length(battery_data),1)';
        for i = 1:length(battery_data)
            missile_launch_times(i) = 10*battery_data(i,1)-10;
        end
    time_to_intercept = battery_data(:,2) - missile_launch_times';
    end  
    number_of_intercepts = size(battery_data,1);

end

function average_TTA = commandPerformance(command_data,num_missiles)
    command_data = sortrows(command_data);
    time_to_assignment = zeros(size(command_data,1),1);
    if ~isempty(command_data)
        missile_launch_times = zeros(length(command_data),1)';
        for i = 1:length(command_data)
            missile_launch_times(i) = 10*command_data(i,1)-10;
        end
        time_to_assignment = command_data(:,2) - missile_launch_times';
    end
    number_of_assignments = size(command_data,1);
    % add penalty time of 70.71 calculated as max time for missile to
    % travel from one corner of map to the other
    if number_of_assignments < num_missiles
        for n = 1:num_missiles-number_of_assignments
            time_to_assignment = [time_to_assignment; 70.71];
        end
    end   

    average_TTA = mean(time_to_assignment);
%     best_time_average = 17.1;
%     command_operability = 100 * (average_TTA - maxTraverseTime) / (best_time_average - maxTraverseTime);%100 * mean((time_to_assignment - traverseTime') ./ (best_times_to_assignment - traverseTime'));
end

function numberOfSuccessfulCuesSent = satellitePerformance(satellite_data)
%     figure
    if ~isempty(satellite_data)
        satellite_data = unique(satellite_data(:,2));
        numberOfSuccessfulCuesSent = length(satellite_data)-1;
    else
        numberOfSuccessfulCuesSent = 0;
    end
%     if ~isempty(satellite_data)
%         numberOfSuccessfulCuesSent = satellite_data(end,2);
%     else
%         numberOfSuccessfulCuesSent = 0;
%     end
    
%     [unq,ind] = unique(satellite_data(:,2));
%     unqt = zeros(length(ind),1);
%     for i = 1:length(satellite_data(:,1))
%         for j = 1:length(ind)
%             if i == ind(j)
%                 unqt(j) = satellite_data(i,1);
%             end
%         end
%     end
%    
%     scatter(unqt,unq)
end

% function [maxTraverseTime,avgTraverseTime,traverseTime] = calculateTimeOfTraverse(missile_start,missile_end,missile_speed)
%     y_i = missile_start;
%     y_f = missile_end;
%     m = (y_f-y_i)/1000;
%     radar_locations = [669 121;483 371; 477 753];
%     range = 250;
%     cruise_speed = missile_speed;
%     for i = 1:length(y_i)
%         if i == 2 || i == 3 || i == 6 || i == 9 || i == 10
%             p = radar_locations(1,1);
%             q = radar_locations(1,2);
%         elseif i == 5 || i == 8
%             p = radar_locations(2,1);
%             q = radar_locations(2,2);
%         else
%             p = radar_locations(3,1);
%             q = radar_locations(3,2);
%         end
%         A = m(i)^2 + 1;
%         B = 2*(m(i)*y_i(i) - m(i)*q - p);
%         C = q^2 - range^2 + p^2 - 2*y_i(i)*q + y_i(i)^2;
%         x(i) = real((-B + sqrt(B^2 - 4*A*C))/(2*A));
%         y(i) = m(i)*x(i) + y_i(i);
%         max_dist(i) = sqrt(x(i)^2 + (y(i)-y_i(i))^2);       
%     end
%     traverseTime = max_dist/cruise_speed;
%     
%     avgTraverseTime = mean(max_dist/cruise_speed);
%     maxTraverseTime = max(max_dist/cruise_speed);
% end

% function maxTraverseTimeBatt = calculateMaxTimeOfTraverseBatt(missile_start,missile_end,missile_speed)
%     y_i = missile_start;
%     y_f = missile_end;
%     m = (y_f-y_i)/1000;
%     radar_locations = [710 94;558 345; 495 629;523 876];
%     range = 150;
%     cruise_speed = missile_speed;
%     for i = 1:length(y_i)
%         if i == 3
%             p = battery_locations(1,1);
%             q = battery_locations(1,2);
%         elseif i == 4 || i == 7 || i ==8
%             p = battery_locations(2,1);
%             q = battery_locations(2,2);
%         elseif i == 1 || i == 2 || i == 5 || i == 10
%             p = battery_locations(3,1);
%             q = battery_locations(3,2);
%         else
%             p = battery_locations(4,1);
%             q = battery_locations(4,2);
%         end
%         A = m(i)^2 + 1;
%         B = 2*(m(i)*y_i(i) - m(i)*q - p);
%         C = q^2 - range^2 + p^2 - 2*y_i(i)*q + y_i(i)^2;
%         x(i) = real((-B + sqrt(B^2 - 4*A*C))/(2*A));
%         y(i) = m(i)*x(i) + y_i(i);
%         max_dist(i) = sqrt(x(i)^2 + (y(i)-y_i(i))^2);       
%     end
% 
%     maxTraverseTimeBatt = max(max_dist/cruise_speed);
% end

