function mx_map	= fn_colormap(nm_numel,ch_scheme)

% fn_colormap Returns custom colormaps with rainbow-like colors
%   FN_COLORMAP(N,SCHEME) returns an Nx3 colormap. 
%   usage: mx_map	= fn_colormap(nm_numel,ch_schema);
%
% Based on PMKMP coded by Matteo Niccoli
%
%
%   arguments: (input)
%   scheme - can be one of the following strings:
%
%     'LinLight'	Lab-based linear lightness rainbow. 
%                   For interval data displayed without external lighting
%                   100% perceptual
% 
%     'LinHot'     Linear lightness modification of Matlab's hot color palette. 
%                  For interval data displayed without external lighting
%                  100% perceptual    
%
% 
% cmocean color names: 
% 
%          SEQUENTIAL:                DIVERGING: 
%          'thermal'                  'balance'
%          'haline'                   'delta'
%          'solar'                    'curl'
%          'ice'
%          'gray'                     CONSTANT LIGHTNESS:
%          'oxy'                      'phase'
%          'deep'
%          'dense'
%          'algae'
%          'matter'
%          'turbid'
%          'speed'
%          'amp'
%          'tempo'
%
%   n - scalar specifying number of points in the colorbar. Maximum n=256
%      If n is not specified, the size of the colormap is determined by the
%      current figure. If no figure exists, MATLAB creates one.
%
%
%   arguments: (output)
%   map - colormap of the chosen scheme
%

%% build colormap 
narginchk(0,2)
nargoutchk(0,1)

if nargin<2
  ch_scheme = 'viridis';
end
if nargin<1
  nm_numel = size(get(gcf,'colormap'),1);
end
if nm_numel>1024
error('Maximum number of 256 points for colormap exceeded');
end
if nm_numel<2
error('n must be >= 2');
end

% valid ch_schemes
switch lower(ch_scheme)
    case 'viridis'
        % from matplotlib
        mx_baseMap	= colormap_viridis(256);
    case 'magma'
        % from matplotlib
        mx_baseMap	= colormap_magma(256);
    case 'plasma'
        % from matplotlib
        mx_baseMap	= colormap_plasma(256);
    case 'inferno'
        % from matplotlib
        mx_baseMap	= colormap_inferno(256);
    case 'vega10'
        % from matplotlib
        mx_baseMap	= colormap_vega10(256);
    case 'vega20'
        % from matplotlib
        mx_baseMap	= colormap_vega20(256);
    case 'linlight'
        mx_baseMap = fn_funLinlight;
    case 'linhot'
        mx_baseMap = fn_funLinhot;
    case 'seqygb'
        mx_baseMap = fn_funSeqYGB;
    case 'seqbpr'
        mx_baseMap = fn_funSeqBPr;
    case 'divbrbg'
        mx_baseMap = fn_funDivBrBG;
    case 'divprg'
        mx_baseMap = fn_funDivPrG;
    case 'divpror'
        mx_baseMap = fn_funDivPrOr;
    case 'divrb'
        mx_baseMap = fn_funDivRB;
    case 'divrgy'
        mx_baseMap = fn_funDivRGy;
    otherwise
        try 
            mx_baseMap = cmocean(lower(ch_scheme));
        catch
            error(['Invalid scheme ' ch_scheme])
        end
end

% interpolating to get desired number of points/colors, n
vt_idx1	= linspace(1,nm_numel,size(mx_baseMap,1));
vt_idx2	= 1:nm_numel;
mx_map	= labinterp(vt_idx1,mx_baseMap,vt_idx2);
mx_map	= max(mx_map,0); % eliminate occasional, small negative numbers 
                  % occurring at one end of the Edge colormx_map because of
                  % cubic interpolation
                  
%% Sub-functions 


function mx_baseMap = fn_funLinlight
    mx_baseMap	=  [0.0143	0.0143	0.0143
                0.1413	0.0555	0.1256
                0.1761	0.0911	0.2782
                0.1710	0.1314	0.4540
                0.1074	0.2234	0.4984
                0.0686	0.3044	0.5068
                0.0008	0.3927	0.4267
                0.0000	0.4763	0.3464
                0.0000	0.5565	0.2469
                0.0000	0.6381	0.1638
                0.2167	0.6966	0.0000
                0.3898	0.7563	0.0000
                0.6912	0.7795	0.0000
                0.8548	0.8041	0.4555
                0.9712	0.8429	0.7287
                0.9692	0.9273	0.8961];
            
end

function mx_baseMap = fn_funLinhot
    mx_baseMap	=  [0.0225	0.0121	0.0121
                0.1927	0.0225	0.0311
                0.3243	0.0106	0.0000
                0.4463	0.0000	0.0091
                0.5706	0.0000	0.0737
                0.6969	0.0000	0.1337
                0.8213	0.0000	0.1792
                0.8636	0.0000	0.0565
                0.8821	0.2555	0.0000
                0.8720	0.4182	0.0000
                0.8424	0.5552	0.0000
                0.8031	0.6776	0.0000
                0.7659	0.7870	0.0000
                0.8170	0.8296	0.0000
                0.8853	0.8896	0.4113
                0.9481	0.9486	0.7165];
end

function mx_baseMap = fn_funSeqYGB
    mx_baseMap	=  flipud([255,255,217
                237,248,177
                199,233,180
                127,205,187
                65,182,196
                29,145,192
                34,94,168
                37,52,148
                8,29,88]/255);
end

function mx_baseMap = fn_funSeqBPr
    mx_baseMap	=  flipud([247,252,253
                224,236,244
                191,211,230
                158,188,218
                140,150,198
                140,107,177
                136,65,157
                129,15,124
                77,0,75]/255);
end

function mx_baseMap = fn_funDivBrBG
    mx_baseMap	=  flipud([84,48,5
                140,81,10
                191,129,45
                223,194,125
                246,232,195
                245,245,245
                199,234,229
                128,205,193
                53,151,143
                1,102,94
                0,60,48]/255);
end

function mx_baseMap = fn_funDivPrG
    mx_baseMap	=  flipud([64,0,75
                118,42,131
                153,112,171
                194,165,207
                231,212,232
                247,247,247
                217,240,211
                166,219,160
                90,174,97
                27,120,55
                0,68,27]/255);
end

function mx_baseMap = fn_funDivPrOr
    mx_baseMap	=  flipud([127,59,8
                179,88,6
                224,130,20
                253,184,99
                254,224,182
                247,247,247
                216,218,235
                178,171,210
                128,115,172
                84,39,136
                45,0,75]/255);
end

function mx_baseMap = fn_funDivRB
    mx_baseMap	=  flipud([103,0,31
                178,24,43
                214,96,77
                244,165,130
                253,219,199
                247,247,247
                209,229,240
                146,197,222
                67,147,195
                33,102,172
                5,48,97]/255);
end

function mx_baseMap = fn_funDivRGy
    mx_baseMap	=  flipud([103,0,31
                178,24,43
                214,96,77
                244,165,130
                253,219,199
                255,255,255
                224,224,224
                186,186,186
                135,135,135
                77,77,77
                26,26,26]/255);
end
end