%
%--------------------------------------------------------------------------
% FUNCTION NAME:
%   plot_DVC_flow_profiles
%
% DESCRIPTION:
%   Takes displacement fields from .mat structure
%   from te DVC analysis in DaVis and makes plots from flow profiles in z
%   direction.
%
% INPUT:
%   - CELL - (structure) Containing all displacement fields from all time
%     steps, and all coordinates
%
% OUTPUT: 
%   - .png plots if needed
%
% ASSUMPTIONS AND LIMITATIONS:
%   None
% 
% For more information, see <a href="matlab: 
% web('https://www.geo.unibe.ch')">Institute of Geological Sciences UNIBE</a>.
%
%--------------------------------------------------------------------------

% Author: Timothy Schmid, MSc., geology
% Institute of Geological Sciences, University of Bern
% Baltzerstrasse 1, Office 207
% 3012 Bern, CH
% email address: timothy.schmid@geo.unibe.ch
% July 2021; Last revision: 07/07/2021 
% * initial implementation

clear;
close all;
clc

% DEFINE INPUT
% ======================================================================= %

    INPUT.displacement   = 'y displacement';
    INPUT.disp_type      = 'cumulative';
    
    INPUT.color_map_name = 'roma';
    
% SET PATHS
% ======================================================================= %

    path_main =  pwd;
    mkdir 'flow_profiles'
    path_profiles = [pwd, '/flow_profiles'];
    
    path_data = [pwd '/' INPUT.disp_type];
   
    path_colormap = [pwd '/_cmaps'];
    addpath(path_colormap)
    
% LOAD DISPLACEMENT STRUCTURE
% ======================================================================= %

    loadvar = [path_data '/displacement_structure.mat'];
    load(loadvar)
    
% RECREATE PROPERTIES
% ======================================================================= %

    l = size(CELL.disp.X,2);
    
    xcoords = double(CELL.coords.xcoords);
    ycoords = double(CELL.coords.ycoords);
    zcoords = double(CELL.coords.zcoords);
    
    xdim = double(CELL.coords.xdim);
    ydim = double(CELL.coords.ydim);
    zdim = double(CELL.coords.zdim);
    
    X = double(CELL.coords.X);
    Y = double(CELL.coords.Y);
    Z = double(CELL.coords.Z);
    
    max_array = zeros(1,l);
    min_array = zeros(1,l);
    avg_array = zeros(1,l);
    
    switch INPUT.displacement
        case 'x displacement'
            plot_var = CELL.disp.X;
        case 'y displacement'
            plot_var = CELL.disp.Y;
        case 'z displacement'
            plot_var = CELL.disp.Z;
        case '2D tot displacement'
            plot_var = CELL.disp.TOT2D;
        case '3D tot displacement'
            plot_var = CELL.disp.TOT3D;
        otherwise
    end
    
% COLORMAP
% ======================================================================= %
    cd(path_main)
    c_map = customcolormap(linspace(0,1,11), {'#a60026','#d83023',...
           '#f66e44','#faac5d','#ffdf93','#ffffbd','#def4f9','#abd9e9',...
           '#73add2','#4873b5','#313691'});
       
% COLORMAP FOR TIME INCREMENTS
% ======================================================================= %
r = linspace(0.9,0,l)';
g = linspace(0.9,0,l)';
b = linspace(0.9,0,l)';

bw_map = [r g b];

% DISTINCT PROFILE OVER TIME
% ======================================================================= %
    
%     pos_x = 100;
%     pos_z = 62;
    
    pos_y_array = [-25 0 25];
    pos_z_array = [31 62 93 120];
    
    for iposy = 1:length(pos_y_array)
        for iposz = 1:length(pos_z_array)
            
            pos_y = pos_y_array(iposy);
            pos_z = pos_z_array(iposz);
            
    [val,idx] = min(abs(ycoords-pos_y));
    
    for istep = 1:size(max_array,2)
        max_array(1,istep) = max(plot_var{istep}(idx,:,pos_z));
        min_array(1,istep) = min(plot_var{istep}(idx,:,pos_z));
        avg_array(1,istep) = mean(plot_var{istep}(idx,:,pos_z));
    end
     
    bounds = ceil(max([abs(min(min_array)), abs(max(max_array))]));

    hor_data = xcoords;
    vert_data = zeros(size(hor_data));
    
    figure(1)
    clf
    set(gcf,'Units','normalized','Position',[.1 .3 .7 .3])
    
    plot(hor_data,vert_data,'color',[0.5 0.5 0.5],'LineWidth',1)
    hold on
    scatter(hor_data(1:2:end),vert_data(1:2:end),20,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1])
        
    for iRead = 1:l
        
        vert_data = plot_var{iRead}(:,idx,pos_z)';
        plot(hor_data,vert_data,'color',[0.5 0.5 0.5],'LineWidth',1)
        hold on
        
    end
    
    for iRead = 1:l
        
        vert_data = plot_var{iRead}(:,idx,pos_z)';
        scatter(hor_data(1:2:end),vert_data(1:2:end),20,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',bw_map(iRead,:))
        hold on
        
    end
    
    
switch INPUT.disp_type
    case 'cumulative'
        ax = gca;
        ax.DataAspectRatio = [10 6 1];
%         axis([-bounds-1 bounds+1 -3 83])
        axis([-160 160 -20 20])
        caxis([-12 12])
        
    case 'incremental'
        ax = gca;
        ax.DataAspectRatio = [10 6 1];
%         axis([-bounds bounds -3 80])
        axis([-160 160 -10 10])
        caxis([-2 2])
        
    otherwise
end
    
    cb = colorbar;
    ylabel(cb, [INPUT.disp_type ' ' INPUT.displacement])
%     colormap(c_map)
    
    slice_pos   = pos_z;
    profile_pos = round(ycoords(idx));
    
    xlabel('width (mm)')
    ylabel('flow (mm)')
    title(['slice: ', num2str(slice_pos), ', profile: ', num2str(profile_pos)])
    
    hAx=gca;
    hAx.LineWidth=3;
    hAx.FontSize = 18;
    box on
    set(gca, 'Layer', 'Top')
    drawnow
      
    cd(path_profiles)
    print('-dpng','-r600','-noui',[INPUT.disp_type, '_slice_',num2str(slice_pos),'_horizontal_profile_',num2str(profile_pos) '_bw.png'])
    print('-depsc',[INPUT.disp_type, '_slice_',num2str(slice_pos),'_horizontal_profile_',num2str(profile_pos) '_bw.eps'])
    
    drawnow
    
        end
    end
