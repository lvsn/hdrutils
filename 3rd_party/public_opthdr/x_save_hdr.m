function x_save_hdr(x, c, xminmax, cm, basename, name)
disp(name);
x(~isfinite(x)) = max(x(:));
imname = strcat(basename, '_', name);
hdrwrite(max(1,x), strcat(imname, '.hdr'));
imwrite(im2hot(log10(max(1,x(:,:,c))), log10(double(xminmax)), cm), strcat(imname, '.ppm'));
