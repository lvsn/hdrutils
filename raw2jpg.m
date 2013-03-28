function jpgFilename = raw2jpg(rawFilename, jpgFilename)
% Converts a RAW file to a JPG
%
%   jpgFilename = raw2jpg(rawFilename, <jpgFilename>);
%
% Notes:
%   Uses a system call to dcraw, so it must be installed and working
%   properly.
%
%   The dcraw options used are:
%       -e     => extract thumbnail
%   See http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
%
% See also:
%   hdr_imread
%
% ----------
% Jean-Francois Lalonde

% Extracts the thumbnail embedded in the raw file.
cmd = sprintf('dcraw -e %s', rawFilename);
system(cmd);

[d,f] = fileparts(rawFilename);
outFilename = fullfile(d, [f '.thumb.jpg']);

assert(exist(outFilename, 'file')>0, ...
    'Could not find JPG file (%s)', outFilename);

% Move files around if needed
if nargin > 1 && ~isequal(outFilename, jpgFilename)
    movefile(outFilename, jpgFilename);
else
    jpgFilename = outFilename;
end



