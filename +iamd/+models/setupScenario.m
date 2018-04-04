function setupScenario(radarAgents,satelliteAgents,missileAgents)%,interceptorAgents,commandAgents,satelliteAgents,...
    %missileAgents,aerialAgents,cyberAgents)

radar_locations         = xlsread('+iamd/+models/inputs.xlsx','Sensors','B2:D5','basic');
radar_ranges            = xlsread('+iamd/+models/inputs.xlsx','Sensors','E2:D5','basic');
sat_locations           = xlsread('+iamd/+models/inputs.xlsx','Sensors','I2:K5','basic');
sat_ranges              = xlsread('+iamd/+models/inputs.xlsx','Sensors','L2:L2','basic');
missile_start_loc       = xlsread('+iamd/+models/inputs.xlsx','Threats','B3:D4','basic');
missile_end_loc         = xlsread('+iamd/+models/inputs.xlsx','Threats','E3:G4','basic');
missile_time_launch     = xlsread('+iamd/+models/inputs.xlsx','Threats','H3:H4','basic');
% command_locations
% 
% missile_start_location
% missle_destination
% aerial_start_location
% aerial_destination

for ii=1:length(radarAgents)
    radarAgents{ii}.setRadarId(ii);
    radarAgents{ii}.setRadarLocation(radar_locations(ii,:));
    radarAgents{ii}.setRadarRange(radar_ranges(ii));
end

for ii=1:length(satelliteAgents)
    satelliteAgents{ii}.setSatelliteId(ii);
    satelliteAgents{ii}.setSatelliteLocation(sat_locations(ii,:));
    satelliteAgents{ii}.setSatelliteRange(sat_ranges(ii));
end

for ii=1:length(missileAgents)
    missileAgents{ii}.setMissileId(ii);
    missileAgents{ii}.setScheduleTime(missile_time_launch(ii));
    missileAgents{ii}.setOrigin(missile_start_loc(ii,:));
    missileAgents{ii}.setDestination(missile_end_loc(ii,:));
end

    



    