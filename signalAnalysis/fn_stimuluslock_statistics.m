function st_out	= fn_stimuluslock_statistics(st_cfg)

if numel(size(st_cfg.stim)) == 3
    nm_dim	= 3;
else
    nm_dim	= 1;
end

if iscell(st_cfg.stim)
    mx_stim     = cell2mat(st_cfg.stim);
    mx_cont     = cell2mat(st_cfg.cont);
else
    mx_stim     = st_cfg.stim;
    mx_cont     = st_cfg.cont;    
end

st_stat	= fn_clustertest(mx_stim,mx_cont,st_cfg);
        
if isempty(st_stat.idClust)
    mx_signif   = [];
else
    vt_id       = vertcat(st_stat.idClust{:});     
    mx_signif   = false(size(st_stat.tValues));
    mx_signif(vt_id) = true;
end

st_out.cont         = single(mx_cont);
st_out.stim         = single(mx_stim);
st_out.meanCont     = single(mean(mx_cont,nm_dim,'omitnan'));
st_out.meanStim     = single(mean(mx_stim,nm_dim,'omitnan'));
st_out.semCont      = single(f_SEM(mx_cont,nm_dim));
st_out.semStim      = single(f_SEM(mx_stim,nm_dim));
st_out.tValues      = single(st_stat.tValues);
st_out.pValues      = single(st_stat.pValues);
st_out.idCluster    = st_stat.idClust;
st_out.pCluster     = st_stat.pCluster;
st_out.pCrtClust	= st_stat.pCrtClust;
st_out.tThres       = st_stat.tThres;
st_out.alphaThr     = st_stat.alphaThr;
st_out.signif       = logical(mx_signif);
