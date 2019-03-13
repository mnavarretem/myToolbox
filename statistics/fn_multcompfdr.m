function st_stats = fn_multcompfdr(vt_input)
% vt_pValues = fn_multcomparenonpar(vt_input) returns a matrix vt_pValues of 
% a pairwise multiple comparison non paramtric permutation test. vt_input
% is a 1 x n cell array with n groups. NaN values are ignored.

%% Variable definition
nm_minNumel     = 5;
vt_input        = vt_input(:);
nm_groups       = numel(vt_input);

% nm_perm         = 200;
% nm_ratio        = 2/3;
% vt_input     = cellfun(@(x) fn_meanpermute(x,nm_perm,nm_ratio),vt_input,...
%             'UniformOutput',false);

mx_combinations	= nchoosek(1:nm_groups,2);

%% Compute p values
vt_tValues  = nan(length(mx_combinations),1);
vt_pValues  = nan(length(mx_combinations),1);
mx_pValues	= nan(nm_groups);
mx_tValues	= nan(nm_groups);
mx_dof      = nan(nm_groups);

vt_advance  = round(size(mx_combinations,1) .* [0.1:0.1:1]);
nm_advCount = 1;

% fprintf('fn_multcompfdr: ')
for kk = 1:size(mx_combinations,1)
    nm_iGr1	= mx_combinations(kk,1);
    nm_iGr2	= mx_combinations(kk,2);
    
    vt_dGr1	= vt_input{nm_iGr1};
    vt_dGr2	= vt_input{nm_iGr2};
    
    vt_dGr1	= vt_dGr1(~isnan(vt_dGr1));
    vt_dGr2	= vt_dGr2(~isnan(vt_dGr2));
    
    if numel(vt_dGr1) < nm_minNumel || numel(vt_dGr2) < nm_minNumel
        mx_pValues(nm_iGr1,nm_iGr2)	= nan;
        mx_tValues(nm_iGr1,nm_iGr2)	= 0;
        mx_dof(nm_iGr1,nm_iGr2)		= 0;
        
        mx_pValues(nm_iGr2,nm_iGr1)	= nan;
        mx_tValues(nm_iGr2,nm_iGr1)	= 0;
        mx_dof(nm_iGr2,nm_iGr1)		= 0;
        continue
    end
    
    [nm_tTm,nm_dofTm]	= f_WelchTvalue(vt_dGr1,vt_dGr2);
    
    
    mx_pValues(nm_iGr1,nm_iGr2)	= 2 * tcdf(-abs(nm_tTm), nm_dofTm);
    mx_tValues(nm_iGr1,nm_iGr2)	= nm_tTm;
    mx_dof(nm_iGr1,nm_iGr2)		= nm_dofTm;
    
    mx_pValues(nm_iGr2,nm_iGr1)	= mx_pValues(nm_iGr1,nm_iGr2);
    mx_tValues(nm_iGr2,nm_iGr1)	= -nm_tTm;
    mx_dof(nm_iGr2,nm_iGr1)		= nm_dofTm;
    
    vt_pValues(kk)              = mx_pValues(nm_iGr1,nm_iGr2);
    vt_tValues(kk)              = nm_tTm;
    
        
%     if kk >= vt_advance(nm_advCount)
%         fprintf('|')
%         nm_advCount = nm_advCount + 1;
%     end
    
end
% fprintf('\n')

%% Compute multicomparison 
% by default takes independent distributions or positevly correlated
vt_pValues      = mx_pValues(:);
vt_isNaN        = isnan(vt_pValues);
vt_pValues      = vt_pValues(~vt_isNaN);

[vt_hypothesis, nm_crit_p] = fdr_bh(vt_pValues,0.05,'pdep');

st_stats.combinations   = mx_combinations;
st_stats.pValues        = vt_pValues;
st_stats.hypothesis     = vt_hypothesis;
st_stats.pMatrix        = mx_pValues;
st_stats.tMatrix        = mx_tValues;
st_stats.crit_p         = nm_crit_p;


