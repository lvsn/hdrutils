% Reconstructs an HDR image from images taken with a camera 
% Canon Powershot S5, using the method reported in the paper:
%
% Optimal HDR reconstruction with linear digital cameras
% M. Granados, B. Ajdin, M. Wand, C. Theobalt, H.-P. Seidel, H. P. A. Lensch
% In Proc. IEEE Conf. Comp. Vis. Pat. Rec. (CVPR), 
%   June 13-18, 2010, San Francisco, USA

% for converting cr2 files to 16bit tiff please use:
% dcraw -v -c -D -h -4 -T filename.cr2 > filename.tif
%   tested with dcraw 9.10

opts = m_default_options('S5test2v2');
opts.confbase = '../Datasets/CanonS5/calib'; % containing cam.conf, aj.tif
opts.basedir = '../Datasets/CanonS5'; % containing sample_v/*.tif, sample_b/*.tif
opts.ssf = 1; % spatial subsampling factor (set to 1 for the full result)
opts.enable_prnu = true;
opts.enable_dcnu = true;

[recon cam] = opthdr(opts);

mkdir('results');
hdrwrite(recon.X.muhat, strcat('results/', opts.dsname, '_muhat.hdr'));
hdrwrite(recon.X.muhatsm, strcat('results/', opts.dsname, '_muhat_smoothed.hdr'));
hdrwrite(sqrt(recon.X.varmuhat), strcat('results/', opts.dsname, '_stdmuhat.hdr'));