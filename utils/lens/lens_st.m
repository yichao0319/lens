function [X,Y,Z,W,U,V,S,T,sigma] = lens_st(D,r,A,B,C,E,F,sigma,soft,rho,tau,tol,exact)
%
% [X,Y,Z,W,U,V,S,T,sig] = LENS_ST(D,r,A,B,E,F,P,Q,sigma,soft,rho,tau,tol,exact) performs 
% Spatial Temporal Low-rank Error Noise Sparse (LENS-st) decomposition on input matrix D by 
% solving the following constrained minimization problem:
%
%    minimize:    alpha*|A*X|_* + beta*|Y|_1 + 1/2/sigma*(|C*Z|_F^2 + |P*S|_F^2 + |T*Q'|_F^2)
%    subject to:  A*X + B*(Y.*F) + C*Z + E.*W + S + T = D
%
% where the choice of alpha and beta and the estimation of sigma is
% described in README.txt.  Specifically, we have:
%
%      alpha  = sum(sqrt(size(X)))*sqrt(D_den);
%      beta   = sqrt(2*log(nnz(F)))
%
% We develop an Alternating Direction Method motivated by the following
% two papers:
%
%   The Augmented Lagrange Multiplier Method for
%   Exact Recovery of Corrupted Low-Rank Matrices
%   http://decision.csl.illinois.edu/~yima/psfile/Lin09-MP.pdf
%
%   Alternating Direction Algorithms for ``$\ell_1$-Problems in 
%   Compressive Sensing
%   http://www.caam.rice.edu/~yzhang/reports/tr0937.pdf
%
% The key idea is to consider the augmented Langrangian function
%
%   L(X,Y,Z,W,S,T,M,mu)
%     = alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*(|Z|_F^2 + |P*S|_F^2 + |T*Q'|_F^2)
%            + <M,D-A*X-B*(Y.*F)-C*Z-W-S-T>
%            + mu/2*|D-A*X-B*(Y.*F)-C*Z-W-S-T|_F^2
%          
% where M is the Lagrangian multipliers, <M,N> = sum(M(:).*N(:)) is the
% standard trace norm.
%
% Input:
%
%    D:        data matrix
%    r:        an upper bound on the true rank
%    A:        A in A*X + B*(Y.*F) + C*Z + S + T + E.*W = D (e.g. routing matrix)
%    B:        B in A*X + B*(Y.*F) + C*Z + S + T + E.*W = D (e.g. anomaly profile matrix)
%    C:        C in A*X + B*(Y.*F) + C*Z + S + T + E.*W = D
%    E:        E(i,j) = 1 <==> D(i,j) has measurement error (e.g. missing/wrong)
%    F:        candidate locations for outliers Y.  F(i,j) = 1 ==> Y(i,j) = 0.
%    P:        spatial constraint matrix that makes |P*S|_F^2 small
%    Q:        temporal constraint matrix that makes |T*Q'|_F^2 small
%    sigma:    estimated value for std(Z) (default: [], i.e. automatically estimate it) 
%    soft:     whether to use soft thresholding in ArgMinX and ArgMinY (default: 1)
%    rho:      growth factor for mu (default: 1.2)
%    tau:      proximal paramter used in ArgMinX and ArgMinY
%              must be < 1 (default: 0.9)
%    tol:      convergence tolerance (default: 1e-7)
%    exact:    in SVShrink, whenever to use ApproxSVD or ExactSVD
%

  [m,n] = size(D);        
  CC = zeros(n, 1); CC(1,1) = 1;                                              
  RR = zeros(1, n); RR(1,1) = 1; RR(1,2) = -1;            
  P = []; % xxx: ignore spatial constraints at the moment
  Q = toeplitz(CC, RR); % use toeplitz matrix for temporal constraints


  if nargin < 8, sigma = [];       end
  if nargin < 9, soft = 1;         end
  if nargin < 10, rho = 1.05;      end
  if nargin < 11, tau = 0.9;       end
  if nargin < 12, tol = 1e-7;      end
  if nargin < 13, exact = 0;       end
  
  if (~isempty(sigma)) 
    [X,Y,Z,W,U,V,S,T,sig] = lens_st_with_sigma(D,r,A,B,C,E,F,P,Q,sigma,soft,rho,tau,tol,exact);
  
  else

    sigma_max = std(D(~E)) * 1e-2;
    sigma_min = -1;
    
    % make sure sigma_max is indeed an upper bound (via exponential search)
    while (1)
      [X,Y,Z,W,U,V,S,T,sig] = lens_st_with_sigma(D,r,A,B,C,E,F,P,Q,sigma_max,soft,rho,tau,tol,exact);    
      if (sig < sigma_max) 
        break;
      else
        sigma_min = sigma_max;
        sigma_max = sigma_max * 10;
      end
    end
    
    % make sure sigma_min is indeed a lower bound (via exponential search)
    if (sigma_min == -1)
      sigma_min = sigma_max / 10;
      while (1)
        [X,Y,Z,W,U,V,S,T,sig] = lens_st_with_sigma(D,r,A,B,C,E,F,P,Q,sigma_min,soft,rho,tau,tol,exact);    
        if (sig >= sigma_min) 
          break;
        else
          sigma_max = sigma_min;
          sigma_min = sigma_min / 10;
        end
      end
    end
    
    % perform binary search on log(sigma) to find a sigma such that 
    while (sigma_max/sigma_min > 1.1)
      sigma = sqrt(sigma_max * sigma_min);
      [X,Y,Z,W,U,V,S,T,sig] = lens_st_with_sigma(D,r,A,B,C,E,F,P,Q,sigma,soft,rho,tau,tol,exact);
      if (sig < sigma)
        sigma_max = sigma;
      else % (sig > sigma)
        sigma_min = sigma;
      end
    end
    
  end
  
