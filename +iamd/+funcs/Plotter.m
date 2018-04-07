classdef Plotter < handle
    
    properties
        marker
        plot_interval; %[s]
        plot_handle
        t=linspace(0,2*pi);
    end
    
    properties (SetAccess=private)
        last_update_time
    end
    
    
    methods
        function updatePlot(obj,pos,plot_info)
            
            switch plot_info.type
                
                case {'radar'}
                    
                    x = pos(1); y = pos(2); z = pos(3);
                    
                    switch plot_info.status
                        
                        case 'normal'
                            if isempty(obj.plot_handle)
                                obj.plot_handle = plot3(x,y,z,'Marker','d','MarkerSize',8,'MarkerFaceColor','g','MarkerEdgeColor','b');
                                obj.plot_handle = plot3(plot_info.range*cos(obj.t)+x,plot_info.range*sin(obj.t)+y,obj.t*0,'g--');
                                view(2)
                                drawnow
                            else
                                set(obj.plot_handle,'XData',x,'YData',y,'ZData',z);
                                plot3(plot_info.range*cos(obj.t)+x,plot_info.range*sin(obj.t)+y,obj.t*0,'g--');
                                text(x+0.5,y+0.5,z,['Radar' num2str(plot_info.radar_id)],'Color','black')
                            end
                            
                        case 'cued'
                            
                            % do something
                            
                        case 'hacked'
                            
                            % do something
                            
                        case 'offline'
                            
                            % do something
                    end
                    
                    if isfield(obj.marker,'id_text')
                        text(obj.marker.id_text,x,y,'Color',[1 1 1]);
                    end
                    
                case {'missile'}
                    
                    x = pos(1); y = pos(2); z = pos(3);
                    
                    switch plot_info.status
                        
                        case 'cruising'
                            if isempty(obj.plot_handle)
                                obj.plot_handle = plot3(x,y,z,'Marker','^','MarkerSize',8,'MarkerFaceColor','r','MarkerEdgeColor','k');                                
                                view(2)
                                drawnow
                            else
                                set(obj.plot_handle,'XData',x,'YData',y,'ZData',z);                               
                                %text(x+0.5,y+0.5,z,['Missile' num2str(plot_info.missile_id)],'Color','black')
                            end
                    end
            end
        end
    end
    
    methods (Static)
        function setup(bounds)
            
            fig = figure('Name','IAMD Simulation');
            box on;
            hold on;
            grid on;
            set(gca,'Color','w')
            xlim(bounds.xLim)
            ylim(bounds.yLim)
            fig.Position(3) = 900;
            fig.Position(4) = 1000;
            movegui(fig,'center')
        end
    end
           
end                          