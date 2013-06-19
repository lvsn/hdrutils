function [xvar dvar] = xvari(cam, vvar, bvar,  t, use_prnu, use_dcnu)
  a = 1;
  if(use_prnu); a = cam.A.a0; end
  if(~use_dcnu); bvar = zeros(size(vvar), 'single'); end
  
  % photograph
  xvar = ((vvar + bvar) ./ ... % TODO: why not  + 2*sigma_R^2
		  (t^2 * a.^2 .* cam.g.^2));
      
  % dark frame
  dvar = (bvar + single(cam.R.var) ./ ...
		  (t^2 * cam.g.^2));

  assert(use_dcnu || all(dvar(:) == single(cam.R.var)./(t^2*cam.g^2)));      
  
  %assert(all(isfinite(xvar(:)))); % marked inf for saturated values
  assert(all((xvar(:) >= 0)));
  %assert(all(isfinite(dvar(:)))); % marked inf for saturated values
  assert(all((dvar(:) >= 0)));
  
