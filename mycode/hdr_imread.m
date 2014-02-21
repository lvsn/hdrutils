function im = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats.
%
%   im = hdr_imread(filename, ...)
%
% Additional options can be used as optional inputs to imread. In addition,
% it also supports:
%   - 'autoRotate' [true]: rotate according to the EXIF information
%   - 'fullRaw' [false]: 
%   
%
% See also:
%   imread
%   exrread
%   raw2tiff
%
% ----------
% Jean-Francois Lalonde

[~,~,ext] = fileparts(filename);

% check if we've passed the 'fullRaw' option. Strip it out if yes.
fullRawInd = find(strcmp(varargin, 'fullRaw'));
fullRawVal = false;
if ~isempty(fullRawInd)
    fullRawVal = varargin{fullRawInd+1};
end
varargin(fullRawInd:fullRawInd+1) = [];

% check if we've passed the 'autoRotate' option. Strip if out if yes.
autoRotateInd = find(strcmp(varargin, 'autoRotate'));
autoRotate = true;
if ~isempty(autoRotateInd)
    autoRotate = varargin{autoRotateInd+1};
end
varargin(autoRotateInd:autoRotateInd+1) = [];

if fullRawVal
    switch lower(ext)
        case {'.nef', '.cr2'}
        otherwise
            warning('hdr_imread:fullRaw', ...
                'fullRaw option not used with extension %s', ext);
    end
end

switch lower(ext)
    case '.hdr'
        % radiance HDR format
        im = hdrread(filename, varargin{:});
        
    case '.exr'
        % openEXR format
        im = exrread(filename);
        
    case {'.nef', '.cr2'}
        % First, convert to tiff
        tiffFile = raw2tiff(filename, 'fullRaw', fullRawVal);
        
        % Read the generated tiff file
        im = hdr_imread(tiffFile);
        
        % Make sure we get rid of the alpha channel
        if size(im, 3) == 4
            im = im(:,:,1:3);
        end
        
        im = rot(im, filename);
        
        % Clean up
        delete(tiffFile);
        
    otherwise
        % other image formats supported by imread
        im = im2double(imreadAutoRot(filename, varargin{:}));
        
end

    function im = imreadAutoRot(filename, varargin)
        % Handle auto-rotation in JPEG (from EXIF tag).
        %
        % ----------
        % Jianxiong Xiao
        % Reference: http://www.impulseadventure.com/photo/exif-orientation.html
        
        im = imread(filename, varargin{:});
        im = rot(im, filename);
    end

    function im = rot(im, filename)
        if ~autoRotate
            return;
        end
        info = imfinfo(filename);
        if ~isempty(info) && isfield(info, 'Orientation')
            switch info(1).Orientation
                case 1
                    
                case 2
                    im = im(:,end:-1:1,:);
                case 3
                    im = imrotate(im,180);
                    % think that's a bug! should just be rotated
%                     im = im(:,end:-1:1,:);
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