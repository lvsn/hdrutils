function im = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats.
% 
%   im = hdr_imread(filename, ...)
%
% See also:
%   imread
%   exrread
%   raw2tiff
%
% ----------
% Jean-Francois Lalonde

[~,~,ext] = fileparts(filename);

switch lower(ext)
    case '.hdr'
        % radiance HDR format
        im = hdrread(filename, varargin{:});
        
    case '.exr'
        % openEXR format
        im = exrread(filename);
        
    case {'.nef', '.cr2'}       
        % First, convert to tiff
        tiffFile = raw2tiff(filename);
        
        % Read the generated tiff file
        im = im2double(imread(tiffFile));
        
        % Clean up 
        delete(tiffFile);
        
    otherwise
        % other image formats supported by imread
        im = im2double(imread(filename, varargin{:}));
        
end