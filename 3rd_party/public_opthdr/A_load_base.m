function [cam, t] = A_load_base(opts)

% -----------------
% read camera parameters
disp('reading camera parameters...');
cam = m_load_cam(opts.confbase, opts.enable_prnu, opts.ssf);

% -----------------
% read exposure times
disp('reading exposure times...');
t = m_load_et(opts.basedir, opts.vlab);

