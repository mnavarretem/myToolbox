function mx_diff = fn_alldiff(mx_x,mx_y)
% fn_alldiff compute all pairwise differences vt_x - vt_y. mx_diff is a
% matrix with numel(vt_x) x numel(vt_y) elements.

if isempty(mx_x) || isempty(mx_y) 
    mx_diff	= nan;
    return
end
    
mx_x	= mx_x(:);
mx_y	= mx_y(:)';

nm_numX	= numel(mx_x);
nm_numY	= numel(mx_y);

mx_x    = repmat(mx_x,1,nm_numY);
mx_y    = repmat(mx_y,nm_numX,1);

mx_diff = mx_x - mx_y;