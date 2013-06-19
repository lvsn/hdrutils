function recon = E_smooth(recon, nstdev)

if ~exist('nstdev', 'var') || isempty(nstdev); nstdev = 3; end

vvv = recon.X.varmuhat;
vvv(~isfinite(vvv)) = max(vvv(:));
vvv = imfilter(vvv, fspecial('gaussian'), 'same');
yyy = recon.X.muhat;
yyy(~isfinite(yyy)) = max(yyy(:));


%% denoising parameters
k_support = 17; % PARAMETER: spatial kernel support
k_bw_space = 1; % PARAMETER: spatial kernel bandwidth
k_bw_range_stdev = sqrt(vvv); % range kernel dynamic bandwith

%% smooth using stdev bandwidth
disp(sprintf('smoothing using %d*stdev', nstdev))
recon.X.muhatsm = bilateralfilter(yyy, [], k_support, k_bw_space, k_bw_range_stdev*nstdev);
disp('  done')

