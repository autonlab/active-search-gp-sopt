function [hits,selected,exploit_explore] = as_sopt_tt( ...
   A0, C0, y, opts)
%%% [hits,selected] = AS_sopt(A,alpha,labels,options) 
%%% Input: 
%%%   A0: RAW adajacency matrix, C0: inv(Laplacian) -- optional by []
%%%   labels: n-by-1 vector. True labels of data points. 1: target, 0: non-target.
%%%   options: a structure specifying values for the following algorithmic options:
%%%   logger: optional
%%%
%%% Output:
%%%   hits: a vector of cumulative counts of discovered target points
%%%   selected: a vector of indices of points selected by the algorithm 

if ~exist('log4m.m', 'file')
  addpath('../external_library/log4m/')
end

logger = log4m.getLogger();
logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Entering function ...');

%% initialize inputs and outputs

p = inputParser;

p.addParameter( 'alpha',        Inf);          % default to pure exploration
p.addParameter( 'omega0',       0.01);         % default graph augmentation consistent with valko et al. 14

p.addParameter( 'mu0',          0.05);         % prior positive rate
p.addParameter( 'obs_sigma',    'no_default'); % observation noise
p.addParameter( 'k', Inf);                     % optional max tt clip

p.addParameter( 'T',            10);           % termination time
p.addParameter( 'start_points', []);           % optional start points


%%% parse input options

p.parse(opts)

remainingResults = p.Results;

[alpha,        remainingResults] = popfield(remainingResults, 'alpha');
[omega0,       remainingResults] = popfield(remainingResults, 'omega0');
[mu0,          remainingResults] = popfield(remainingResults, 'mu0');
[obs_sigma,    remainingResults] = popfield(remainingResults, 'obs_sigma');
[k,            remainingResults] = popfield(remainingResults, 'k');
[T,            remainingResults] = popfield(remainingResults, 'T');
[start_points, remainingResults] = popfield(remainingResults, 'start_points');

assert(isempty(fieldnames(remainingResults)));

logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), evalc('p.Results'));

%%% verify inputs
if ~isempty(C0)
  graph_representation = 'cov';
  n = size(C0, 1);
  assert(issymmetric(C0));
else
  graph_representation = 'adj';
  n = size(A0, 1);
  assert(issymmetric(A0));
end

assert(n>1);
assert(size(y, 1) == n);

if T > n-1
  T = n-1;
  logger.debug(sprintf('PID:%d - %s', feature('getpid'), mfilename), sprintf('shrink input T to %d', T));
end

logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), ...
  sprintf('graph_representation=%s, n=%d, T=%d', graph_representation, n, T));

%%% initialize outputs
hits            = nan(1, T);
selected        = nan(1, T);
exploit_explore = nan(2, T);

%% Algorithm 1
logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Starting algorithm 1 ...');

%%%

switch lower(graph_representation)
  case 'adj'
    logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Building prior cov ...');
    L0 = diag(sum(A0, 2) + omega0) - A0;
    C0 = inv(full(L0));
  case 'cov'
    logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Use given prior cov, ignore omega0!');
    C0 = full(C0);
  otherwise
    logger.error(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'input error: graph representation not recognized');
    error(-1,'input error');
end

logger.debug(sprintf('PID:%d - %s', feature('getpid'), mfilename), ['head C0', evalc('C0(1:5,1:5)')]);

%%%
logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Assigning warm starts ...');

t0 = length(start_points);

last_ind       = start_points;
selected(1:t0) = last_ind;
hits(1:t0)     = y(last_ind);

%%% variables that will be updated immediately
mut = mu0 * ones(n,1);
Ct = C0;

%%% Main loop

logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Entering main loop..');
for t = t0:(T-1)
    
  %%% update to posterior
  if ~isempty(last_ind)
    X = sparse(1:length(last_ind), last_ind(:)', 1, length(last_ind), length(Ct));
    [mut, ~, Ct] = Gaussian_posterior(mut, [], Ct, X, y(last_ind, :), obs_sigma);
  end
    
  %%% sigma-optimality acquisition
  sopt_noiseless = sum(Ct, 2) ./ sqrt(diag(Ct));
  tt_clip        = k*sqrt(diag(Ct));
  
  [score_exploration, clip_or_sopt] = min([tt_clip, sopt_noiseless], [], 2);  
  score = mut + alpha * score_exploration;  
  score(selected(1:t)) = nan; % without replacement
  
  % select and update
  [best_score, last_ind] = max(score);

  selected(t+1) = last_ind;
  hits(t+1) = sum(y(selected(1:(t+1))));
    
  exploit_explore(:, t+1) = [sum(mut >= mut(last_ind)); ...
    sum(score_exploration >= score_exploration(last_ind))];
  
  logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), ['[' num2str(t+1) ']' ...
    ', #' num2str(last_ind) ...
    ', hits: ' num2str(hits(t+1)) '/' num2str(t+1) ...
    ', E[score]= ' num2str(best_score) ...
    ', exploit_explore: ' num2str(exploit_explore(:,t+1)') ...
    ', %sopt= ' num2str(mean(clip_or_sopt==2))]);
  
end


logger.info(sprintf('PID:%d - %s', feature('getpid'), mfilename), 'Leaving function ...');
