function [timeStruct, year, month, day, hour, mn, sec, dateNum, utc] = ...
    dateTimeFromExif(imgPath, varargin)
% Extracts date and time information from EXIF.
%
%   [timeStruct, year, month, day, hour, min, sec, dateNum, utc] =
%       dateTimeFromExif(imgPath, ...)
%
% Returns a 'timeStruct' in the format required by sun_position.
%
% Optional parameters are:
%   utc: timezone difference wrt UTC
%   listAction: what to do if we're given a list of images. ('mean' or
%   'all')
%   useExifTool: whether to use exiftool or not (default = true). 
%   Make sure you know what you're doing when over-riding this parameter!
%
% See also:
%   imfinfo
%   sun_position
%
% ----------
% Jean-Francois Lalonde

% timezone difference wrt UTC
utc = -5;

% what to do if we're given a list of images. Possible values are:
% - 'mean': returns the mean value for each field
% - 'all': returns all values
listAction = 'mean'; 

% since exiftool is slow, we might not always want to use it.
% note: exiftool should be used automatically only when needed. so be
% careful when over-riding this parameter yourself, make sure you know what
% you are doing! 
useExifTool = true;

parseVarargin(varargin{:});

if iscell(imgPath)
    % if we're given a cell array of files, return mean time for all files
    nbFiles = length(imgPath);
    year    = cell(1, nbFiles);
    month   = cell(1, nbFiles);
    day     = cell(1, nbFiles);
    hour    = cell(1, nbFiles);
    mn      = cell(1, nbFiles);
    sec     = cell(1, nbFiles);
    dateNum = cell(1, nbFiles);
    utc     = cell(1, nbFiles);
    
    for i_img = 1:nbFiles
        [~,year{i_img}, month{i_img}, day{i_img}, hour{i_img}, mn{i_img}, ...
            sec{i_img}, dateNum{i_img}, utc{i_img}] = ...
            dateTimeFromExif(imgPath{i_img}, varargin{:});
    end
    
    year    = cell2mat(year);
    month   = cell2mat(month);
    day     = cell2mat(day);
    hour    = cell2mat(hour);
    mn      = cell2mat(mn);
    sec     = cell2mat(sec);
    dateNum = cell2mat(dateNum);
    utc     = cell2mat(utc);
    
    switch listAction
        case 'mean'
            dateNum = mean(dateNum);
            utc = mean(utc);
            [year, month, day, hour, mn, sec] = datevec(dateNum);
            
        case 'all'
            % we're ok, nothing to do.
            
        otherwise
            error('Unsupported ''listAction'': %s', listAction);
            
    end
    
    timeStruct = struct('year', year, 'month', month, 'day', day, ...
        'hour', hour, 'min', mn, 'sec', sec, 'UTC', utc);
   
    return;
end

if ~useExifTool
    info = imfinfo(imgPath);
    dateTimeStr = info(1).DateTime;
else
    % use exiftool. 
    
    % get creation date
    cmd = sprintf('exiftool -CreateDate -TimeZone %s -s3', imgPath);
    [r,outStr] = system(cmd);
    assert(r == 0, 'Error running exiftool. It must be installed.');
    
    outData = strsplit(outStr, '\n');
    dateTimeStr = outData{1};
    utc = sscanf(outData{2}, '%d:%d');
    if ~isempty(utc)
        utc = utc(1);
    else
        utc = -5;
    end
end

dateData = sscanf(dateTimeStr, '%d:%d:%d %d:%d:%d');

year = dateData(1);
month = dateData(2);
day = dateData(3);

hour = dateData(4);
mn = dateData(5);
sec = dateData(6);

dateNum = datenum(year, month, day, hour, mn, sec);
timeStruct = struct('year', year, 'month', month, 'day', day, ...
    'hour', hour, 'min', mn, 'sec', sec, 'UTC', utc);
