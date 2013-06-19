function [Xmuhat Xvarmuhat Dmuhat Dvarmuhat Xns] = ...
    m_reconstruct_irradiance_from_samples(cam, t, ...
    v, b, ...         % required by muhat
    prnu, dcnu)

nt = length(t);
Xivarhat = cell(nt, 1);
Divarhat = cell(nt, 1);

% initialize irradiance variance
for i=1:nt
    Xivarhat{i} = (max(0, cam.g*single(v{i})-cam.R.mu) + cam.R.var)/(cam.g^2*t(i)^2);
    Divarhat{i} = (max(0, cam.g*single(b{i})-cam.R.mu) + cam.R.var)/(cam.g^2*t(i)^2);
end

Xmeansnrhat = -Inf;
it = 0;
while(true)
    it = it + 1;
    
    % recover the irradiance mean estimate and variance
    [Xmuhat Xvarmuhat Dmuhat  Dvarmuhat Xns] = ...
        xmu2s(cam, v, Xivarhat, b, Divarhat, t, prnu, dcnu);
    
    % compute the estimation SNR
    Xsnrhat = 20*log10(Xmuhat ./ sqrt(Xvarmuhat));
    Xmeansnrhatp = Xmeansnrhat;
    Xmeansnrhat = min(Xsnrhat(isfinite(Xvarmuhat))); % maximize minimum SNR
    assert(isfinite(Xmeansnrhat));
    
    % debug snr improvement vs maximum snr
    disp(sprintf('  It. %d: curr. min. SNR = %f, curr/prev=%f', it, Xmeansnrhat, Xmeansnrhat/Xmeansnrhatp))%, fflush(stdout);
    
    if((it >= 5) && (abs(1-Xmeansnrhat/Xmeansnrhatp) < 1e-8) || (it>10))
        break;
    end
    
    % recover the irradiance  variance perexptime
    for i=1:nt
        [txivarhat tdivarhat] = ...
            vvari(cam, Xmuhat, Dmuhat, t(i), prnu, dcnu);
               
        Xivarhat{i} = txivarhat;
        Divarhat{i} = tdivarhat;
    end
end

disp('done.')
