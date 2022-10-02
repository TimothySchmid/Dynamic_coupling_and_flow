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

    INPUT.displacement   = 'z displacement';
    INPUT.disp_type      = 'incremental';
    
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
    
    pos_x_array = 50;%[-100 -50 0 50 100];
    pos_z_array = 120;%[31 62 93 120];
    
    for iposx = 1:length(pos_x_array)
        for iposz = 1:length(pos_z_array)
            
            pos_x = pos_x_array(iposx);
            pos_z = pos_z_array(iposz);
            
    [val,idx] = min(abs(xcoords-pos_x));
    
    for istep = 1:size(max_array,2)
        max_array(1,istep) = max(plot_var{istep}(idx,1:end-4,pos_z));
        min_array(1,istep) = min(plot_var{istep}(idx,1:end-4,pos_z));
        avg_array(1,istep) = mean(plot_var{istep}(idx,1:end-4,pos_z));
    end
     
    bounds = ceil(max([abs(min(min_array)), abs(max(max_array))]));

    hor_data = ycoords - ycoords(1);
    vert_data = zeros(size(hor_data));
    
    figure(1)
    clf
    set(gcf,'Units','normalized','Position',[.1 .1 .4 .7])
    
    plot(vert_data(1:end-4),hor_data(1:end-4),'color',[0.5 0.5 0.5],'LineWidth',2)
    hold on
    scatter(vert_data(1:end-4),hor_data(1:end-4),50,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',[1 1 1])
        
    for iRead = 1:l
        
        vert_data = plot_var{iRead}(idx,:,pos_z)';
        eliminate_num = length(vert_data(vert_data==0));
        plot(vert_data(1:end-eliminate_num),hor_data(1:end-eliminate_num),'color',[0.5 0.5 0.5],'LineWidth',2)
        hold on
        
    end
    
    for iRead = 1:l
        
        vert_data = plot_var{iRead}(idx,:,pos_z)';
        eliminate_num = length(vert_data(vert_data==0));
        scatter(vert_data(1:end-eliminate_num),hor_data(1:end-eliminate_num),50,'MarkerEdgeColor',[0 0 0],'MarkerFaceColor',bw_map(iRead,:))
        hold on
        
    end
    
    
switch INPUT.disp_type
    case 'cumulative'
        ax = gca;
%         ax.DataAspectRatio = [1 1 1];
%         axis([-bounds-1 bounds+1 -3 83])
%         axis([-15 15 -3 83])
        caxis([-12 12])
        
    case 'incremental'
        ax = gca;
%         ax.DataAspectRatio = [1 10 1];
%         axis([-bounds bounds -3 80])
%         axis([-2 2 -3 83])
        caxis([-2 2])
        
    otherwise
end
    
    cb = colorbar;
    ylabel(cb, [INPUT.disp_type ' ' INPUT.displacement])
%     caxis([-bounds bounds])
%     caxis([-12 12])
    colormap(c_map)
    
    slice_pos   = pos_z;
    profile_pos = round(xcoords(idx));
    
    xlabel('flow (mm)')
    ylabel('height (mm)')
    title(['slice: ', num2str(slice_pos), ', profile: ', num2str(profile_pos)])
    
    hAx=gca;
    hAx.LineWidth=3;
    hAx.FontSize = 18;
    box on
    set(gca, 'Layer', 'Top')
    drawnow
      
%     cd(path_profiles)
%     print('-dpng','-r600','-noui',[INPUT.disp_type, '_slice_',num2str(slice_pos),'_vertical_profile_',num2str(profile_pos) '_bw.png'])
%     print('-depsc',[INPUT.disp_type, '_slice_',num2str(slice_pos),'_vertical_profile_',num2str(profile_pos) '_bw.eps'])
    
    drawnow
    
        end
    end
