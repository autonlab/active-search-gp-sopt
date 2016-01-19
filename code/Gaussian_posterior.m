function [mn, prec, cov] = Gaussian_posterior( ...
    mn0, prec0, cov0, X, y, sigma_n)
  % function [p_vec, p_mat] = Gaussian_posterior( ...
  %     mode, p_vec0, p_mat0, X, y, sigma_n)
  % y = X*f = H' * f

  [m,n] = size(X);
  t = size(y,2);
  
  assert( all(size(mn0)   == [n,t] ));
  assert( all(size(prec0) == [n,n] ) || isempty(prec0) );
  assert( all(size(cov0)  == [n,n] ) || isempty(cov0)  );
  assert( all(size(X)     == [m,n] ));
  assert( all(size(y)     == [m,t] ));
  assert( isscalar(sigma_n) && sigma_n>0 );
  
  if ~isempty(prec0)
    prec = prec0 + sigma_n^-2 * (X' * X);
  else
    prec = [];
  end
  
  % cov_t from (6) in http://auai.org/uai2015/proceedings/papers/307.pdf
  if ~isempty(cov0)
    cov0_y = X * cov0 * X' + sigma_n^2 * eye(size(y, 1));
    R0_y = chol(cov0_y);
    minus_R = R0_y' \ (X * cov0);
    cov = cov0 - minus_R' * minus_R;
  else
    cov = [];
  end
  
  % mn_t with known cov_t, derived from (5) and also substituted L_0 by cov_t^-1 in
  % http://auai.org/uai2015/proceedings/papers/307.pdf
  if ~isempty(cov)
    mn = mn0 + cov  * (sigma_n^-2 * X'*(y-X*mn0));
  else
    mn = mn0 + prec \ (sigma_n^-2 * X'*(y-X*mn0));
  end
  
end

