function Ir = x_load_tiff(fn, s)
  
%  [R G B] = pfs_read_rgb(fn); % Octave
%  I = cat(3, R, G, B); % Octave

  I = imread(fn); % Matlab
  
  Ir = x_image_downscale(I, s);
