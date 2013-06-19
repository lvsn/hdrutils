function [v b] = m_load_sample_exposures(basedir, vlab, blab, sf)

if ~exist('sf', 'var')
    sf = 1; % downsampling factor
end

vpath = strcat(basedir, '/', vlab, '/*.tif');
disp(sprintf('  listing %s...', vpath));
vfns = dir(vpath);
assert(~isempty(vfns));

bpath = strcat(basedir, '/', blab, '/*.tif');
disp(sprintf('  listing %s...', bpath));
bfns = dir(bpath);
O_use_dummy_b = isempty(bfns);

nt = length(vfns);
v = cell(nt, 1);
b = cell(nt, 1);
j = 0;
for i=1:nt
  j = j+1;
  
  vfn = strcat(basedir, '/', vlab, '/', vfns(i).name);
  %disp(sprintf('loading %s', vfn))%,fflush(stdout);
  v{j} = uint16(x_load_tiff(vfn, sf));
  
  if O_use_dummy_b
        b{j} = zeros(size(v{j}), 'uint16');
  else
      %disp(sprintf('loading %s', bfn))%,fflush(stdout);
      bfn = strcat(basedir, '/', blab, '/', bfns(i).name);
      b{j} = uint16(x_load_tiff(bfn, sf));
  end
end