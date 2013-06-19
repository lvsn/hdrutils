% [xmu xmuvar dmu dmuvar ns] = xmu2s(cam, v, xvarhat, b, dvarhat, t, use_prnu, use_dcnu)
%
%   Estimates the irradiance map based on the observed values and the estimate of its variance.
%
%   $Id
%
%   Author: Miguel Granados, 2011
%
function [xmu xmuvar dmu dmuvar ns] = xmu2s(cam, v, xvarhat, b, dvarhat, t, use_prnu, use_dcnu)

  res = size(v{1});
  
  xmu = zeros(res, 'single');
  dmu = zeros(res, 'single');

  xmuvar = zeros(res, 'single');
  dmuvar = zeros(res, 'single');

  ns = zeros(res, 'uint16');
  txwsum = zeros(res, 'single');
  tdwsum = zeros(res, 'single');

  for i=1:length(t)
	[txmu tdmu] = xmui(cam, v{i}, b{i}, t(i), use_prnu, use_dcnu);
	% NOTE: there is no reason to suppress negative irradiance
	% and dark current estimates. Actually, suppressing them
	% automatically bias the weighted average estimate.
	txwi = 1 ./ xvarhat{i};
	tdwi = 1 ./ dvarhat{i};
	txwi = txwi .* (v{i}<cam.vsatsafe);
	tdwi = tdwi .* (b{i}<cam.vsatsafe);

	assert(~any(~isfinite(txwi(:))));
	assert(~any(~isfinite(tdwi(:))));
	assert(~any(txwi(:) < 0));
	assert(~any(tdwi(:) < 0));
	xmu = xmu + txwi.*txmu;
	dmu = dmu + tdwi.*tdmu;

	xmuvar = xmuvar + txwi; % unknown variance, assume M.L. estimate
	dmuvar = dmuvar + tdwi; % unknown variance, assume M.L. estimate
	%xmuvar += (txwi.^2).*xvar{i}; % measured variance
	%dmuvar += (tdwi.^2).*dvar{i}; % measured variance

	txwsum = txwsum + txwi;
	tdwsum = tdwsum + tdwi;
	ns = ns + uint16(v{i} < cam.vsatsafe);
  end
  xmu = xmu ./ txwsum;
  dmu = dmu ./ tdwsum;

  %xmuvar = xmuvar./txwsum.^2; % measured variance
  %dmuvar = dmuvar./tdwsum.^2; % measured variance
  
