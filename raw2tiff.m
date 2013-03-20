function tiffFilename = raw2tiff(rawFilename, tiffFilename)
% Converts a RAW file to 16-bits linear TIFF file.
%
%   tiffFilename = raw2tiff(rawFilename, <tiffFilename>);
%
% The output TIFF file will have the same 
%
% Notes:
%   Uses a system call to dcraw, so it must be installed and working
%   properly.
%
%   The dcraw options used are:
%       -v     => verbose
%       -4     => linear 16-bits
%       -T     => save in .tiff format
%       -w     => use camera's white balance 
%       -o 0   => no color profile
%       -q 3   => highest possible Bayer interpolation
%   See http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
%
% See also:
%   hdr_imread
%
% ----------
% Jean-Francois Lalonde

cmd = sprintf('dcraw -v -4 -T -w -q 3 -o 0 %s', rawFilename);
system(cmd);

[d,f] = fileparts(rawFilename);
outFilename = fullfile(d, [f '.tiff']);

assert(exist(outFilename, 'file')>0, ...
    'Could not find TIFF file (%s)', outFilename);

% Move files around if needed
if nargin > 1 && ~isequal(outFilename, tiffFilename)
    movefile(outFilename, tiffFilename);
else
    tiffFilename = outFilename;
end



