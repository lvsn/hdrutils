function [recon cam] = opthdr(opts)

[cam t] = A_load_base(opts);
recon = C_reconstruct(t, cam, opts);

if ~all(isfinite(recon.X.muhat(:)))
    warning('OptHdr:SomePixelsAlwaysSaturated', 'Some pixels are saturated in every frame, setting their value to the maximum irradiance seen');
    Xfinite = isfinite(recon.X.muhat);
    recon.X.muhat(~Xfinite) = max(recon.X.muhat(Xfinite));
    recon.X.varmuhat(~Xfinite) = max(recon.X.varmuhat(Xfinite));
end

recon = E_smooth(recon);