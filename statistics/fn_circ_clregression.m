function [nm_a1,nm_a2,nm_b] = fn_circ_clregression(vt_alpha, vt_x)
%
% [nm_a1,nm_a2,nm_b] = fn_circ_clregression(vt_alpha, vt_x)
%   Regression model between one circular and one linear random
%   variable.
%
%   Input:
%     vt_alpha   sample of angles in radians
%     vt_x       sample of linear random variable
%
%   Output:
%     nm_a1, nm_a2	angular coefficient
%     nm_b          linear coefficient
%   
%   Regression model is
%       vt_xhat =  a1*cos(vt_alpha) + a2*sin(vt_alpha) + b
%
% References:
%       Jupp & Mardia (1980)
%       Mardia (1976)
%
%
% Based on circ_corrcl from Circular Statistics Toolboox for Matlab


if size(vt_alpha,2) > size(vt_alpha,1)
	vt_alpha = vt_alpha';
end

if size(vt_x,2) > size(vt_x,1)
	vt_x = vt_x';
end

if length(vt_alpha)~=length(vt_x)
  error('Input dimensions do not match.')
end

% vt_num = length(vt_alpha);

% compute correlation coefficent for sin and cos independently
vt_rxs  = corr(vt_x,sin(vt_alpha));
vt_rxc  = corr(vt_x,cos(vt_alpha));
vt_rcs  = corr(sin(vt_alpha),cos(vt_alpha));

% compute statistics
vt_sig	= var(vt_x);
vt_Vc   = var(cos(vt_alpha));
vt_Vs   = var(sin(vt_alpha));

nm_a1	= sqrt(vt_sig/vt_Vc)*((vt_rxc - vt_rcs*vt_rxs) / (1-vt_rcs^2));
nm_a2	= sqrt(vt_sig/vt_Vs)*((vt_rxs - vt_rcs*vt_rxc) / (1-vt_rcs^2));

% compute linear coefficent  Mardia & Sutton (1978)
nm_b    = mean(vt_x) - circ_r(vt_alpha) .* (...
        nm_a1 * cos(circ_mean(vt_alpha)) + ...
        nm_a2 * sin(circ_mean(vt_alpha)));

% % compute angular-linear correlation Mardia (1976)
% vt_rho = sqrt((vt_rxc^2 + vt_rxs^2 - 2*vt_rxc*vt_rxs*vt_rcs)/(1-vt_rcs^2));
% 
% % compute pvalue
% pval = 1 - chi2cdf(vt_num*vt_rho^2,2);