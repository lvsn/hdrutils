function ev = evFromExif(imgPath, varargin)
% Extracts EV (Exposure Value) from EXIF.
%
%   ev = evFromExif(imgPath)
%
% Computes the Exposure Value (EV) from the information available within
% the EXIF fields. 
% 
% See also:
%   imfinfo
%   computeEV
%
% ----------
% Jean-Francois Lalonde

parseVarargin(varargin{:});

info = imfinfo(imgPath);

if isfield(info, 'DigitalCamera')
    if length(info) > 1
        info = info(1);
    end
    t = info.DigitalCamera.ExposureTime;
    N = info.DigitalCamera.FNumber;
    iso = info.DigitalCamera.ISOSpeedRatings;
else
    error('Could not find exposure information in image header');
end

ev = computeEV(N, t, iso);
