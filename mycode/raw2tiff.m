function tiffFilename = raw2tiff(rawFilename, varargin)
% Converts a RAW file to 16-bits linear TIFF file.
%
%   tiffFilename = raw2tiff(rawFilename, ...);
%
% Notes:
%   Uses a system call to dcraw, so it must be installed and working
%   properly.
%
%   The dcraw options used are:
%       -v     => verbose
%       -4     => linear 16-bits
%       -T     => save in .tiff format
%              => use default D65 white balance (don't specify the -w flag)
%       -o 0   => no color profile
%       -q 3   => highest possible Bayer interpolation
%   See http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
%
% See also:
%   hdr_imread
%
% ----------
% Jean-Francois Lalonde

% enabling this will disable Bayer interpolation and rescaling, so the
% image will be twice as small as the camera resolution
fullRaw = false;

% optional output filename
tiffFilename = '';

% over-ride dead pixel file
deadPixelFile = fullfile('data', '130315-sigmaCalibration', ...
    'radiometric', 'deadPixels', 'deadPixels.txt');

parseVarargin(varargin{:});

opts = sprintf('-v -4 -T -t 0 -j -P %s', deadPixelFile);
if fullRaw
    opts = [opts ' -D -h'];
else
    opts = [opts ' -q 3 -o 0'];
end

cmd = sprintf('dcraw %s %s', opts, rawFilename);
s = system(cmd);

if s > 0
    error(['raw2tiff:dcraw', 'Error running dcraw. '...
        'Is is installed properly?']);
end

[d,f] = fileparts(rawFilename);
outFilename = fullfile(d, [f '.tiff']);

assert(exist(outFilename, 'file')>0, ...
    'Could not find TIFF file (%s)', outFilename);

% Move files around if needed
if ~isempty(tiffFilename) && ~isequal(outFilename, tiffFilename)
    movefile(outFilename, tiffFilename);
else
    tiffFilename = outFilename;
end



