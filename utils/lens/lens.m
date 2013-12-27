function [X,Y,Z,W,sigma] = lens(D,r,A,B,C,E,F,sigma,soft,rho,tau,tol,exact,tol_sig)
%
% [X,Y,Z,W,U,V] = LENS(D,r,A,B,E,F,sigma,soft,rho,tau,tol,exact) performs 
% Low-rank Error Noise Sparse (LENS) decomposition on input matrix D by 
% solving the following constrained minimization problem:
%
%    minimize:    alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2
%    subject to:  A*X + B*(Y.*F) + Z + E.*W = D
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
%   
%
% The key idea is to consider the augmented Langrangian function
%
%   L(X,Y,Z,W,M,mu)
%     = alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2
%            + <M,D-A*X-B*(Y.*F)-Z-W>
%            + mu/2*|D-A*X-B*Y-Z-W|_F^2
%          
% where M is the Lagrangian multipliers, <M,N> = sum(M(:).*N(:)) is the
% standard trace norm.
%
% Input:
%
%    D:        data matrix
%
%    r:        an upper bound on the true rank
%
%    A:        A in A*X + B*(Y.*F) + Z + E.*W = D (e.g. routing matrix)
%
%    B:        B in A*X + B*(Y.*F) + Z + E.*W = D (e.g. anomaly profile matrix)
%
%    E:        E(i,j) = 1 <==> D(i,j) has measurement error (e.g. missing/wrong)
%
%    F:        candidate locations for outliers Y.  F(i,j) = 1 ==> Y(i,j) = 0.
%
%    sigma:    estimated value for std(Z) (default: [], i.e. automatically estimate it) 
%
%    soft:     whether to use soft thresholding in ArgMinX and ArgMinY (default: 1)
%
%    rho:      growth factor for mu (default: 1.2)
%
%    tau:      proximal paramter used in ArgMinX and ArgMinY
%              must be < 1 (default: 0.9)
%
%    tol:      convergence tolerance (default: 1e-7)
% 
%    exact:    in SVShrink, whenever to use ApproxSVD or ExactSVD
%
%

  if nargin < 8,  sigma = [];       end
  if nargin < 9,  soft = 1;         end
  if nargin < 10, rho = 1.05;       end
  if nargin < 11, tau = 0.9;        end
  if nargin < 12, tol = 1e-7;       end
  if nargin < 13, exact = 0;        end
  if nargin < 14, tol_sig = 1e-4;   end
    
  % obtain size information
  [m,n] = size(D);
  rx    = size(A,2);
  ry    = size(B,2);
  rz    = size(C,2);
  nx    = rx*n;
  ny    = ry*n;
  nf    = nnz(F);
  
  % make sure r is no greater than min(rx,n)
  r     = min(r,min(rx,n));

  % make sure D(E==1) = 0
  D     = D - D.*E;
  D_den = 1 - nnz(E)/(m*n);

  % initialize sigma
  if (isempty(sigma))
    sigma = std(D(~E));
    est_sig = 1;
    if (~soft)
      error('Can only estimate sigma when soft=1');
    end
  else
    est_sig = 0;
  end
  
  % initialize alpha, beta
  alpha = (sqrt(m)+sqrt(n))*sqrt(D_den);
  beta  = sqrt(2*log(min(nf,ny*D_den)));
  
  % check whether to skip X, Y, Z, W
  skipX = 0;
  if (nnz(A) == 0)
    skipX = 1;
  end
  skipY = 0;
  if (nnz(B) == 0) || (nnz(F) == 0)
    skipY = 1;
  end
  skipZ = 0;
  if (sigma == 0)
    skipZ = 1;
  end
  skipW = 0;
  if (nnz(E) == 0)
    skipW = 1;
  end
  
  % initialize M,X,Y,Z,W
  Dn = normest(D);
  mu = 1/Dn;
  M  = mu*D;
  
  U  = orth(randn(m,r));
  V  = orth(randn(n,r));
  S  = zeros(r,r);
  Y  = zeros(ry,n);
  W  = zeros(m,n);

  AX = U*S*V';
  BY = B*(Y.*F);
  CZ = zeros(m,n);
  
  eyeB  = isequal(B,speye(ry,ry));

  tau_y = tau/normest(B)^2;

  % convergence condition 1: norm(D-AX-BY-CZ-W,'fro') < min_diff
  min_diff = tol*norm(D,'fro');

  % convergence condition 2: abs(sigma_k-sigma) < min_sig_diff
  min_sig_diff = tol_sig*std(D(~E));
  
  for k = 1:inf

    % update X
    if (~skipX)
      J = D-BY-CZ-W+M/mu;
      [AX,U,S,V] = ArgMinAX(J,U,S,V,r,alpha/mu,exact,soft);
    end

    % update Y
    if (~skipY)
      J  = D-AX-CZ-W+M/mu;
      Y  = ArgMinY(J,B,BY,F,Y,beta/mu,eyeB,tau_y,soft);
      BY = B*(Y.*F);
    end

    % update Z
    if (~skipZ)
      J  = D-AX-BY-W+M/mu;
      CZ = ArgMinCZ(J,1/sigma/mu);
    end
    
    % update W (which ensures that M.*E = 0)
    if (~skipW)
      J  = D-AX-BY-CZ+M/mu;
      W  = E.*J;
    end
    
    % update sigma if needed
    sig_diff = 0;
    if (est_sig)
      dX = U*sign(S)*V';  % noise due to SVShrink on AX
      dY = B*sign(Y);     % noise due to Shrink on Y
      ZN = D-AX-BY;       % Z plus noise
      P  = [dX(~E) dY(~E)];
      q  = pinv(full(P'*P))*(P'*ZN(~E));
      J  = ZN-dX*q(1)-dY*q(2);
      sigma_k = std(J(~E))/sqrt((1-nnz(S)/min(m,n))*(1-nnz(Y)/ny));
      sig_diff = sigma_k - sigma;
      sigma = sigma + sig_diff * tau;
    end

    % update M
    J = D-AX-BY-CZ-W;
    M = M + mu*J;

    % update mu
    mu = mu*rho;
    
    % convergence test
    J = D-AX-BY-CZ-W;
    if (norm(J,'fro') <= min_diff) && (abs(sig_diff) < min_sig_diff)
      break
    end

  end
  
  % infer X from AX
  X = (A\U)*S*V';
  
  % infer Z from CZ
  Z = C\CZ;


function [AX,U,S,V] = ArgMinAX(J,U,S,V,r,thresh,exact,soft)

  [U,S,V] = SVShrink(J,U,S,V,thresh,r,exact,soft);
  AX = U*S*V';


function Y = ArgMinY(J,B,BY,F,Y,thresh,eyeB,tau_y,soft)

  if (eyeB)
    Y = Shrink(J.*F,thresh,soft);
  else
    G = (B'*(BY-J)).*F;
    Y = Shrink(Y-tau_y*G,tau_y*thresh,soft);
  end
  
function CZ = ArgMinCZ(J,thresh)

  CZ = 1/(1+thresh)*J;
  
function [U,S,V] = SVShrink(X,U,S,V,thresh,r,exact,soft)

  if (exact == 0)
    [U,S,V] = ApproxSVD(X,U,S,V);
  else
    [U,S,V] = ExactSVD(X,r);
  end
  S = Shrink(S,thresh,soft);
  
function X = Shrink(X,thresh,soft)

  if (~issparse(X))
    if (soft)
      X = sign(X).*max(0,abs(X)-thresh);
    else
      X(abs(X)<thresh) = 0;
    end
  else
    [m,n] = size(X);
    [i,j,v] = find(X);
    if (soft)
      v = sign(v).*max(0,abs(v)-thresh);
    else
      v(abs(v)<thresh) = 0;
    end
    X = sparse(i,j,v,m,n);
  end

%
% Be sure to install PROPACK (lansvd), which is much faster than
% Matlab's built-in svds(...) 
% 
function [U,S,V] = ExactSVD(X,r)

  if (~isempty(which('lansvd')))
    [U,S,V] = lansvd(X,r);
  else
    [U,S,V] = svds(X,r);
  end
  
  % set tiny singular values to 0
  s = diag(S);
  s(s<eps(max(s))*r) = 0;
  S = sparse(1:r,1:r,s,r,r);
  
%
% approximate version of SVD
%
function [U,S,V] = ApproxSVD(X,U,S,V)

  % X \approx (X*V) * V'
  [U,skip] = qr(X*V,0);
  
  % X \approx U*(X'*U)'
  [V,R] = qr(X'*U,0);
  
  % X \approx: U*Ur*Sr*Vr'*V'
  [Ur,Sr,Vr] = svd(R');

  
  U = U*Ur;
  V = V*Vr;

  % set tiny singular values to 0
  s = diag(Sr);
  r = length(s);
  s(s<eps(max(s))*r) = 0;
  S = sparse(1:r,1:r,s,r,r);
  
  
  
