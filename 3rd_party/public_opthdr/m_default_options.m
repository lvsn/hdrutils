function opts = m_default_options(dsname)

opts.vlab = 'sample_v';
opts.blab = 'sample_b';
opts.enable_prnu = false;
opts.enable_dcnu = false;
opts.ssf = 1; % spatial subsampling factor (test only)
opts.nstdev = 2; % smoothing factor (in stdevs)
opts.dsname = dsname;
