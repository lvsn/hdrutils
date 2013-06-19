function x_progress(i, n, msg0)
global vdbg;

msg = sprintf('%s: %d/%d', msg0, i, n);
if ~vdbg
  disp(msg)
  return
end
msg = strrep(msg, '_', '\_');

persistent h;
if i == 1
    if ishandle(h)
        close(h);
    end
    h = [];
end
if isempty(h)
  h = waitbar(i/n, msg);
else
  waitbar(i/n, h, msg);
end
if i == n
  close(h);
  h = [];
end
  
%disp(msg);
