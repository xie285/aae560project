classdef Plotter < handle
    
    properties
        marker
        plot_interval; %[s]
        plot_handle
        t=linesapce(0,2*pi);
    end
    
    properties (SetAccess=private)
        last_update_time
    end
    
    
    methods
        function updatePlot(obj,pos,plot_info)
            
            switch plot_info.type
                
                case {'radar'}
                    
                    x = pos(1);
                    y =pos(2);
                    z = pos(3);
                    
                    switch plot_info.status
                        
                        case 'normal'
                            if isempty(obj.plot_handle)
                                obj.plot_handle = plot3(x,y,z,'Marker','d','MarkerSize',8,'MarkerFaceColor','g');
                                obj.plot_handle = plot3(plot_info.range*cos(obj.t)+x,plot_info.range*sin(obj.t)+y,obj.t*0,'r--');
                                view(2)
                                drawnow
                            else
                                set(obj.plot_handle,'XData',x,'YData',y,'ZData',z);
                                plot3(plot_info.range*cos(obj.t)+x,plot_info.range*sin(obj.t)+y,obj.t*0,'r--');
                                text(x+0.5,y+0.5,z,['Radar' num2str(plot_info.radar_id)],'Color','white')
                            end
                            
                        case 'cued'
                            
                            % do something
                            
                        case 'hacked'
                            
                            % do something
                            
                        case 'offline'
                            
                            % do something
                    end
            end
        end
    end
end                          