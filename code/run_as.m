addpath ../external_library/log4m/

%%% choose a log location
if ~exist('logDir','var'), logDir = '~/tmp/as_logs'; end
if ~exist('cacheDir','var'), cacheDir = '~/tmp/as_cache'; end

if ~exist(logDir,'dir'), 
  fprintf(2, 'creating temporary directory %s\n', logDir);
  mkdir(logDir); 
end

if ~exist(cacheDir,'dir'), 
  fprintf(2, 'creating temporary directory %s\n', cacheDir);
  mkdir(cacheDir); 
end

save_cache = true;

%%% choose a dataset
% dataset = 'toy';
% dataset = 'populated_places_5000';
% dataset = 'enron_graph';
if ~exist('dataset', 'var'), dataset = 'toy'; end

%%% choose an algorithm
% algorithm = @as_sopt_tt;
% algorithm = @as_gp_select;
% algorithm = @as_sopt_vanilla;
if ~exist('algorithm', 'var'), algorithm = @as_sopt_vanilla; end

%%% for synchronization among multiple matlab sessions
if ~exist('skipRunIfLogExists','var'), skipRunIfLogExists = false; end

%% summarize
data_alg_ID = sprintf('Data_%s_Alg_%s', dataset, func2str(algorithm));

logger = log4m.getLogger(fullfile(logDir, [data_alg_ID, '.log']));
logger.setFilename(fullfile(logDir, [data_alg_ID, '.log']));
logger.setLogLevel(log4m.ALL);
logger.info(logPrompt(mfilename), '===== starting =====');


logger.info(logPrompt(mfilename), ...
  sprintf('%s, skipRunIfLogExists=%d', ...
  data_alg_ID, skipRunIfLogExists));

%% parameter choices from script
[A,y,choices_per_param] = configure_param_choices(dataset, algorithm);
param_choices = product_options(choices_per_param);

logger.info(logPrompt(mfilename), evalc('choices_per_param'));
logger.info(logPrompt(mfilename), sprintf('length(param_choices)=%d',length(param_choices)));

%% precompute prior covariance

if length(choices_per_param.omega0) == 1
  [C, cache_hit, cachePath] = compute_or_load_cov(dataset, A, choices_per_param.omega0, cacheDir);
  
  if ~cache_hit && save_cache
    logger.info(logPrompt(mfilename), sprintf('saving cache at %s ...', cachePath));
    save(cachePath, 'C', '-v7.3');
  end
else
  logger.info(logPrompt(mfilename), 'multiple omega0, L may be different per experiment!');
  C = [];
end



%% run algorithm

% for i = 1:numel(param_choices)
gcp
parfor i = 1:numel(param_choices)
  % pick param
  param = param_choices(i);
  
  logID = sprintf('%s_%06d.log', data_alg_ID, i);

  if skipRunIfLogExists && exist(fullfile(logDir, logID), 'file')
    % check sync flags
    warning('log exists, skip %s', logID);
    continue;

  else
    % pick log location
    
    logger = log4m.getLogger(fullfile(logDir, logID));
    logger.setFilename(fullfile(logDir, logID));
    logger.setLogLevel(log4m.ALL);
    
    [hits(:,i), selected(:,i)] = algorithm(A, C, y, param);
  end
end

%% pick top 15%
auc = sum(hits, 1);
[~, ind_sort_auc] = sort(auc, 'descend');
hits_top15percent = mean(hits(:, ind_sort_auc(1:ceil(.15*size(hits, 2)))), 2);

plot(hits_top15percent ./ sum(y));

clear C L A
save(data_alg_ID);
dlmwrite(sprintf('%s_selected.txt', data_alg_ID), selected, 'precision','% 8d')
