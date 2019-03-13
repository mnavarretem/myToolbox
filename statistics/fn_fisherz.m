function mx_zValues = fn_fisherz(mx_rValues)
% mx_zValues = fn_fisherz(mx_rValues) computes the Fisher z-transformation
% Hypotheses about the value of the  population correlation coefficient rho 
% between variables X and Y can be tested using the Fisher transformation 
% applied to the sample correlation coefficient. 

mx_zValues = 0.5 .* log((1+mx_rValues)./(1-mx_rValues));