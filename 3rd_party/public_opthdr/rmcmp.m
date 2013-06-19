function score = rmcmp(I0mean, I0var, Ihat)

% correlation coefficient
%cc = corrcoef(I0mean, (I0mean - Ihat));
%score = cc(2);

% average normalized error
%score = nanmean(sqrt((I0mean - Ihat).^2./I0var));
score = nanmean((I0mean - Ihat).^2./I0var);
