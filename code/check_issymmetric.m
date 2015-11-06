function [tf] = check_issymmetric(varargin)
  if exist('issymmetric','builtin')
    tf = issymmetric(varargin{:});
  else
    matrix = varargin{1};
    tf = isequal(matrix, matrix');
  end
