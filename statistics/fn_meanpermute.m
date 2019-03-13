function vt_meanPerm = fn_meanpermute(vt_data,nm_perm,nm_ratio)

if nm_perm > factorial(numel(vt_data))
    vt_meanPerm = nan;
    return
end

nm_numRatio     = round(nm_ratio.*numel(vt_data));
[~,mx_idPerm]	= sort(rand(nm_perm,numel(vt_data)),2); 
mx_idPerm       = mx_idPerm(:,1:nm_numRatio);
mx_blockData    = vt_data(mx_idPerm);

vt_meanPerm		= mean(mx_blockData,2);

