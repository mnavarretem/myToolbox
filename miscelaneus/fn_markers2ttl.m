function nm_outTTL = fn_markers2ttl(nm_inTTL,nm_trigger)
% nm_outTTL = fn_markers2ttl(nm_inTTL,nm_trigger) converts a TTL marker and
% binary output to an unique TTL word to be sent to the parallel port. The
% TTL marker is a binary word of 7-bits and the marker is a logical 1 or 0.
% The TTL output consist of a binary word of 8-bits with the first 7 as the
% original TTL input, and the most significative bit corresponds to the
% marker. The TTL input must be a integer between 0 and 128, any greater value 
% is set to 127, and negative integers are set to 0
%
% M. Navarrete. CUBRIC. 2018

%% Variable check

if nargin ~= 2
    error('[fn_markers2ttl] - wrong number of input arguments!')
end

if nm_inTTL >= 128
   nm_inTTL = 127;
end

if nm_inTTL < 0
   nm_inTTL = 0;
end

nm_trigger = logical(nm_trigger);

%% Convert values
nm_outTTL   = false(1,8);
nm_inTTL	= logical(de2bi(nm_inTTL));

nm_outTTL(1:numel(nm_inTTL))= nm_inTTL;
nm_outTTL(8)                = nm_trigger;

nm_outTTL   = bi2de(nm_outTTL);
