function cam = m_load_cam(confbase, enable_prnu, ssf)

camfn = strcat(confbase, '/cam.conf');
disp(sprintf('  loading %s...', camfn));
camf = fopen(camfn, 'r');

% read gain factor, readout mean and variance, and saturation value
%for tc=1:3 % Matlab
%  [cam.g3(tc) cam.R.mu3(tc) cam.R.var3(tc) cam.vsat3(tc)] = fscanf(camf, '%f %f %f %d', 'C'); % Matlab
%end % Matlab
cam.m = fscanf(camf, '%f %f %f %d\n', [4 3])'; % Octave

% read flat filed and gain per pixel image filenames
cam.fffn = fgetl(camf); % Octave
%disp(strcat('  fffn=', cam.fffn));
cam.ajfn = fgetl(camf); % Octave
%disp(strcat('  ajfn=', cam.ajfn));
fclose(camf);

cam.g3 = cam.m(:,1);     % camera gain per channel
cam.R.mu3 = cam.m(:,2);  % mean readout noise
cam.R.var3 = cam.m(:,3); % variance readout noise
cam.vsat3 = uint16(cam.m(:,4));  % first saturated output value

cam.g = mean(cam.g3);
cam.R.mu = mean(cam.R.mu3);
cam.R.var = (cam.R.var3(1) + 2*cam.R.var3(2) + cam.R.var3(3)) / 3;
cam.vsat = max(cam.vsat3);
cam.vmax = cam.vsat;
cam.nv = cam.vmax+1;
cam.vmid = cam.vmax/2;

% vsatsafe is the largest output value for which we consider
% the measured variance is not affected by output value clamping
% and so can be used for estimated the measurement's SNR
cam.SFW = (double(cam.vsat) - cam.R.mu + 6*sqrt(cam.R.var))./cam.g;
assert(all(cam.vsat <= (cam.g.*cam.SFW + cam.R.mu - 6*sqrt(cam.R.var)+1e-8)));
cam.vsatvar = cam.g.*cam.SFW + cam.R.var;
cam.vsatsafe = uint16(double(cam.vsat) - 6*sqrt(cam.vsatvar));

% load gain per pixel
if enable_prnu
    ajfn = strcat(confbase, '/', cam.ajfn);
    disp(sprintf('  loading %s...', ajfn));
    cam.A.aj = x_load_tiff(ajfn, ssf); % aj: prnu + vignetting
    [cam.A.a0 cam.A.avig] = m_prnu_decompose(cam.A.aj); % a0: prnu, no vignetting
else
    cam.A.a0 = 1; % a: no prnu, no vignetting
end
