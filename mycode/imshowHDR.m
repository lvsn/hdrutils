function varargout = imshowHDR(img, varargin)
% Displays an image, with keyboard shortcuts to in(de)crease the exposure.
% 
%   <h> = imshowHDR(img, ...)
% 
% Press:
%   cmd-] to increase the exposure
%   cmd-[ to decrease the exposure
%   cmd-0 to reset the exposure
%
% Note: Use 'ctrl' instead of 'cmd' on Linux/Windows computers. 
%
% ----------
% Jean-Francois Lalonde


h = imshow(img, varargin{:});

if nargout == 1
    varargout{1} = h;
end

axesHandle = get(h, 'Parent');
figHandle = get(axesHandle, 'Parent');

% Store info in the axes 'UserData' field
axesData.imgScaleFactor = 1;
axesData.img = img;
axesData.imgHandle = h;
axesData.name = tempname;
set(axesHandle, 'UserData', axesData);

figData = get(figHandle, 'UserData');
if isfield(figData, 'imshowHDRData')
    % see if we already have a callback for these axes
    if ~figData.imshowHDRData.callbacks.isKey(axesData.name)
        id = iptaddcallback(figHandle, 'WindowKeyPressFcn', @keyPressFcn);
        figData.imshowHDRData.callbacks(axesData.name) = id;        
    end
else
    id = iptaddcallback(figHandle, 'WindowKeyPressFcn', @keyPressFcn);
    figData.imshowHDRData.callbacks = containers.Map(axesData.name, id);
end

set(figHandle, 'UserData', figData);

    function keyPressFcn(figHandle, event)
        currAxes = get(figHandle, 'CurrentAxes');
        if currAxes == axesHandle
            if any(strcmp(event.Modifier, 'command')) || ...
                    any(strcmp(event.Modifier, 'control'))
                if any(strcmp(event.Modifier, 'control'))
                    event.Character = event.Key;
                end
                
                % 'command' or 'control' key is held down
                if any(strcmp(event.Modifier, 'shift'))
                    % 'shift' key is also held down
                    % --> loop over all axes
                    allAxes = findall(figHandle, 'Type', 'axes');
                    for i_ax = 1:length(allAxes)
                        doHDRAction(allAxes(i_ax), event.Character);
                    end
                    
                else
                    doHDRAction(currAxes, event.Character);
                end
            end
        end
    end

    function doHDRAction(curAxesHandle, character)
        % Re-scales display according to the user input
        axesData = get(curAxesHandle, 'UserData');
        
        if ~isempty(axesData)
            switch character
                case {'[', 'leftbracket', '8'}
                    % decrease exposure
                    axesData.imgScaleFactor = axesData.imgScaleFactor/1.5;
                    set(curAxesHandle, 'UserData', axesData);
                    updateDisplay(axesData);
                    
                case {']', 'rightbracket', '9'}
                    % increase exposure
                    axesData.imgScaleFactor = axesData.imgScaleFactor*1.5;
                    set(curAxesHandle, 'UserData', axesData);
                    updateDisplay(axesData);
                    
                case '0'
                    % reset exposure
                    axesData.imgScaleFactor = 1;
                    set(curAxesHandle, 'UserData', axesData);
                    updateDisplay(axesData);
            end
        end
    end

    function updateDisplay(axesData)
        set(axesData.imgHandle, ...
            'CData', min(max(axesData.img*axesData.imgScaleFactor, 0), 1));
    end

end
