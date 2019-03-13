function vt_handles = fn_boxplotmeasures(mx_measures,mx_outliers,st_Cnf)
% fn_boxplotmeasures(mx_measures,mx_outliers,st_Cnf) plots a boxplot
% diagram according to the measures stablished in mx_measures, the outliers
% in the mx_outliers.
%
% Inputs:
% 
%       mx_measures:        m x 5 matrix indicating m distributions and 5
%                           measures [lowerfence,Q1,Q2,Q3,upperfence]
%
%       mx_outliers:        m x 2 cell matrix indicating the outlier values
%                           as [vt_lowOutliers,vt_upOutliers]. If not outliers 
%                           in all distributions, then an empty matrix can
%                           be passed in.
%
%       st_Cnf              Structure indicating plot settings:
%
%           - st_Cnf.groupTick:     Tick values for each group distribution
%
%           - st_Cnf.boxWidth:     	Relative box width (default: 0.75)
%
%           - st_Cnf.colorBox:      Matlab color vector or string
%                                   indicating the box color
%
%           - st_Cnf.colorWisker:   Matlab color vector or string
%                                   indicating the wisker color
%
%           - st_Cnf.colorMedian:   Matlab color vector or string
%                                   indicating the median color
%
%           - st_Cnf.colorMean:     Matlab color vector or string
%                                   indicating the mean color
%
%           - st_Cnf.colorOutlier:	Matlab color vector or string
%                                   indicating the outliers color
%
%           - st_Cnf.markOutlier:	Matlab key for outlier marks (default: o)
%
%           - st_Cnf.markMean:      Matlab key for mean marks (default: x),
%                                   if empty, then not marker
%
%           - st_Cnf.means:         vector with m elements inidicating the
%                                   mean of each distribution
%
%           - st_Cnf.wiskerLine:    Matlab LineStyle for wiskers (default: --),
%                                   
%           - st_Cnf.ConfidenceI:	vector with m elements inidicating the
%                                   95% confidence interval
%
%           - st_Cnf.isNotched:     Notch the box if st_Cnf.ConfidenceI is
%                                   set (default: false)
%
%           - st_Cnf.notchWidth:	Relative notch width (default: 0.6)
%
%           - st_Cnf.isFenced:      Plot wisker fences (default: true)
%
%           - st_Cnf.fenceWidth:	Relative box width (default: 0.2)
%
%           - st_Cnf.axes:          figure axes

% Miguel Navarrete
% CUBRIC
% 2017

%% Code starts here:

% Check input variables
if nargin < 2
    mx_outliers = [];
    st_Cnf      = [];
end

if nargin < 3 || isempty(st_Cnf)
    st_Cnf      = struct;
end

if ~isfield(st_Cnf,'groupTick')
    st_Cnf.groupTick	= 1:size(mx_measures,1);
end
if ~isfield(st_Cnf,'boxWidth')
    st_Cnf.boxWidth        = 0.4;
end
if ~isfield(st_Cnf,'colorBox')
    st_Cnf.colorBox     = [0.2 0.2 0.2];
end
if ~isfield(st_Cnf,'colorWisker')
    st_Cnf.colorWisker	= [0.5 0.5 0.5];
end
if ~isfield(st_Cnf,'colorMedian')
    st_Cnf.colorMedian	= [0.5 0.0 0.0];
end
if ~isfield(st_Cnf,'colorMean')
    st_Cnf.colorMean	= [0.0 0.0 0.5];
end
if ~isfield(st_Cnf,'colorOutlier')
    st_Cnf.colorOutlier	= [0.0 0.0 0.5];
end
if ~isfield(st_Cnf,'markOutlier')
    st_Cnf.markOutlier	= 'o';
end
if ~isfield(st_Cnf,'markMean')
    st_Cnf.markMean     = 'x';
end
if ~isfield(st_Cnf,'means')
    st_Cnf.means        = [];
end
if ~isfield(st_Cnf,'wiskerLine')
    st_Cnf.wiskerLine   = '--';
end
if ~isfield(st_Cnf,'ConfidenceI')
    st_Cnf.ConfidenceI	= [];
end
if ~isfield(st_Cnf,'isNotched')
    st_Cnf.isNotched 	= false;
end
if ~isfield(st_Cnf,'fenceWidth')
    st_Cnf.notchWidth	= 0.3;
end
if ~isfield(st_Cnf,'isFenced')
    st_Cnf.isFenced     = true;
end
if ~isfield(st_Cnf,'fenceWidth')
    st_Cnf.fenceWidth	= 0.2;
end
if ~isfield(st_Cnf,'axes')
    st_Cnf.axes         = gca;
end

%% Prepare values

if isempty(st_Cnf.ConfidenceI)
    st_Cnf.isNotched	= false;
    st_Cnf.notchWidth   = st_Cnf.boxWidth;
    st_Cnf.ConfidenceI  = zeros(size(mx_measures,1),1);
end

nm_isMean	= ~isempty(st_Cnf.means);

nm_boxSpace = min(diff(st_Cnf.groupTick)) / 2; 

if isempty(nm_boxSpace)
    nm_boxSpace = 0.5;
end

nm_boxLim	= nm_boxSpace * st_Cnf.boxWidth;
nm_fenceLim = nm_boxSpace * st_Cnf.fenceWidth;
nm_notchLim	= nm_boxSpace * st_Cnf.notchWidth * st_Cnf.boxWidth;

if isempty(mx_outliers)
    mx_outliers     = cell(size(mx_measures,1),2);
end

%% Plot wisker plot for each distribution

vt_handles  = cell(size(mx_measures,1),1);

for kk = 1:size(mx_measures,1)
    
    if any(isnan(mx_measures(kk,:)))
        continue
    end
    
    % plot the current box
    nm_curBin       = st_Cnf.groupTick(kk);
    nm_curLoFence   = mx_measures(kk,1);
    nm_curQ1        = mx_measures(kk,2);
    nm_curQ2        = mx_measures(kk,3);
    nm_curQ3        = mx_measures(kk,4);
    nm_curUpFence	= mx_measures(kk,5);
    
    nm_curLoNotch   = nm_curQ2 - st_Cnf.ConfidenceI(kk)/2;
    nm_curUpNotch   = nm_curQ2 + st_Cnf.ConfidenceI(kk)/2;
    
    st_hBox.Box     = line(st_Cnf.axes,...
                    'XData',[nm_curBin - nm_boxLim,...
                            nm_curBin + nm_boxLim,...
                            nm_curBin + nm_boxLim,...
                            nm_curBin + nm_notchLim,...
                            nm_curBin + nm_boxLim,...
                            nm_curBin + nm_boxLim,...
                            nm_curBin - nm_boxLim,...
                            nm_curBin - nm_boxLim,...
                            nm_curBin - nm_notchLim,...
                            nm_curBin - nm_boxLim,...
                            nm_curBin - nm_boxLim],...                            
                    'YData',[nm_curQ1,...
                            nm_curQ1,...
                            nm_curLoNotch,...
                            nm_curQ2,...
                            nm_curUpNotch,...
                            nm_curQ3,...
                            nm_curQ3,...
                            nm_curUpNotch,...
                            nm_curQ2,...
                            nm_curLoNotch,...
                            nm_curQ1],...
                    'Color',st_Cnf.colorBox);
    
    st_hBox.Median	= line(st_Cnf.axes,...
                    'XData',[nm_curBin - nm_notchLim,...
                            nm_curBin + nm_notchLim],...                            
                    'YData',[nm_curQ2,...
                            nm_curQ2],...
                    'Color',st_Cnf.colorMedian);
    
    st_hBox.LoWisker	= line(st_Cnf.axes,...
                        'XData',[nm_curBin,nm_curBin],...                            
                        'YData',[nm_curLoFence,nm_curQ1],...
                        'Color',st_Cnf.colorWisker,...
                        'LineStyle',st_Cnf.wiskerLine);
    
    st_hBox.UpWisker	= line(st_Cnf.axes,...
                        'XData',[nm_curBin,nm_curBin],...                            
                        'YData',[nm_curQ3,nm_curUpFence],...
                        'Color',st_Cnf.colorWisker,...
                        'LineStyle',st_Cnf.wiskerLine);
                            
    if st_Cnf.isFenced
            
        st_hBox.LoFence	= line(st_Cnf.axes,...
                        'XData',[nm_curBin - nm_fenceLim,...
                                nm_curBin + nm_fenceLim],...                            
                        'YData',[nm_curLoFence,nm_curLoFence],...
                        'Color',st_Cnf.colorWisker,...
                        'LineStyle',st_Cnf.wiskerLine);

        st_hBox.UpFence	= line(st_Cnf.axes,...
                        'XData',[nm_curBin - nm_fenceLim,...
                                nm_curBin + nm_fenceLim],...                            
                        'YData',[nm_curUpFence,nm_curUpFence],...
                        'Color',st_Cnf.colorWisker,...
                        'LineStyle',st_Cnf.wiskerLine);
    end     
    
    if nm_isMean
        st_hBox.Mean	= line(st_Cnf.axes,...
                        'XData',nm_curBin,...                            
                        'YData',st_Cnf.means(kk),...
                        'Color',st_Cnf.colorMean,...
                        'LineStyle','none',...
                        'Marker',st_Cnf.markMean);
    end
    
    if ~isempty(st_Cnf.markOutlier) && ~isempty(mx_outliers{kk,1})
        vt_curOutliers	= mx_outliers{kk,1};
        vt_curBinValues	= (2 * nm_fenceLim).*rand(size(vt_curOutliers)) + ...
                        (nm_curBin - nm_fenceLim);
                    
        st_hBox.LoOut	= line(st_Cnf.axes,...
                        'XData',vt_curBinValues,...                            
                        'YData',vt_curOutliers,...
                        'Color',st_Cnf.colorOutlier,...
                        'LineStyle','none',...
                        'Marker',st_Cnf.markOutlier);
        
    end
    
    if ~isempty(st_Cnf.markOutlier) && ~isempty(mx_outliers{kk,2})
        vt_curOutliers	= mx_outliers{kk,2};
        vt_curBinValues	= (2 * nm_fenceLim).*rand(size(vt_curOutliers)) + ...
                        (nm_curBin - nm_fenceLim);
                    
        st_hBox.LoOut	= line(st_Cnf.axes,...
                        'XData',vt_curBinValues,...                            
                        'YData',vt_curOutliers,...
                        'Color',st_Cnf.colorOutlier,...
                        'LineStyle','none',...
                        'Marker',st_Cnf.markOutlier);
        
    end
    
    vt_handles{kk}  = st_hBox;
    
end
