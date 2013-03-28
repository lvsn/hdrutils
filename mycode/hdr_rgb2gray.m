function img = hdr_rgb2gray(img)
% HDR version for rgb2gray
%
%   img = hdr_rgb2gray(img)
%
% See also:
%   rgb2gray
%   
% ----------
% Jean-Francois Lalonde


if ndims(img) == 3 && size(img,3) == 3
    img = 0.299 * img(:,:,1) + ...
        0.587 * img(:,:,2) + ...
        0.114 * img(:,:,3);
    
elseif size(img,2) == 3
    img = 0.299 * img(:,1) + ...
        0.587 * img(:,2) + ...
        0.114 * img(:,3);
else
    error('hdr_rgb2gray:input', 'Unsupported input');
    
end
