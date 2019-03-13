function st_Stats	= fn_permutebivariatematrix(...
                    vt_xVal,vt_yVal,vt_zVal,vt_xBin,vt_yBin,ch_stat)
% mx_matrixCell  = fn_permutebivariatematrix(vt_xVal,vt_yVal,vt_zVal,vt_xBin,vt_yBin) 
% create a matrix mx_matrixCell as the average values vt_zVal located in
% positions (vt_xVal,vt_yVal) according to edge bins (vt_xBin,vt_yBin)

% Miguel Navarrete
% CUBRIC
% 2017
%%
nm_minNumel	= 5;

if nargin < 6
    ch_stat = 'median';
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

mx_matrixCell	= cell(max(vt_yGroups),max(vt_xGroups));

% fill matrix (nested loops are not optimal)
for xx = vt_xGroups(:)'
    
    vt_curXid	= vt_iXpos == xx;
    
    if sum(vt_curXid) == 0
        continue
    end
    
    for yy = vt_yGroups(:)'
        
        vt_curYid	= vt_iYpos == yy;            
        vt_curGroup	= vt_curXid & vt_curYid;
    
        if sum(vt_curGroup) == 0
            continue
        end
        
        mx_matrixCell{yy,xx}	= vertcat(mx_matrixCell{yy,xx},...
                                vt_zVal(vt_curGroup));
        
    end
end

switch ch_stat
    case 'mean'        
        mx_matrix	= cellfun(@mean,mx_matrixCell);
    case 'median'
        mx_matrix	= cellfun(@median,mx_matrixCell);
end

mx_matrixNumel      = cellfun(@numel,mx_matrixCell);
mx_matrixCompare	= mx_matrixNumel > nm_minNumel;
vt_idxGroup         = find(mx_matrixCompare);

[vt_row,vt_col]     = ind2sub(size(mx_matrix),vt_idxGroup);

mx_pVals    = nan(size(mx_matrix));
vt_pValues  = zeros(size(vt_row));

vt_advance  = round(numel(vt_row) .* [0.1:0.1:1]);
nm_advCount = 1;
fprintf('fn_permutebivariatematrix: ')
for nm_cId = 1:numel(vt_row)
    ir	= vt_row(nm_cId);
    ic  = vt_col(nm_cId);
    
    vt_compDist         = mx_matrixCell;
    vt_compDist{ir,ic}	= [];
    vt_compDist         = vt_compDist(:);
    
    vt_compDist = cell2mat(vt_compDist);
    vt_currDist	= mx_matrixCell{ir,ic};
    
    mx_pVals(ir,ic)     = f_PermTest(vt_currDist,vt_compDist,1,1600,ch_stat);
    vt_pValues(nm_cId)  = mx_pVals(ir,ic);
    
    if nm_cId >= vt_advance(nm_advCount)
        fprintf('|')
        nm_advCount = nm_advCount + 1;
    end
end
fprintf('\n')

[~, nm_crit_p]	= fdr_bh(vt_pValues);

st_Stats.pValues    = mx_pVals;
st_Stats.hypothesis	= mx_pVals <= nm_crit_p;
st_Stats.crit_pVal  = nm_crit_p;
st_Stats.numcomp    = numel(vt_pValues);


