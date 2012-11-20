function im = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats
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
        
    otherwise
        % other image formats supported by imread
        im = im2double(imread(filename, varargin{:}));
        
end