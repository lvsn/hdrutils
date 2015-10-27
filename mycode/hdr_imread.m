function [im, rotFcn, alpha, depth] = hdr_imread(filename, varargin)
% Wrapper for imread that supports HDR formats.
%
%   [im, rotFcn] = hdr_imread(filename, ...)
%
% Additional options can be used as optional inputs to imread. In addition,
% it also supports:
%   - 'autoRotate' [true]: rotate according to the EXIF information
%   - 'doCleanup' [true]: cleans temporary files (necessary when loading
%   CR2's)
%   - 'EV' []: defines target EV for re-exposure
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

% check if we've passed the following options. Strip them out if so.
[fullRaw, varargin] = lookforVarargin('fullRaw', false, varargin{:});
[autoRotate, varargin] = lookforVarargin('autoRotate', true, varargin{:});
[doCleanup, varargin] = lookforVarargin('doCleanup', true, varargin{:});
[EV, varargin] = lookforVarargin('EV', [], varargin{:});

% default return values
alpha = [];
depth = [];
rotFcn = @(x) x;

    function [flag, varargin] = lookforVarargin(flagName, flagDefault, varargin)
        flag = flagDefault;
        flagInd = find(strcmp(varargin, flagName));
        if ~isempty(flagInd)
            flag = varargin{flagInd+1};
        end
        varargin(flagInd:flagInd+1) = [];
    end

if fullRaw
    switch lower(ext)
        case {'.nef', '.cr2'}
        otherwise
            warning('hdr_imread:fullRaw', ...
                'fullRaw option not used with extension %s', ext);
    end
end

% if autoRotate
%     switch lower(ext)
%         case {'.hdr', '.exr'}
%             warning('hdr_imread:autoRotate', ...
%                 'autoRotate option not used with extension %s', ext);
%     end
% end

switch lower(ext)
    case '.hdr'
        % radiance HDR format
        im = hdrread(filename, varargin{:});
        
    case '.exr'
        % openEXR format --> use pfstools
        try
            [im, alpha, depth] = pfs_read_image(filename);
            alpha = im2double(alpha);

        catch
            try
                im = pfs_read_image(filename);
            catch
                % looks like we don't have pfstools installed... 
                im = exrread(filename);
            end
        end
        im = im2double(im);
        
    case {'.nef', '.cr2'}
        % First, convert to tiff
        tiffFile = raw2tiff(filename, 'fullRaw', fullRaw);
        
        % Read the generated tiff file
        im = hdr_imread(tiffFile);
        
        % Make sure we get rid of the alpha channel
        if size(im, 3) > 3
            im = im(:,:,1:3);
        end
        
        % don't rotate
        rotFcn = @(x) x; 
                
        % Clean up
        if doCleanup
            delete(tiffFile);
        end
        
    case '.png'
        [im, ~, alpha] = imread(filename);
        im = im2double(im);
        alpha = im2double(alpha);
        
    otherwise
        % other image formats supported by imread
        [im, rotFcn] = imreadAutoRot(filename, varargin{:});
        im = im2double(im);
        
end

% check if we need to re-expose
if ~isempty(EV)
    curEV = evFromExif(filename);
    im = reExposeImage(im, curEV, EV);
end

    function [im, rotFcn] = imreadAutoRot(filename, varargin)
        % Handle auto-rotation in JPEG (from EXIF tag).
        %
        % ----------
        % Jianxiong Xiao
        % Reference: http://www.impulseadventure.com/photo/exif-orientation.html
        
        im = imread(filename, varargin{:});
        [im, rotFcn] = rotFromExif(im, filename);
    end

    function [im, rotFcn] = rotFromExif(im, filename)
        % don't do anything
        rotFcn = @(x) x;
        
        if ~autoRotate
            return;
        end
        info = imfinfo(filename);
        if ~isempty(info) && isfield(info, 'Orientation')
            rotFcn = @(i) rot(i, info(1).Orientation);
            im = rotFcn(im);
        end
    end

    function im = rot(im, orientation)
        switch orientation
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