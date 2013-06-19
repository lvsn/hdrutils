function [xi di] = xmui(cam, v, b, t, use_prnu, use_dcnu)
  a = 1;
  if(use_prnu); a = cam.A.a0; end
  if(~use_dcnu); b = ones(size(v), 'single')*cam.R.mu; end
  
  % photograph
  xi = ((single(v) - single(b)) ./ ...
		 (cam.g .* t .* a)); ...

  % Dark frame
  di = ((double(b) - single(cam.R.mu)) ./ ...
		 (cam.g * t));
     
 assert(use_dcnu || all(di(:) == 0));
