function M_img_smoothed = blf(M_img, M_img_subregion, s_kernel_size, s_space_bw, M_range_bw)

s_ks = (s_kernel_size-1)/2;
M_space_kernel = fspecial('gaussian', s_kernel_size, s_space_bw);

[sy sx sc] = size(M_img);
M_img_smoothed = zeros(size(M_img), class(M_img));
if isempty(M_img_subregion)
    V_rx = 1:sx;
    V_ry = 1:sy;
    V_rc = 1:sc;
else
    V_ry = M_img_subregion(1,1):M_img_subregion(1,2);
    V_rx = M_img_subregion(2,1):M_img_subregion(2,2);
    V_rc = M_img_subregion(3,1):M_img_subregion(3,2);
end
for c=V_rc
  for y=V_ry
      x_progress(y, length(V_ry), sprintf('applying bilateral filter, channel %d, row', c));
	for x=V_rx
	  % select spatial support
	  yr = (int16(y)-s_ks):(int16(y)+s_ks);
	  yr(yr<1) = abs(yr(yr<1))+1;
	  yr(yr>sy) = int16(2*sy) - yr(yr>sy) + 1;

	  xr = (int16(x)-s_ks):(int16(x)+s_ks);
	  xr(xr<1) = abs(xr(xr<1))+1;
	  xr(xr>sx) = int16(2*sx) - xr(xr>sx) + 1;

	  % compute range kernel
	  s_range_bw2 = M_range_bw(y,x,c)^2;
	  M_range_kernel = exp(-(M_img(yr,xr,c) - M_img(y,x,c)).^2./(2*s_range_bw2));

	  % compute compound kernel
	  k = M_space_kernel .* M_range_kernel;

	  % apply kernel
      yk = M_img(yr, xr, c) .* k;
	  M_img_smoothed(y,x,c) = sum(yk(:)) / sum(k(:));
	end
	%fprintf(1, 'row=%d/%d\n', y, sy);
  end
end
