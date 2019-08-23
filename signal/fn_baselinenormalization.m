% function fn_trial_normalization.m
% 
function mx_out = fn_baselinenormalization(mx_input,vt_baseline,ch_method)

%% Check input values
if nargin < 1
    error('[fn_trial_normalization] - ERROR: bad number of parameters!')
end

if ~exist('vt_baseline', 'var') || isempty(vt_baseline)
    vt_baseline = [1,size(mx_input,2)];
end

if ~exist('ch_method', 'var') || isempty(ch_method)
    ch_method = 'abs';
end

if vt_baseline(1) < 1
    vt_baseline(1) = 1;
end
if vt_baseline(2) > size(mx_input, 2)
    vt_baseline(2) = size(mx_input, 2);
end

%% Compute baseline input values
vt_mean	= mean(mx_input(:,vt_baseline(1):vt_baseline(2),:),2);
vt_std	= std(mx_input(:,vt_baseline(1):vt_baseline(2),:),0,2);

switch lower(ch_method)
    case {'zscore','z'}
        mx_out	= (mx_input - repmat(vt_mean,1,size(mx_input,2)))./ ...
                repmat(vt_std, 1, size(mx_input, 2));
            
    case {'ratio','absolute','abs'}
        mx_out	= mx_input./repmat(vt_mean,1,size(mx_input, 2));
        
    case {'logaritmic','log'}
        mx_out	= mx_input./repmat(vt_mean,1,size(mx_input, 2));
        mx_out  = 10*log10(mx_out);
        
    otherwise        
        error('[fn_trial_normalization] - wrong method!')
end

end
