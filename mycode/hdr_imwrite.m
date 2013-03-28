function hdr_imwrite(im, filename, varargin)
% Wrapper for imwrite that supports HDR formats
% 
%   hdr_imwrite(im, filename, ...)
%
% See also:
%   imwrite
%   
% ----------
% Jean-Francois Lalonde


[~,~,ext] = fileparts(filename);

switch lower(ext)
    case '.hdr'
        % radiance HDR format
        hdrwrite(im, filename, varargin{:});
        
    case '.exr'
        % openEXR format
        exrwrite(im, filename);
        
    case {'.tif', '.tiff'}
        % 16-bit tiff
        imwrite(im2uint16(im), filename, varargin{:});
        
    otherwise
        % other image formats supported by imwrite
        imwrite(im, filename, varargin{:});
        
end