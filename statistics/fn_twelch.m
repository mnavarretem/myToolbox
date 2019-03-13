% fn_twelch

function [mx_tVals,mx_dof] = fn_twelch(mx_x,mx_y,nmx_dim)
% form Moser & Stevens (1992) and Ruxton (2006)
if nargin < 3
    nmx_dim = 1;
end

if isempty(mx_x) || isempty(mx_x)
    mx_tVals = nan;
    mx_dof = nan;
    return
end

if any(isnan(mx_x(:))) || any(isnan(mx_y(:)))    
    mx_uX1	= mean(mx_x,nmx_dim,'omitnan');
    mx_uX2	= mean(mx_y,nmx_dim,'omitnan');
    mx_vX1	= var(mx_x,0,nmx_dim,'omitnan');
    mx_vX2	= var(mx_y,0,nmx_dim,'omitnan');   
    mx_nX1	= sum(~isnan(mx_x),nmx_dim);
    mx_nX2	= sum(~isnan(mx_y),nmx_dim); 
else    
    mx_uX1	= mean(mx_x,nmx_dim);
    mx_uX2	= mean(mx_y,nmx_dim);
    mx_vX1	= var(mx_x,0,nmx_dim);
    mx_vX2	= var(mx_y,0,nmx_dim);
    mx_nX1	= size(mx_x,nmx_dim);
    mx_nX2	= size(mx_y,nmx_dim);
end

mx_u        = mx_vX2 ./ mx_vX1;

mx_tVals	= (mx_uX1-mx_uX2)./sqrt((mx_vX1./mx_nX1)+(mx_vX2./mx_nX2));
mx_dof      = (((1./mx_nX1) + mx_u./mx_nX2).^2) ./...
            ((1./(mx_nX1.^2.*(mx_nX1-1))) + ((mx_u.^2)./(mx_nX2.^2.*(mx_nX2-1))));