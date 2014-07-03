function ext = hdr_imwrite(im, filename, varargin)
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
ext = lower(ext);

switch ext
    case '.hdr'
        % radiance HDR format
        hdrwrite(im, filename, varargin{:});
        
    case '.exr'
        % openEXR format --> pfstools
%         exrwrite(im, filename);
        pfs_write_image(filename, im);
        
    case {'.tif', '.tiff'}
        % 16-bit tiff
        imwrite(im2uint16(im), filename, varargin{:});
        
    case '.png'
        % 16-bit png
        imwrite(im2uint16(im), filename, 'bitdepth', 16, varargin{:});
        
    otherwise
        % other image formats supported by imwrite
        imwrite(im, filename, varargin{:});
        
end