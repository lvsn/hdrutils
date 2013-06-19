function Ir = x_image_downscale(I, s)
  Ir = I(1:s:end, 1:s:end, :);

