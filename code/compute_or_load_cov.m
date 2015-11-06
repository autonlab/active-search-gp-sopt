function [C, cache_hit, cachePath] = compute_or_load_cov(dataset, A, omega0, cacheDir)
  logger = log4m.getLogger();

  if nargin<4
    cacheDir = '~/tmp/as_cache';
  end

  
  cachePath = fullfile(cacheDir, sprintf('cov_%s_%f.mat', dataset, omega0));
  
  if exist(cachePath, 'file')
    cache_hit = true;
    
    logger.info(logPrompt(mfilename), sprintf('Loading from %s ...', cachePath));

    load(cachePath, 'C');
    logger.info(logPrompt(mfilename), 'load done.');
  else
    cache_hit = false;

    logger.info(logPrompt(mfilename), 'computing cov ...');

    L = diag(sum(A, 2) + omega0) - A;
    L = full(L);
    C = inv(L);
  end
