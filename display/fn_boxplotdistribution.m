function vt_handles = fn_boxplotdistribution(mx_distribution,st_Cnf)
% vt_handles = fn_boxplotdistribution(vt_distribution) plots a boxplot
% diagram according to the distribution values in vt_distribution,
%
% Inputs:
% 
%       mx_distribution:    If matrix each gorup is determined colomnwise,
%                           if cell each cell is stablish as a group.
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
%                                   if empty, then no marker
%
%           - st_Cnf.wiskerLine:    Matlab LineStyle for wiskers (default: --),

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
    st_Cnf      = [];
end

if ~iscell(mx_distribution)
    mx_distribution	= mat2cell(mx_distribution,size(mx_distribution,1),...
                    ones(1,size(mx_distribution,2))); 
end

if nargin < 2 || isempty(st_Cnf)
    st_Cnf      = struct;
end

if ~isfield(st_Cnf,'groupTick')
    st_Cnf.groupTick	= 1:numel(mx_distribution);
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
if ~isfield(st_Cnf,'isNotched')
    st_Cnf.isNotched 	= false;
end
if ~isfield(st_Cnf,'fenceWidth')
    st_Cnf.notchWidth	= 0.5;
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

%% Obtain boxplot measures

mx_measures	= nan(numel(mx_distribution),5);
mx_outliers	= cell(numel(mx_distribution),2);
vt_means    = nan(numel(mx_distribution),1);
vt_95CI     = nan(numel(mx_distribution),1);

for kk = 1:numel(mx_distribution)
    vt_curDistribution      = mx_distribution{kk}(:);
    vt_curDistribution      = vt_curDistribution(~isnan(vt_curDistribution));
    
    [vt_curMeas,vt_curOutl]	= fn_obtainboxplotmeasures(vt_curDistribution);
    
    mx_measures(kk,:)       = vt_curMeas;
    mx_outliers(kk,:)       = vt_curOutl;
    vt_means(kk,1)          = mean(vt_curDistribution);
    vt_95CI(kk,1)           = 3.14 * diff(vt_curMeas([2,4])) / ...
                            sqrt(numel(vt_curDistribution)) ;
end

st_Cnf.means        = vt_means;
st_Cnf.ConfidenceI  = vt_95CI;

vt_handles	= fn_boxplotmeasures(mx_measures,mx_outliers,st_Cnf);
