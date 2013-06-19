function [PSNR MSE] = x_psnr(I, K)

s = isfinite(I(:)) & isfinite(K(:));
MSE = sum((I(s)-K(s)).^2)/sum(s);
%MSE = mad(I(s)-K(s))^2;
%disp(sprintf('MSE = %f', MSE));
MAXI = max(I(s));
PSNR = 10*log10(MAXI^2/MSE);