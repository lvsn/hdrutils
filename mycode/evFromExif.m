function ev = evFromExif(imgPath)
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

info = imfinfo(imgPath);

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
        
        s = textscan(s, '%s %d', 1, 'Delimiter', ':');
        iso = double(s{2});
        
    end
else
    error('Could not find exposure information in image header');
end

ev = computeEV(N, t, iso);
