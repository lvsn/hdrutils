function im = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats.
% 
%   im = hdr_imread(filename, ...)
%
% Note:
%   Uses the command-line executable 'dcraw' to read RAW files. See:
%   http://www.cybercom.net/~dcoffin/dcraw/
%
% See also:
%   imread
%   exrread
%   dcraw 
%
% ----------
% Jean-Francois Lalonde

[p,f,ext] = fileparts(filename);

switch lower(ext)
    case '.hdr'
        % radiance HDR format
        im = hdrread(filename, varargin{:});
        
    case '.exr'
        % openEXR format
        im = exrread(filename);
        
    case {'.nef', '.cr2'}
        % Nikon/Canon RAW formats, use dcraw to convert.
        % options used are:
        %   -v     => verbose
        %   -4     => linear 16-bits
        %   -T     => save in .tiff format
        %          => default white balance behavior (D65 light source)
        %   -o 0   => no color profile
        %   -q 3   => highest possible Bayer interpolation
        % See http://www.guillermoluijk.com/tutorial/dcraw/index_en.htm
        cmd = sprintf('dcraw -v -4 -T -q 3 -o 0 %s', filename);
        system(cmd);
        
        % Read the generated tiff file
        tiffFile = fullfile(p, [f, '.tiff']);
        im = im2double(imread(tiffFile));
        
        % Clean up 
        delete(tiffFile);
        
    otherwise
        % other image formats supported by imread
        im = im2double(imread(filename, varargin{:}));
        
end