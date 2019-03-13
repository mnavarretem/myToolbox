function [vt_measures,vt_outliers] = fn_obtainboxplotmeasures(vt_randVariable)
% [vt_measures,vt_outliers] = fn_obtainboxplotmeasures(vt_randVariable) 
% get boxplot measures from random variable vt_randVariable.
%
% Outputs:
% 
%       vt_measures:        m x 5 matrix indicating m distributions and 5
%                           measures [lowerfence,Q1,Q2,Q3,upperfence]
%
%       vt_outliers:        m x 2 cell matrix indicating the outlier values
%                           as [vt_lowOutliers,vt_upOutliers]. If not outliers 
%                           in all distributions, then an empty matrix can
%                           be passed in.
%
% Also see fn_boxplotmeasures
%
% Miguel Navarrete
% CUBRIC
% 2017

%% Code starts here

vt_randVariable	= vt_randVariable(:);
vt_randVariable	= vt_randVariable(~isnan(vt_randVariable));

% Computing measures for first click
nm_lowQtle  = prctile(vt_randVariable,25);
nm_midQtle  = prctile(vt_randVariable,50);
nm_uppQtle  = prctile(vt_randVariable,75);

nm_minVal   = min(vt_randVariable);
nm_maxVal   = max(vt_randVariable);

nm_minExt   = nm_lowQtle - 1.5 * (nm_uppQtle - nm_lowQtle);
nm_maxExt   = nm_uppQtle + 1.5 * (nm_uppQtle - nm_lowQtle);

vt_lowOutl  = vt_randVariable(vt_randVariable < nm_minExt);
vt_uppOutl  = vt_randVariable(vt_randVariable > nm_maxExt);

if ~isempty(vt_lowOutl)
    nm_minVal = nm_minExt;
end

if ~isempty(vt_uppOutl)
    nm_maxVal = nm_maxExt;
end

if isempty(nm_minVal)
    nm_minVal = nan;
end

if isempty(nm_maxVal)
    nm_maxVal = nan;
end

vt_measures(1,1)	= nm_minVal;
vt_measures(1,2)	= nm_lowQtle;
vt_measures(1,3)	= nm_midQtle;
vt_measures(1,4)	= nm_uppQtle;
vt_measures(1,5)	= nm_maxVal;

vt_outliers{1,1} = vt_lowOutl;
vt_outliers{1,2} = vt_uppOutl;