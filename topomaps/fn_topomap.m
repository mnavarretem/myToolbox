function fn_topomap(vt_dat,st_cfg)
% Descripption to complete
% fn_topomap()   - plot a topographic map of an EEG field as a 2-D
%                circular view (looking down at the top of the head) 
%                 using cointerpolation on a fine cartesian grid.
% Usage:
%        >>  topoplot(vt_data,cfg);
% Inputs:
%   vt_data = vector of values at the corresponding locations.
%   st_cfg = structure of parameters
%   st_cfg.fileloc     -  file with vector locations
%   st_cfg.channels	-  cell vector of strings with the names of channles
%                       in the same order of vt_data 
%   st_cfg.colormap	-  any sized colormap
%   st_cfg.gridscale	-  scaling grid size {default 100}
%   st_cfg.maplimits	- 'absmax' +/- the absolute-max 
%                       'maxmin' scale to data range
%                       [clim1,clim2] user-definined lo/hi
%                       {default = 'absmax'}
%   st_cfg.interplimits	- 'electrodes' to furthest electrode
%                                     'head' to edge of head
%                                        {default 'head'}
%	st_cfg.style       - 'straight' colormap only
%                       'contour' contour lines only
%                       'both' both colormap and contour lines
%                       'fill' constant color between lines
%                       'blank' just head and electrodes
%                       {default = 'both'}
%	st_cfg.numcontour	- number of contour lines
%                                        {default = 6}
%	st_cfg.shading       - 'flat','interp'  {default = 'flat'}
%   st_cfg.headcolor	- Color of head cartoon {default black}
%   st_cfg.mask         - electrode mask
%   st_cfg.electrodes	- 'on','off','labels','numbers'
%   st_cfg.efontsize,st_cfg.electcolor,st_cfg.emarker,st_cfg.emarkersize - details
%   st_cfg.emarkerfacecolor,st_cfg.emarkeredgecolor - details
%
% Inspired in the original version topoplot from by Andy Spydell and topomaps 
% from Mike X. Cohen

%% Define input
if nargin < 2
    st_cfg  = struct;
end

if ~isfield(st_cfg,'fileloc')
    st_cfg.fileloc      = '10_10_system.mat';
end
if ~isfield(st_cfg,'channels')
    st_cfg.channels     = nan;
end
if ~isfield(st_cfg,'gridscale')
    st_cfg.gridscale    = 100;    
end
if ~isfield(st_cfg,'maplimits')
    st_cfg.maplimits	= 'absmax';    
end
if ~isfield(st_cfg,'interplimits')
    st_cfg.interplimits	= 'head';    
end
if ~isfield(st_cfg,'style')
    st_cfg.style        = 'both';    
end
if ~isfield(st_cfg,'numcontour')
    st_cfg.numcontour	= 6;    
end
if ~isfield(st_cfg,'shading')
    st_cfg.shading      = 'flat';    
end
if ~isfield(st_cfg,'headcolor')
    st_cfg.headcolor	= [0,0,0];
end
if ~isfield(st_cfg,'electrodes')
    st_cfg.electrodes	= 'on';    
end
if ~isfield(st_cfg,'efontsize')
    st_cfg.efontsize	= get(0,'DefaultAxesFontSize');   
end
if ~isfield(st_cfg,'electcolor')
    st_cfg.electcolor	= [0,0,0];    
end
if ~isfield(st_cfg,'emarker')
    st_cfg.emarker	= '.';    
end
if ~isfield(st_cfg,'emarkersize')
    st_cfg.emarkersize	= 6;    
end
if ~isfield(st_cfg,'emarkerfacecolor')
    st_cfg.emarkerfacecolor	= 'none';    
end
if ~isfield(st_cfg,'emarkeredgecolor')
    st_cfg.emarkeredgecolor	= st_cfg.electcolor;    
end
if ~isfield(st_cfg,'head')
    st_cfg.head	= true;    
end
if ~isfield(st_cfg,'linewidth')
    st_cfg.linewidth	= 0.5;    
end
if ~isfield(st_cfg,'mask')
    st_cfg.mask     = [];    
end

%% check input

st_channel	= load(st_cfg.fileloc);
st_channel  = st_channel.chanlocs;
vt_chLabels	= cell(size(st_channel));

for cc = 1:numel(st_channel)
    vt_chLabels{cc}	= st_channel(cc).labels;
end
    
if ~iscell(st_cfg.channels) && ~isempty(st_cfg.channels)
    st_cfg.channels	= cell(size(st_channel));
    for cc = 1:numel(st_channel)
        st_cfg.channels{cc}	= st_channel(cc).labels;
    end
end

% look for channel position
st_chLoc        = struct;
st_chLoc.theta	= nan(size(st_cfg.channels));
st_chLoc.radius	= nan(size(st_cfg.channels));

for cc = 1:numel(st_cfg.channels)
    vt_id	= ismember(vt_chLabels,st_cfg.channels{cc});
    if ~any(vt_id)
        continue
    end
    st_chLoc.theta(cc)	= st_channel(vt_id).theta;    
    st_chLoc.radius(cc)	= st_channel(vt_id).radius;
end


[vt_x,vt_y]	= pol2cart(pi/180*[st_chLoc.theta],[st_chLoc.radius]);
nm_rmax    	= 0.58;

ob_hAxes = gca;

if st_cfg.head
    cla
end

hold on

if ~strcmp(st_cfg.style,'blank')
  % find limits for interpolation
  if strcmp(st_cfg.interplimits,'head')
        nm_xmin = min(-nm_rmax,min(vt_x)); 
        nm_xmax = max(nm_rmax,max(vt_x));
        nm_ymin = min(-nm_rmax,min(vt_y)); 
        nm_ymax = max(nm_rmax,max(vt_y));
  else
        nm_xmin = max(-nm_rmax,min(vt_x)); 
        nm_xmax = min(nm_rmax,max(vt_x));
        nm_ymin = max(-nm_rmax,min(vt_y)); 
        nm_ymax = min(nm_rmax,max(vt_y));
  end
  
  vt_xi = linspace(nm_xmin,nm_xmax,st_cfg.gridscale);   % x-axis description (row vector)
  vt_yi = linspace(nm_ymin,nm_ymax,st_cfg.gridscale);   % y-axis description (row vector)
  
  % Border correction -- mgnm
%   vt_yT = repmat(nm_ymax,numel(vt_xi)-1,1);
%   vt_xT = vt_xi(1:end-1);
%   vt_vT = zeros(size(vt_yT));
%   
%   vt_yB = repmat(nm_ymin,numel(vt_xi)-1,1);
%   vt_xB = vt_xi(2:end);
%   vt_vB = zeros(size(vt_yB));
%   
%   vt_yR = vt_yi(2:end);
%   vt_xR = repmat(nm_xmax,numel(vt_xi)-1,1);
%   vt_vR = zeros(size(vt_yR));
% 
%   vt_yL = vt_yi(1:end-1);
%   vt_xL = repmat(nm_xmin,numel(vt_xi)-1,1);
%   vt_vL = zeros(size(vt_yL));
% 
%   vt_x = vertcat(vt_xT(:),vt_xB(:),vt_xR(:),vt_xL(:),vt_x(:));
%   vt_y = vertcat(vt_yT(:),vt_yB(:),vt_yR(:),vt_yL(:),vt_y(:));
%   vt_dat = vertcat(vt_vT(:),vt_vB(:),vt_vR(:),vt_vL(:),vt_dat(:));
  
  % Continue original code
  [mx_Xi,mx_Yi,mx_Zi] = griddata(vt_y,vt_x,vt_dat,vt_yi',vt_xi,'v4'); % Interpolate data
  
  if ~isempty(st_cfg.mask)
    Vm  = double(st_cfg.mask);
    [mx_Xm,mx_Ym,mx_Zm] = griddata(vt_y,vt_x,Vm,vt_yi',vt_xi,'v4'); % Interpolate data
  end
  
  % Take data within head
  mx_mask       = (sqrt(mx_Xi.^2+mx_Yi.^2) <= nm_rmax);
  vt_id         = find(mx_mask == 0);
  mx_Zi(vt_id)  = NaN;
  
  if ~isempty(st_cfg.mask)
    ms_Zm(vt_id)   	= NaN;
    mx_Zi(ms_Zm<nm_rmax)= NaN; 
  end
  
  % calculate colormap limits
  m = size(colormap,1);
  if ischar(st_cfg.maplimits)
    if strcmp(st_cfg.maplimits,'absmax')
      nm_amin = -max(max(abs(mx_Zi)));
      nm_amax = max(max(abs(mx_Zi)));
    elseif strcmp(st_cfg.maplimits,'maxmin')
      nm_amin = min(min(mx_Zi));
      nm_amax = max(max(mx_Zi));
    end
  else
    nm_amin = st_cfg.maplimits(1);
    nm_amax = st_cfg.maplimits(2);
  end
  nm_delta = vt_xi(2)-vt_xi(1); % length of grid entry
  
  % Draw topoplot on head
  if strcmp(st_cfg.style,'contour')
      contour(mx_Xi,mx_Yi,mx_Zi,st_cfg.numcontour,'k');
  elseif strcmp(st_cfg.style,'both')
        surface(mx_Xi-nm_delta/2,mx_Yi-nm_delta/2,zeros(size(mx_Zi)),mx_Zi,...
            'EdgeColor','none',...
            'FaceColor',st_cfg.shading);
            contour(mx_Xi,mx_Yi,mx_Zi,st_cfg.numcontour,'k');
  elseif strcmp(st_cfg.style,'straight')
        surface(mx_Xi-nm_delta/2,mx_Yi-nm_delta/2,zeros(size(mx_Zi)),mx_Zi,...
            'EdgeColor','none',...
            'FaceColor',st_cfg.shading);
  elseif strcmp(st_cfg.style,'fill')
        contourf(mx_Xi,mx_Yi,mx_Zi,st_cfg.numcontour,'k');
  else
        error('Invalid st_cfg.style')
  end
        caxis([nm_amin nm_amax]) % set coloraxis
end

set(ob_hAxes,...
    'Xlim',[-nm_rmax*1.3 nm_rmax*1.3],...
    'Ylim',[-nm_rmax*1.3 nm_rmax*1.3])

% Plot Electrodes
if strcmp(st_cfg.electrodes,'on') 
  ob_hCh = plot(vt_y,vt_x,st_cfg.emarker,...
        'MarkerFaceColor',st_cfg.emarkerfacecolor,...
        'MarkerEdgeColor',st_cfg.emarkeredgecolor',...
        'Color',st_cfg.electcolor,...
        'markersize',st_cfg.emarkersize);
elseif strcmp(st_cfg.electrodes,'labels')
    for ii = 1:size(vt_chLabels,1)
        text(vt_y(ii),vt_x(ii),vt_chLabels(ii,:),'HorizontalAlignment','center',...
            'VerticalAlignment','middle','Color',st_cfg.electcolor,...
            'FontSize',st_cfg.efontsize)
    end
elseif strcmp(st_cfg.electrodes,'numbers')
    for ii = 1:size(labels,1)
        text(vt_y(ii),vt_x(ii),int2str(ii),'HorizontalAlignment','center',...
            'VerticalAlignment','middle','Color',st_cfg.electcolor,...
            'FontSize',st_cfg.efontsize)
    end
end

if st_cfg.head
    % %%% Draw Head %%%%
    vt_line	= 0:2*pi/100:2*pi;
    nm_tip  = nm_rmax*1.15; 
    nm_base = nm_rmax-.004;
    vt_EarX = [0.4970 0.5100 0.5180 0.5299 0.5419  0.5400 ...
                0.5470  0.5320  0.510   0.4890] - 0.5 + nm_rmax;
    vt_EarY = [0.0555 0.0775 0.0783 0.0746 0.0555 -0.0055 ...
                -0.0932 -0.1313 -0.1384 -0.1199];
                        
    % Plot Head, Ears, Nose
    plot(cos(vt_line).*nm_rmax,sin(vt_line).*nm_rmax,...
        'color',st_cfg.headcolor,...
        'LineStyle','-',...
        'LineWidth',st_cfg.linewidth);

    plot([.18*nm_rmax;0;-.18*nm_rmax],[nm_base;nm_tip;nm_base],...
        'Color',st_cfg.headcolor,...
        'LineWidth',st_cfg.linewidth);

    plot(vt_EarX,vt_EarY,...
        'color',st_cfg.headcolor,...
        'LineWidth',st_cfg.linewidth)
    plot(-vt_EarX,vt_EarY,...
        'color',st_cfg.headcolor,...
        'LineWidth',st_cfg.linewidth)   

end
hold off
axis off

