function ev100 = computeEV(N, t, iso)
% Computes the Exposure Value (EV) at ISO 100.
%
%   ev = computeEV(N, t, <iso>)
%
% Formally, ev100 = log2(N^2/t)-log2(ISO/100) where 
%   - N is the exposure (f-stops)
%   - t is the shutter time (in seconds)
%   - iso is the ISO speed (default = 100)
%
% Taken from:
%   http://en.wikipedia.org/wiki/Exposure_value
%
% ----------
% Jean-Francois Lalonde

if nargin == 2
    % by default, assume iso = 100
    iso = 100;
end

ev100 = log2(N^2/t)-log2(iso/100);
