function t = m_load_et(basedir, vlab)
% read exposure times
etfn = strcat(basedir, '/', vlab, '/exposure_times');
disp(sprintf('  loading %s...', etfn));
etf = fopen(etfn, 'r');
t = fscanf(etf, '%f');
fclose(etf);
disp(sprintf('  inverting exposures times'));
t = 1./t;
