system = 'Radar';

inputfilename = '+iamd/+models/inputs2.xlsx';
ntrials = 10;
switch system
    case 'Radar'
        for SE = 0:10:90
            xlswrite(inputfilename,SE,'Friendly','F2:F4')
                for i = 1:ntrials
                    iamd.models.run_simulation()
                end
        end
    case 'Satellite'
        for SE = 0:10:90
            xlswrite(inputfilename,SE,'Friendly','M2')
                for i = 1:ntrials
                    iamd.models.run_simulation()
                end
        end
    case 'Command'
        for SE = 0:10:90
            xlswrite(inputfilename,SE,'Friendly','S2')
                for i = 1:ntrials
                    iamd.models.run_simulation()
                end
        end
    case 'Interceptor'
        for SE = 0:10:90
            xlswrite(inputfilename,SE,'Friendly','Z2:Z5')
                for i = 1:ntrials
                    iamd.models.run_simulation()
                end
        end
    case 'Baseline'
        for i = 1:ntrials
            iamd.models.run_simulation()
        end        
end