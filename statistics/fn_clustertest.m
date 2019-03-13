function st_out =	fn_clustertest(mx_X,mx_Y,st_cfg)
% Descripption to complete

%   Example:
%       F1 = [36 60 39]; F2 = [73 55 70];
%       vt_pCluster = f_PermTestERP(F1,F2)
%       % Returns:
%       %   vt_pCluster = 0.2
%       vt_pCluster = f_PermTestERP(F1,F2,1)
%       % Returns:
%       %   vt_pCluster = 0.1
%
%   See also TTEST2, F_PERMTESTERP, F_WELCHTVALUE.

%   References:
%       Butar, FB., Ph, D., and Park, J. (2008). Permutation Tests for Comparing 
%       Two Populations. Journal of Mathematical Sciences and Mathematics 
%       Education 3 (2): 19–30..

% Miguel Navarrete; 12-25-2015;
% mnavarretem@gmail.com;

%% BSD license;
% Copyright (c) 2015, Miguel Navarrete;
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without 
% modification, are permitted provided that the following conditions are 
% met:
% 
%     * Redistributions of source code must retain the above copyright 
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright 
%       notice, this list of conditions and the following disclaimer in 
%       the documentation and/or other materials provided with the distribution
%       
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%% Code starts here;
         
nm_alpha	= 0.05;

if nargin < 2
    error('[fn_clustertest] - ERROR: Bad number of parameters')   
elseif nargin < 3
    st_cfg	= struct;
else
    if ~isstruct(st_cfg)
        st_cfg	= struct;  
    end
end

if ~isfield(st_cfg,'tails')
    st_cfg.tails = 0;
end

if ~isfield(st_cfg,'numPerm')
    st_cfg.numPerm = 1600;    % Keller-McNulty and Higgins (1987)
end

if ~isfield(st_cfg,'dimension')
    if numel(size(mx_X)) < 3
        st_cfg.dimension = 1;
    elseif numel(size(mx_X)) == 3
        st_cfg.dimension = 3;
    else
        error('fn_clustertest do not support > 3D matrices yet')
    end
end

if ~isfield(st_cfg,'alphaThr')
    st_cfg.alphaThr = nm_alpha;
end

if ~isfield(st_cfg,'autoThr')
    st_cfg.autoThr = 0;
end

if ~isfield(st_cfg,'alpha')
    st_cfg.alpha = nm_alpha;
end

if ~isfield(st_cfg,'clustStat')
    st_cfg.clustStat	= 'size';
end

if ~isfield(st_cfg,'mask')
    st_cfg.mask	= [];
end

% Set input parameters

if st_cfg.tails > -1 && st_cfg.tails < 1 && st_cfg.tails ~= 0
    st_cfg.tails = 0;
elseif st_cfg.tails > 1
    st_cfg.tails = 1;
elseif st_cfg.tails < -1
    st_cfg.tails = -1;
end

if isempty(mx_X) || isempty(mx_Y)
    
    st_out.tValues	= [];
    st_out.pValues	= [];
    st_out.idClust	= [];
    st_out.pCluster	= [];   
    st_out.pCrtClust= [];      
    st_out.alphaThr	= [];
    st_out.tThres   = [];
    return
end

nm_numX	= size(mx_X,st_cfg.dimension);
nm_numY	= size(mx_Y,st_cfg.dimension);

nm_numPer	= round(factorial(nm_numX+nm_numY)/...
            (factorial(nm_numX)*factorial(nm_numY)));
      
if	isnan(nm_numPer) || nm_numPer > st_cfg.numPerm
    nm_numPer = st_cfg.numPerm;
end

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%   0. auto Threshold selection
mx_idPerm	= [];

if st_cfg.autoThr
    vt_observ	= cat(st_cfg.dimension,mx_X,mx_Y);
    mx_idPerm	= fn_uperms(size(vt_observ,st_cfg.dimension),nm_numPer,nm_numX);
    mx_idS1     = mx_idPerm(:,1:nm_numX);
    mx_idS2     = mx_idPerm(:,nm_numX+1:end);
    vt_tDist    = nan(nm_numPer,1);
    vt_dDist    = nan(nm_numPer,1);
    
    for ii = 1:nm_numPer
        vt_G1       = f_SubSetMatrix(vt_observ,st_cfg.dimension,mx_idS1(ii,:));
        vt_G2       = f_SubSetMatrix(vt_observ,st_cfg.dimension,mx_idS2(ii,:));
        
        [vt_T,vt_D]	= f_WelchTvalue(vt_G1,vt_G2,st_cfg.dimension);
        vt_T        = abs(vt_T(:));
        vt_D        = vt_D(:);
        
        [vt_T,nm_i]	= max(vt_T);
        vt_tDist(ii)= vt_T;
        vt_dDist(ii)= vt_D(nm_i);
    end
    
    [vt_tDist,nm_i]	= sort(vt_tDist,'descend');
    vt_dDist        = vt_dDist(nm_i);
    
    nm_tVal	= prctile(vt_tDist,100.*(1-st_cfg.alphaThr));
    nm_i    = find(vt_tDist > nm_tVal,1,'last');
    nm_dof  = vt_dDist(nm_i);
    
	st_cfg.alphaThr = nm_alpha;
    st_cfg.tThres   = nm_tVal;
    nm_alphaThr     = tcdf(abs(nm_tVal),nm_dof,'upper');
    
else
    nm_alphaThr     = st_cfg.alphaThr; 
    st_cfg.tThres   = 0;
end


%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%   A. Obtain stats of original distributions
st_out            = fn_getstats(mx_X,mx_Y);
st_out.tThres     = st_cfg.tThres;
st_out.alphaThr   = nm_alphaThr;

if isempty(st_out.szClust)
    st_out.pCluster	= 1;    
    st_out.idClust	= [];
    st_out.szClust	= [];
    st_out.pCrtClust= [];
    return
end

nm_numObj	= numel(st_out.idClust);

%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%   B. Calculate cluster-level statistics by taking the sum of the t-values 
%   within a cluster. 
vt_clustStat	=  zeros(nm_numObj,1);

for cc = 1:nm_numObj
    switch st_cfg.clustStat
        case 'size'
            % maximum suprathreshold cluster size (max STCS)Nichols 2001
            vt_clustStat(cc) = st_out.szClust(cc);
        case 'tmax'
            vt_clustStat(cc) = max(st_out.tValues(st_out.idClust{cc}));    
        case 'tsum'
            % Maris 2007
            vt_clustStat(cc) = sum(st_out.tValues(st_out.idClust{cc}));
    end
end


%:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
%   C. Using the cluster-based permutation test, compute the Monte Carlo p-value 
%   for each cluster

if isempty(mx_idPerm)
    vt_observ	= cat(st_cfg.dimension,mx_X,mx_Y);
    mx_idPerm	= fn_uperms(size(vt_observ,st_cfg.dimension),nm_numPer,nm_numX);
    mx_idS1     = mx_idPerm(:,1:nm_numX);
    mx_idS2     = mx_idPerm(:,nm_numX+1:end);
end
vt_permStat	= nan(nm_numObj,nm_numPer); 

for ii = 1:nm_numPer
    vt_G1       = f_SubSetMatrix(vt_observ,st_cfg.dimension,mx_idS1(ii,:));
    vt_G2       = f_SubSetMatrix(vt_observ,st_cfg.dimension,mx_idS2(ii,:));
    st_iStat	= fn_getstats(vt_G1,vt_G2);
    
    if isempty(st_iStat.szClust)
        st_iStat.szClust = 0;
    end
        
    for cc = 1:nm_numObj
        switch st_cfg.clustStat
            case 'size'
                vt_permStat(:,ii) = max(st_iStat.szClust);
                break
            case 'tmax'
                vt_permStat(cc,ii) = max(st_iStat.tValues(st_out.idClust{cc}));    
            case 'tsum'
                vt_permStat(cc,ii) = sum(st_iStat.tValues(st_out.idClust{cc}));
        end
    end
end

vt_pCluster	=  nan(nm_numObj,1);

for cc = 1:nm_numObj
    vt_pCluster(cc) = sum(abs(vt_clustStat(cc)) <= vt_permStat(cc,:))/ nm_numPer;
end
if ischar(st_cfg.alpha)
    switch lower(st_cfg.alpha)
        case 'bonferroni'
            st_cfg.alpha	= nm_alpha/numel(vt_pCluster);
        case 'holm'
            vt_hCluster     = vt_pCluster > nm_alpha./...
                            (numel(vt_pCluster)+1-(1:numel(vt_pCluster)))';
                        
            if isempty(vt_pCluster(vt_hCluster))
                st_cfg.alpha    = nm_alpha;
            else
                st_cfg.alpha    = min(vt_pCluster(vt_hCluster));
            end
        case 'fdr'
            [vt_hCluster,st_cfg.alpha]	= fdr_bh(vt_pCluster); %#ok<ASGLU>
        otherwise
            st_cfg.alpha	= nm_alpha;
    end
end

vt_hCluster     = vt_pCluster < st_cfg.alpha;

st_out.idClust	= st_out.idClust(vt_hCluster);
st_out.szClust	= st_out.szClust(vt_hCluster);
st_out.pCluster	= vt_pCluster(vt_hCluster);
st_out.pCrtClust= st_cfg.alpha;

%% Sub-Functions
%...............................................................................
    function st_curStats = fn_getstats(mx_S1,mx_S2)
        %   1. Quatify the effect of the sample by the welch t-test

        [mx_t,mx_dof]	= f_WelchTvalue(mx_S1,mx_S2,st_cfg.dimension);
        mx_p            = tcdf(abs(mx_t),mx_dof,'upper');
        
        %   2. Select all values as positive, negative and rejected null
        %   hypotesis
        mx_pHyp	= mx_p < st_cfg.alphaThr;
        mx_tPos	= mx_t > st_cfg.tThres;
        mx_tNeg	= mx_t < -st_cfg.tThres;
        
        switch st_cfg.tails
            case -1
                mx_tPos	= false(size(mx_tPos)); 
            case 1
                mx_tNeg = false(size(mx_tNeg)); 
            otherwise
        end
        
        %   3. Cluster the selected samples in connected sets on the basis of 
        %   temporal/spectral/spatial adjacency
        if isempty(st_cfg.mask)
            st_cfg.mask	= true(size(mx_p));
            nm_conn     = 8;
        else            
            nm_conn     = 4;
        end
        
        vt_connPos	= bwconncomp(mx_tPos & mx_pHyp & st_cfg.mask,nm_conn);
        vt_connNeg	= bwconncomp(mx_tNeg & mx_pHyp & st_cfg.mask,nm_conn);
        vt_connPos  = vt_connPos.PixelIdxList(:);
        vt_connNeg  = vt_connNeg.PixelIdxList(:);
        
        vt_idClust	= vertcat(vt_connPos,vt_connNeg);
        
        [vt_clustN,vt_id]	= sort(cellfun(@numel,vt_idClust),'descend');
        vt_idClust          = vt_idClust(vt_id);
 
        st_curStats.tValues	= mx_t;
        st_curStats.pValues	= mx_p;
        st_curStats.idClust	= vt_idClust;
        st_curStats.szClust	= vt_clustN;
        
    end
%...............................................................................
    function mx_perm = fn_uperms(nm_numel,nm_numPer,nm_numS1)
        
        mx_perm     = zeros(nm_numPer, nm_numel, 'uint32');
        
        vt_idRef    = 1:nm_numel;
        mx_perm(1,:)= vt_idRef;
        
        nm_count    = 1;
        nm_numBlock = ceil(nm_numPer/10);
        
        while nm_count < nm_numPer
            [~,mx_Id]	= sort(rand(nm_numBlock,nm_numel),2); 
            mx_newId    = [mx_perm(1:nm_count, :); vt_idRef(mx_Id)];

            [~,vt_idC1]	= unique(sort(mx_newId(:,1:nm_numS1),2),...
                        'rows','stable');
            [~,vt_idC2]	= unique(sort(mx_newId(:,nm_numS1+1:end),2),...
                        'rows','stable');
            
            vt_idStore      	= false(size(mx_newId,1),1);
            vt_idStore(vt_idC1)	= true;
            vt_idC1             = vt_idStore;
            
            vt_idStore          = false(size(mx_newId,1),1);
            vt_idStore(vt_idC2)	= true;
            vt_idC2             = vt_idStore;
                        
            clear vt_idStore
            
            mx_newId    = mx_newId(vt_idC1 & vt_idC2,:);
            
            if size(mx_newId,1) > nm_count
                                
                mx_perm     = mx_newId;
                nm_count    = size(mx_newId,1);
                                
            end
        end
        
        if size(mx_perm,1) > nm_numPer
            mx_perm  = mx_perm(1:nm_numPer,:);
        end
        
    end
%...............................................................................

end