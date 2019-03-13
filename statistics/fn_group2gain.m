function [mx_group1,mx_group2] = fn_group2gain(mx_group1,mx_group2,nm_beg,nm_end)

vt_szG1	= 1:size(mx_group1,1);
vt_szG2	= vt_szG1(end)+(1:size(mx_group2,1));

mx_group	= vertcat(mx_group1,mx_group2);
mx_group	= f_Matrix2Gain(mx_group,nm_beg,nm_end); 

mx_group1   = mx_group(vt_szG1,:);
mx_group2   = mx_group(vt_szG2,:);