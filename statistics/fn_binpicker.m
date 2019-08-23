function vt_bins	= fn_binpicker(vt_values,mx_edges)
% fn_binpicker select the number of vector vt_values contained into the 
% edges defined by mx_edges (nx2)

% Miguel Navarrete
% CUBRIC
% 2019

if isempty(vt_values) || isempty(mx_edges) 
    vt_bins	= nan;
    return
end
    
if size(mx_edges,2) ~= 2
    error('[fn_binpicker] - mx_edges should be a nx2 matrix')
end

mx_values	= single(repmat(vt_values(:),1,size(mx_edges,1)));
mx_loEdge   = single(repmat(mx_edges(:,1)',numel(vt_values),1));
mx_hiEdge	= single(repmat(mx_edges(:,2)',numel(vt_values),1));

vt_bins 	= mx_loEdge < mx_values & mx_values < mx_hiEdge;
vt_bins     = sum(vt_bins);
vt_bins     = vt_bins(:);
