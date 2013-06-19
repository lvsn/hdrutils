function recon = C_reconstruct(t, cam, opts)

recon.t = t;

% -----------------
% read sample exposures

disp('reading  exposures...');
[recon.V.v recon.B.b] = m_load_sample_exposures(opts.basedir, opts.vlab, opts.blab, opts.ssf);
assert(length(recon.V.v) == length(recon.t));
assert(length(recon.B.b) == length(recon.t));

% -----------------
% reconstruct the irradiance map using our method
disp('reconstructing using our method...')

[recon.X.muhat recon.X.varmuhat recon.D.muhat recon.D.varmuhat recon.X.nshat] = ...
    m_reconstruct_irradiance_from_samples(cam, recon.t, ...
    recon.V.v, recon.B.b, ...
    opts.enable_prnu, opts.enable_dcnu);
