function vt_scale = fn_scalecorticalattenuation(vt_in,nm_distance,st_cfg)
% see Logothetis et al 2007 - In Vivo Measurement of Cortical
% Impedance Spectrum in Monkeys:Implications for Signal Propagation

if nargin < 3
    % Logothetis et al 2007 ~200Hz
    st_cfg.dipoleDistance	= 0.005;% (m) dipole distance
    st_cfg.impedance        = 75;   % (ohms) average for grey matter medio-lateral
end

% rho range rho = 1.65 to 3.9(Ohm m)
nm_rho	= 4*pi*st_cfg.dipoleDistance*st_cfg.impedance;
nm_Ip   = vt_in.*(4*pi)*st_cfg.dipoleDistance;

vt_scale    = nm_Ip/(2*pi)*((1./nm_distance) - 1./...
            sqrt(nm_distance.^2 + 4*st_cfg.dipoleDistance^2));
        
