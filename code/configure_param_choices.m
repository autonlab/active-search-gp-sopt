function [A,y,choices_per_param] = configure_param_choices(dataset, algorithm, randomSeeds)

  switch dataset
    case 'toy'
      load('../data/toy','A','label_toy_bin');
      A = A;
      y = label_toy_bin';
      
      choices_per_param = struct( ...
        'alpha', 10, ...
        'omega0', 0.01, ...
        'obs_sigma', 0.5, ...
        'T', 15 ...
        );
      if strcmpi(func2str(algorithm), 'as_sopt_tt')
        choices_per_param.k = 100;
      end
      if ~exist('randomSeeds', 'var'), randomSeeds = []; end
      
      
    case 'populated_places_5000'
      load('../data/populated_places_5000.mat','A','labels');
      A = A;
      y = labels == 1;
      
      choices_per_param = struct( ...
        'alpha', [4,2,1,.1,.01,.001], ...
        'omega0', .01, ...
        'obs_sigma', [1,.5,.25,.1], ...
        'T',  3000 ...
        );
      if strcmpi(func2str(algorithm), 'as_sopt_tt')
        choices_per_param.k = [400 800 1600];
      end
      if ~exist('randomSeeds', 'var'), randomSeeds = []; end
      
    case 'wikipedia_data'
      load('../data/wikipedia_data.mat','A','labels_wiki');
      A = A;
      y = labels_wiki == 1;
      
      choices_per_param = struct( ...
        'alpha', [.1,.01,.001], ...
        'omega0', .01, ...
        'obs_sigma', [1,.5,.25,.1], ...
        'T',  1200 ...
        );
      if strcmpi(func2str(algorithm), 'as_sopt_tt')
        choices_per_param.k = [400 800 1600];
      end
      if ~exist('randomSeeds', 'var'), randomSeeds = []; end

    case 'new_nips'
      load('../data/new_nips.mat','A','posi*');
      A = A;
      labels = zeros(size(A, 1),1);
      labels(positive_node_ids) = 1;
      y = labels == 1;
      
      choices_per_param = struct( ...
        'alpha', [1, .1,.01,.001, .0001], ...
        'omega0', .01, ...
        'obs_sigma', [1,.5,.25,.1], ...
        'T',  3000 ...
        );
      if strcmpi(func2str(algorithm), 'as_sopt_tt')
        choices_per_param.k = [400 800 1600];
      end
      if ~exist('randomSeeds', 'var'), randomSeeds = [1,2,3,4,5]; end

    case 'enron_graph'
      load('../data/enron_graph.mat', 'A12w','labels');
      A = A12w;
      y = labels == 1;
      
      choices_per_param = struct( ...
        'alpha', [.001, .01, .1], ...
        'omega0', .01, ...
        'obs_sigma', [.1, .05, .01], ...
        'T', 4000 ...
        );
      
      if strcmpi(func2str(algorithm), 'as_sopt_tt')
        choices_per_param.k = [1600, 800, 400];
      end
      if ~exist('randomSeeds', 'var'), randomSeeds = [1]; end
  end
  
  %%
  if ~isempty(randomSeeds)
    for randomSeed = randomSeeds
      rng(randomSeed);
      f = find(y); randp = randperm(length(f));
      start_points(randomSeed) = f(randp(1));
    end
    choices_per_param.start_points = start_points;
  end
