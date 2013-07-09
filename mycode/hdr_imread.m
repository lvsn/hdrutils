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
        % check if we've passed the 'fullRaw' option. Strip it out if yes.
        fullRawInd = find(strcmp(varargin, 'fullRaw'));
        fullRawVal = false;
        if ~isempty(fullRawInd)
            fullRawVal = varargin{fullRawInd+1};
        end
        
        % First, convert to tiff
        tiffFile = raw2tiff(filename, 'fullRaw', fullRawVal);
        
        % Read the generated tiff file
        im = hdr_imread(tiffFile);
        
        % Make sure we get rid of the alpha channel
        if size(im, 3) == 4
            im = im(:,:,1:3);
        end
        
        % Clean up
        delete(tiffFile);
        
    otherwise
        % other image formats supported by imread
        im = im2double(imreadAutoRot(filename, varargin{:}));
        
end

    function im = imreadAutoRot(filename)
        % Handle auto-rotation in JPEG (from EXIF tag).
        %
        % ----------
        % Jianxiong Xiao
        % Reference: http://www.impulseadventure.com/photo/exif-orientation.html
        
        im = imread(filename);
        
        info = imfinfo(filename);
        if ~isempty(info)
            if isfield(info, 'Orientation')
                switch info.Orientation
                    case 1
                        
                    case 2
                        im = im(:,end:-1:1,:);
                    case 3
                        im = imrotate(im,180);
                        im = im(:,end:-1:1,:);
                    case 4
                        im = im(:,end:-1:1,:);
                        
                    case 6
                        im = imrotate(im,-90);
                    case 5
                        im = im(:,end:-1:1,:);
                        im = imrotate(im,-90);
                        
                    case 8
                        im = imrotate(im,90);
                    case 7
                        im = imrotate(im,90);
                        im = im(:,end:-1:1,:);
                end
            end
        end
    end
end