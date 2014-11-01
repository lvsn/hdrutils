function [ev, t, N, iso] = evFromExif(imgPath)
% Extracts EV (Exposure Value) from EXIF.
%
%   [ev, t, N, iso] = evFromExif(imgPath)
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

if iscell(imgPath)
    ev = zeros(1, length(imgPath));
    t = zeros(1, length(imgPath));
    N = zeros(1, length(imgPath));
    iso = zeros(1, length(imgPath));
    for i_img = 1:length(imgPath)
        [ev(i_img), t(i_img), N(i_img), iso(i_img)] = ...
            evFromExif(imgPath{i_img});
    end
    return;
end

% turn off annoying warning
warnState = warning('off', 'MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero');
info = imfinfo(imgPath);
warning(warnState);

if isfield(info, 'DigitalCamera')
    if length(info) > 1
        info = info(1);
    end
    t = info.DigitalCamera.ExposureTime;
    N = info.DigitalCamera.FNumber;
    
    if isfield(info.DigitalCamera, 'ISOSpeedRatings')
        iso = info.DigitalCamera.ISOSpeedRatings;
    else
        % this is sometimes hidden "deeper" in the EXIF information, which
        % imfinfo is not able to extract. Use the more powerful exiftool
        % (must be installed on the system)
        
        % if the path is not local, download the image first!
        if ~isempty(strfind(imgPath, 'http'))
            % download to tmp file
            [~,~,ext] = fileparts(imgPath);
            tmpImgPath = [tempname, ext];
            urlwrite(imgPath, tmpImgPath);
            
            imgPath = tmpImgPath;
        end
        cmd = sprintf('exiftool -ISO %s', imgPath);
        [r,s] = system(cmd);
        
        if r
            error('Could not run exiftool');
        end
        
        s = textscan(s, '%s %s', 1, 'Delimiter', ':');
        if ~isnan(str2double(s{2}{1}))
            iso = str2double(s{2}{1});
        else
            % contains a string too?
            s = textscan(s{2}{1}, '%s %d', 1, 'Delimiter', ' ');
            iso = double(s{2});
        end
    end
else
    error('Could not find exposure information in image header');
end

ev = computeEV(N, t, iso);
