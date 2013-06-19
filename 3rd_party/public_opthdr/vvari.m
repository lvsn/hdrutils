function [xvar dvar] = vvari(cam, X, D, t, use_prnu, use_dcnu)
  a = 1;
  if(use_prnu); a = cam.A.a0; end
  assert(use_dcnu || all(D(:) == 0));
  
  % photograph
  Vvar = cam.g.^2 .* t .* max(0, a.*X + D) + cam.R.var;
  
  % dark frame
  Bvar = cam.g.^2 .* t .* max(0,        D) + cam.R.var;
  
  [xvar dvar] = xvari(cam, Vvar, Bvar, t, use_prnu, use_dcnu);
