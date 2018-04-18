function setupScenario(radarAgents,satelliteAgents,commandAgents,missileAgents,batteryAgents)%,interceptorAgents,commandAgents,satelliteAgents,...
    %missileAgents,aerialAgents,cyberAgents)

radar_locations         = xlsread('+iamd/+models/inputs2.xlsx','Friendly','B2:D4','basic');
radar_ranges            = xlsread('+iamd/+models/inputs2.xlsx','Friendly','E2:E4','basic');
radar_se                = xlsread('+iamd/+models/inputs2.xlsx','Friendly','F2:F4','basic');

battery_locations       = xlsread('+iamd/+models/inputs2.xlsx','Friendly','V2:X5','basic');
battery_ranges          = xlsread('+iamd/+models/inputs2.xlsx','Friendly','Y2:Y5','basic');
battery_se              = xlsread('+iamd/+models/inputs2.xlsx','Friendly','Z2:Z5','basic');

sat_locations           = xlsread('+iamd/+models/inputs2.xlsx','Friendly','I2:K5','basic');
sat_ranges              = xlsread('+iamd/+models/inputs2.xlsx','Friendly','L2:L2','basic');
sat_se                  = xlsread('+iamd/+models/inputs2.xlsx','Friendly','M2','basic');

command_location        = xlsread('+iamd/+models/inputs2.xlsx','Friendly','P2:R2','basic');
command_se              = xlsread('+iamd/+models/inputs2.xlsx','Friendly','S2','basic');

sim_end_time            = xlsread('+iamd/+models/inputs2.xlsx','Simulation','B2','basic');

% missile spawn matrix
% for trial of m missiles
% randomly spawn missiles at y-axis
m = length(missileAgents);
x_i = zeros(m,1);
% y_i = randi(1000,m,1);
y_i = [539 336 325 230 5 688 753 339 470 798]';
z_i = zeros(m,1);
% origin matrix
missile_start_locations = [x_i y_i z_i];
missile_spawn_times = [0 10 20 30 40 50 60 70 80 90 100]';
% missiles travel towards east axis
x_f = repmat(1000,m,1);
% y_f = randi(1000,m,1);
y_f = [648 23 284 955 884 326 911 480 203 272]';
z_f = zeros(m,1);
missile_end_locations = [x_f y_f z_f];


bounds = findPlottingBounds();
iamd.funcs.Plotter.setup(bounds);
    
    function bounds = findPlottingBounds()
        x_min = 0;
        x_max = 1000;
        y_min = 0;
        y_max = 1000;
        bounds.xLim = [x_min x_max];
        bounds.yLim = [y_min y_max];
    end

for ii=1:length(radarAgents)
    radarAgents{ii}.setRadarId(ii);
    radarAgents{ii}.setRadarLocation(radar_locations(ii,:));
    radarAgents{ii}.setRadarRange(radar_ranges(ii));
    radarAgents{ii}.setEndTime(sim_end_time);
    radarAgents{ii}.setSE(radar_se(ii,:));
end

for ii=1:length(batteryAgents)
    batteryAgents{ii}.setBatteryId(ii);
    batteryAgents{ii}.setBatteryLocation(battery_locations(ii,:));
    batteryAgents{ii}.setBatteryRange(battery_ranges(ii));
    batteryAgents{ii}.setEndTime(sim_end_time);
    batteryAgents{ii}.setSE(battery_se(ii,:));
end

for ii=1:length(satelliteAgents)
    satelliteAgents{ii}.setSatelliteId(ii);
    satelliteAgents{ii}.setSatelliteLocation(sat_locations(ii,:));
    satelliteAgents{ii}.setSatelliteRange(sat_ranges(ii));
    satelliteAgents{ii}.setSE(sat_se(ii,:));
    satelliteAgents{ii}.setEndTime(sim_end_time);
end

for ii = 1:length(commandAgents)
    commandAgents{ii}.setCommandId(ii);
    commandAgents{ii}.setCommandLocation(command_location(ii,:));
    commandAgents{ii}.setSE(command_se(ii,:));
    commandAgents{ii}.setEndTime(sim_end_time);
end

for ii=1:length(missileAgents)
    missileAgents{ii}.setMissileId(ii);
    missileAgents{ii}.setScheduleTime(missile_spawn_times(ii));
    missileAgents{ii}.setOrigin(missile_start_locations(ii,:));
    missileAgents{ii}.setDestination(missile_end_locations(ii,:));
end
   
end