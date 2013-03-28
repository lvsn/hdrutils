function ev = computeEV(N, t, iso)
% Computes the Exposure Value (EV)
%
%   ev = computeEV(N, t, <iso>)
%
% Formally, ev = log2(N^2/t)+log2(ISO/100) where 
%   - N is the exposure (f-stops)
%   - t is the shutter time (in seconds)
%   - iso is the ISO speed (default = 100)
%
% ----------
% Jean-Francois Lalonde

if nargin == 2
    % by default, assume iso = 100
    iso = 100;
end

ev = log2(N^2/t)+log2(iso/100);
