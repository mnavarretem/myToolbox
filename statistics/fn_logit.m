function mx_logit = fn_logit(mx_p)

% limit boundaries
mx_p(mx_p < 0.01) = 0.01;
mx_p(mx_p > 0.99) = 0.99;

% compute logit
mx_logit	= log(mx_p./(1-mx_p));  


