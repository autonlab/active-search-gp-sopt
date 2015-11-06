function [array_of_structs] = product_options(choices_per_option)
  % accepts 1d numeric values only, in the form [{name1, {values1n}}; ... ].
  % output [struct(name1, value11, name2, value21), ...]
  
  names = fieldnames(choices_per_option);
  values = struct2cell(choices_per_option);
  
  counts = cellfun(@numel, values);
  
  VALUES = repmat({[]}, [length(values), 1]);
  [VALUES{:}] = ndgrid(values{:});
  
  for i = 1:length(names)
    VALUES{i} = mat2cell(VALUES{i}(:), ones(prod(counts), 1));
  end
  
  interleave = [names, VALUES]';
  interleave = interleave(:);
  
  array_of_structs = struct(interleave{:});
