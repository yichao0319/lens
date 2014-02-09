function [X,Y,Z,W,U,V,S,T,sig] = lens_st_with_sigma(D,r,A,B,C,E,F,P,Q,sigma,soft,rho,tau,tol,exact)
%
% [X,Y,Z,W,U,V,S,T,sig] = LENS_ST_WITH_SIGMA(D,r,A,B,E,F,P,Q,sigma,soft,rho,tau,tol,exact) performs 
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
    error('sigma cannot be empty');
  end
  
  % initialize alpha, beta
  alpha = (sqrt(m)+sqrt(n))*sqrt(D_den);
  beta  = sqrt(2*log(min(nf,ny*D_den)));
  
  % check whether to skip X, Y, Z, W, S, T
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
  skipS = 0;
  if (nnz(P) == 0 || sigma == 0)
    skipS = 1;
  end
  skipT = 0;
  if (nnz(Q) == 0 || sigma == 0)
    skipT = 1;
  end
  
  % initialize M,X,Y,Z,W
  Dn = normest(D);
  mu = 1/Dn;
  M  = mu*D;

  U     = orth(randn(m,r));
  V     = orth(randn(n,r));
  Sigma = zeros(r,r);
  Y     = zeros(ry,n);
  W     = zeros(m,n);
  S     = zeros(m,n);
  T     = zeros(m,n);

  AX    = U*Sigma*V';
  BY    = B*(Y.*F);
  CZ    = zeros(m,n);
  
  eyeB  = isequal(B,speye(ry,ry));

  tau_y = tau/normest(B)^2;

  % convergence condition 1: norm(D-AX-BY-CZ-W-S-T,'fro') < min_diff
  min_diff = tol*norm(D,'fro');

  for k = 1:1000000

    % update X
    if (~skipX)
      J = D-BY-CZ-W-S-T+M/mu;
      [AX,U,Sigma,V] = ArgMinAX(J,U,Sigma,V,r,alpha/mu,exact,soft);
    end

    % update Y
    if (~skipY)
      J  = D-AX-CZ-W-S-T+M/mu;
      Y  = ArgMinY(J,B,BY,F,Y,beta/mu,eyeB,tau_y,soft);
      BY = B*(Y.*F);
    end

    % update Z
    if (~skipZ)
      J  = D-AX-BY-W-S-T+M/mu;
      CZ = ArgMinCZ(J,1/sigma/mu);
    end
    
    % update S
    if (~skipS)
      J  = D-AX-BY-CZ-W-T+M/mu;
      S  = ArgMinS(J,P,m,1/sigma/mu);
    end
    
    % update T
    if (~skipT)
      J  = D-AX-BY-CZ-W-S+M/mu;
      T  = ArgMinT(J,Q,n,1/sigma/mu);
    end
    
    % update W (which ensures that M.*E = 0)
    if (~skipW)
      J  = D-AX-BY-CZ-S-T+M/mu;
      W  = E.*J;
    end
    
    % update sigma if needed
    % TODO: consider S and T
    if (soft)
      dX = U*sign(Sigma)*V';  % noise due to SVShrink on AX
      dY = B*sign(Y);         % noise due to Shrink on Y
      ZN = D-AX-BY-W-S-T;     % Z plus noise
      PP = [dX(~E) dY(~E)];
      qq = pinv(full(PP'*PP))*(PP'*ZN(~E));
      JJ = ZN-dX*qq(1)-dY*qq(2);
      sig= std(JJ(~E))/sqrt((1-nnz(Sigma)/min(m,n))*(1-nnz(Y)/ny));
    else
      sig= sigma;
    end

    % update M
    J = D-AX-BY-CZ-W-S-T;
    M = M + mu*J;

    % update mu
    mu = mu*rho;
    
    % convergence test
    J = D-AX-BY-CZ-W-S-T;
    if (norm(J,'fro') <= min_diff)
      break
    end

  end
  
  % infer X from AX
  X = (A\U)*Sigma*V';
  
  % infer Z from CZ
  Z = C\CZ;
  [rz,cz] = size(Z);
  fprintf('sigma=%f sig=%f\n',sigma,sig);

function [AX,U,Sigma,V] = ArgMinAX(J,U,Sigma,V,r,thresh,exact,soft)

  [U,Sigma,V] = SVShrink(J,U,Sigma,V,thresh,r,exact,soft);
  AX = U*Sigma*V';


function Y = ArgMinY(J,B,BY,F,Y,thresh,eyeB,tau_y,soft)

  if (eyeB)
    Y = Shrink(J.*F,thresh,soft);
  else
    G = (B'*(BY-J)).*F;
    Y = Shrink(Y-tau_y*G,tau_y*thresh,soft);
  end
  

function CZ = ArgMinCZ(J,thresh)

  CZ = 1/(1+thresh)*J;


function S = ArgMinS(J,P,m,thresh)

  S = (thresh*P'*P + eye(m,m))\J;


function T = ArgMinT(J,Q,n,thresh)

  T = J/(thresh*Q'*Q + eye(n,n));  

  

function [U,Sigma,V] = SVShrink(X,U,Sigma,V,thresh,r,exact,soft)

  if (exact == 0)
    [U,Sigma,V] = ApproxSVD(X,U,Sigma,V);
  else
    [U,Sigma,V] = ExactSVD(X,r);
  end
  Sigma = Shrink(Sigma,thresh,soft);
  
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
function [U,Sigma,V] = ExactSVD(X,r)

  if (~isempty(which('lansvd')))
    [U,Sigma,V] = lansvd(X,r);
  else
    [U,Sigma,V] = svds(X,r);
  end
  
  % set tiny singular values to 0
  s = diag(Sigma);
  s(s<eps(max(s))*r) = 0;
  Sigma = sparse(1:r,1:r,s,r,r);
  
%
% approximate version of SVD
%
function [U,Sigma,V] = ApproxSVD(X,U,Sigma,V)

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
  Sigma = sparse(1:r,1:r,s,r,r);
  
  
  
