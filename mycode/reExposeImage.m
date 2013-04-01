function [img, scale] = reExposeImage(img, imgEV, targetEV)
% Re-exposes and image to a target EV.
%
%   img = reExposeImage(img, imgEV, targetEV)
%
%
% Note: 
%   This function does not deal with saturation issues, so it works best
%   with floating-point data.
% 
% ----------
% Jean-Francois Lalonde

% compute scale factor
scale = 1./(2^(targetEV - imgEV));

% apply scale factor
img = img .* scale;