function st_Stats = fn_multcomparenonpar(vt_input)
% vt_pValues = fn_multcomparenonpar(vt_input) returns a matrix vt_pValues of 
% a pairwise multiple comparison non paramtric permutation test. vt_input
% is a 1 x n cell array with n groups. NaN values are ignored.

%% Variable definition
vt_input        = vt_input(:);
nm_groups       = numel(vt_input);
mx_combinations	= nchoosek(1:nm_groups,2);
ch_stat         = 'mean';

%% Compute p values
vt_pValues	= nan(size(mx_combinations,1),1);

mx_pValues	= nan(nm_groups);
mx_tValues	= nan(nm_groups);

vt_advance  = round(size(mx_combinations,1) .* [0.1:0.1:1]);
nm_advCount = 1;
fprintf('fn_multcomparenonpar: ')
for kk = 1:size(mx_combinations,1)
    nm_iGr1	= mx_combinations(kk,1);
    nm_iGr2	= mx_combinations(kk,2);
    
    vt_dGr1	= vt_input{nm_iGr1};
    vt_dGr2	= vt_input{nm_iGr2};
    
    vt_dGr1	= vt_dGr1(~isnan(vt_dGr1));
    vt_dGr2	= vt_dGr2(~isnan(vt_dGr2));
    
    if numel(vt_dGr1) < 5 || numel(vt_dGr2) < 5 
        mx_tValues(nm_iGr1,nm_iGr2)	= 0;
        mx_tValues(nm_iGr2,nm_iGr1)	= 0;
        continue
    end
    
    vt_pValues(kk)	= f_PermTest(vt_dGr1,vt_dGr2,2,1600,ch_stat);
    
    mx_pValues(nm_iGr1,nm_iGr2)	= vt_pValues(kk);
    mx_tValues(nm_iGr1,nm_iGr2)	= median(vt_dGr1) - median(vt_dGr2);
    mx_pValues(nm_iGr2,nm_iGr1)	= vt_pValues(kk);
    mx_tValues(nm_iGr2,nm_iGr1)	= median(vt_dGr2) - median(vt_dGr1);
        
    if kk >= vt_advance(nm_advCount)
        fprintf('|')
        nm_advCount = nm_advCount + 1;
    end
    
end
fprintf('\n')

%% Compute multicomparison 
% by default takes independent distributions or positevly correlated
vt_isNaN        = isnan(vt_pValues);
mx_combinations	= mx_combinations(~vt_isNaN,:);
vt_pValues      = vt_pValues(~vt_isNaN);

[vt_hypothesis, nm_crit_p] = fdr_bh(vt_pValues);

st_Stats.combinations   = mx_combinations;
st_Stats.pValues        = vt_pValues;
st_Stats.hypothesis     = vt_hypothesis;
st_Stats.crit_pVal      = nm_crit_p;
