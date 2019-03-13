function [mx_mean mx_matrix]	= fn_createbivariatematrix(...
                    vt_xVal,vt_yVal,vt_zVal,vt_xBin,vt_yBin,ch_measure)
% mx_matrixCell  = fn_createbivariatematrix(vt_xVal,vt_yVal,vt_zVal,vt_xBin,vt_yBin) 
% create a matrix mx_matrixCell as the average values vt_zVal located in
% positions (vt_xVal,vt_yVal) according to edge bins (vt_xBin,vt_yBin)

% Miguel Navarrete
% CUBRIC
% 2017
%%
if nargin < 6
    ch_measure = 'median';
end

if numel(vt_xVal) == numel(vt_xBin) && numel(vt_yVal) == numel(vt_yBin) 
    vt_iXpos    = vt_xBin;
    vt_iYpos    = vt_yBin;
else
    vt_iXpos    = discretize(vt_xVal,vt_xBin);
    vt_iYpos    = discretize(vt_yVal,vt_yBin);
end
vt_xGroups  = unique(vt_iXpos);
vt_xGroups  = vt_xGroups(~isnan(vt_xGroups));
vt_yGroups  = unique(vt_iYpos);
vt_yGroups  = vt_yGroups(~isnan(vt_yGroups));

mx_matrixCell	= cell(numel(vt_yBin)-1,numel(vt_xBin)-1);

% fill matrix (nested loops are not optimal)
for xx = vt_xGroups(:)'
    
    vt_curXid	= vt_iXpos == xx;
    
    if sum(vt_curXid) == 0
        continue
    end
    
    for yy = vt_yGroups(:)'
        
        vt_curYid	= vt_iYpos == yy;            
        vt_curGroup	= vt_curXid & vt_curYid;
    
%         if sum(vt_curGroup) == 0
        if sum(vt_curGroup) < 3
%         if sum(vt_curGroup) < 5
%         if sum(vt_curGroup) < 10
            continue
        end
        
        mx_matrixCell{yy,xx}	= vertcat(mx_matrixCell{yy,xx},vt_zVal(vt_curGroup));
        
    end
end

mx_numel    = cellfun(@numel,mx_matrixCell);
nm_maxNumel = max(mx_numel(:));
mx_matrix   = nan(size(mx_numel,1),size(mx_numel,2),nm_maxNumel);

vt_Idx      = find(mx_numel);
[vt_r,vt_c]	= ind2sub(size(mx_numel),vt_Idx);

for ii = 1:numel(vt_Idx)
    nm_curSize	= mx_numel(vt_r(ii),vt_c(ii));
    vt_cId      = 1:nm_curSize;
    mx_matrix(vt_r(ii),vt_c(ii),vt_cId) = permute(mx_matrixCell{vt_Idx(ii)}(:),...
                                        [3,2,1]);
end

switch ch_measure
    case 'mean'        
        mx_mean	= cellfun(@mean,mx_matrixCell);
    case 'median'
        mx_mean	= cellfun(@median,mx_matrixCell);
end

% mx_matrixCell(isnan(mx_matrixCell)) = 0;

