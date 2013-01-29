function im = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats
% 
%   im = hdr_imread(filename, ...)
%
% See also:
%   imread
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
        cmd = sprintf('dcraw -v -6 -T -W -g 1 1 -w %s', filename);
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