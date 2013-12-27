1. LENS: A general framework for analyzing network matrices
=============================================================

We propose LENS: a general framework for analyzing network matrices by
decomposing the matrix into a Low-rank matrix, an Error term, a
Noise matrix, and a Sparse matrix.

* Basic Formulation
-------------------

   minimize:     alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2   (1)
   subject to:   X + Y + Z + W = D
                 W = E.*W
                 
where

   * D is the input matrix (of size [m,n])
   
   * X represents the low rank component,

     |X|_* = sum(svd(X)) is the nuclear norm of matrix X.
     
   * Y represents the sparse component, |Y|_1 = sum(abs(Y(:))).

   * Z represents the dense noise component.

     |Z|_F is the Frobenius norm of matrix Z.  |Z|_F^2 = sum(Z(i,j)^2) 

   * W represents the arbitrary error component.

     E is an 0/1 indicator matrix showing which elements of D are
     missing/erronenous.  
     
     Since W fully captures the missing/erroneous values, we can
     simply set D(E==1) = 0 without loss of generality.

     Let D_den = 1 - nnz(E)/prod(size(E)) be the density of non
     missing elements.

   * sigma is the standard deviation of Z(E==0).  For simplicity, we
     will assume that sigma is known a priori and that Z is
     homoscedastic (i.e. has uniform variance).  Later we show how to
     cope with the case when sigma is unknown and when Z is
     heteroscedastic (i.e. with non-uniform variance).

* More general formulation
--------------------------

We can easily generalize the above LENS decomposition to cope with the
following more general measurement constraint:

    A*X + B*Y + C*Z + W = D
    W = E.*W
    
where

    A captures tomography constraints for both direct and indirect
    measurements. 
   
    B represents an overcomplete anomaly profile matrix
    (e.g. enumerate all possible spike locations => I; all level
    shifts; wavelet coefficients; discrete cosine transform matrix;
    etc.) We ensure that columns of B have unit length.

    C captures the correlation among measurement noise.

In this case, notice that (i) when X is low-rank, A*X is also
low-rank, and (ii) when Z is a dense noise matrix, C*Z is also likely
to be dense.  We therefore propose to infer X, Y, Z by solving

  minimize:   alpha*|A*X|_* + beta*|Y|_1 + 1/2/sigma*|C*Z|_F^2  (2)
  subject to: A*X + B*Y + C*Z + W = D

where sigma is the standard deviation of CZ(~E), where CZ = C*Z.

We can simplify (2) by performing a change of variable.  Specifically,
let X = A*X_orig, Z = C*Z_orig.  Then (2) becomes

  minimize:   alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2      (3)
  subject to: X + B*Y + Z + W = D

Once we solve (3), we can then infer X_orig and Z_orig as X_orig =
pinv(A)*X, Z_orig = pinv(C)*Z.

2. Choosing parameters alpha and beta
==================================================================

Let sigma be the standard deviation of noise Z in (3).  For
simplicity, we assume that sigma is known.  Later we propose a
procedure for jointly estimating sigma with X,Y,Z,W.  Let D_den =
1-nnz(E)/prod(size(E)) be the density of good measurements in D.

We then propose to set:

   alpha = (sqrt(m)+sqrt(n))*sqrt(D_den)
   beta  = sqrt(2*log(prod(size(Y))*D_den))

Our proposed choices of alpha, beta are directly motivated by recent
advances in compressive sensing and matrix completion literature.  In
fact, these parameters are optimal if among the three components X, Y,
Z only two components need to be estimated.  Our empirical results
show that such choices also work very well in practice.

Below we intuitively justify our choice of alpha and beta for
formulation (3).  In this case, we have Z = D-X-B*Y-W.
 
2.1 Choosing alpha
------------------

Suppose Y is given.  Then we just need to solve:

    minimize: alpha*sigma*|X|_* + 1/2*|D-X-B*Y-W|_F^2

Clearly the optimal X is simply:

    SVSoftThresh(D-B*Y-W,alpha*sigma) = U*SoftThresh(S,alpha*sigma)*V'

where [U,S,V] = svd(D-B*Y-W),
SoftThresh(S,alpha)=sign(S).*max(0,abs(S)-alpha).  The shrinkage (aka
soft-thresholding) allows us to eliminate the effect of noise.

Assuming that we are doing a good job in the decomposition, then
D-X-B*Y-W contains only the noise component (with stddev = sigma).

According to the following lecture notes:

  http://www-stat.stanford.edu/~dneedell/280.html
  http://www-stat.stanford.edu/~dneedell/lecs/lec6.pdf
  
for a random matrix with entries draw i.i.d. from a subgaussian
distribution with robability D_den, its norm (i.e. the largest
singular value) is bounded by C*(sqrt(m)+sqrt(n))*sqrt(D_den)*sigma
with high probability, where constant C depends on which subgaussian
distribution it is.  In particular, if entries are i.i.d. Gaussian,
then C=1.  Therefore, a good heuristic is to set

      alpha*sigma = (sqrt(m)+sqrt(n))*sqrt(D_den)*sigma

That is:

      alpha = (sqrt(m)+sqrt(n))*sqrt(D_den)
      
A similar heuristic is proposed in the following paper,

      Matrix Completion With Noise
      Emmanuel J. Candes, Yaniv Plan
      arXiv:0903.3131v1
      http://arxiv.org/abs/0903.3131

Note that in reality D-X-B*Y-W consists of a mixture of the measurement
noise, and the residual noise introduced by applying SVSoftThresh on X and
SoftThresh on Y (see below).  As a result, even when the measurement noise
Z may not be strictly Gaussian, D-X-B*Y-W is likely to be gaussian-like
(just like in PCA where the residual tends to be gaussian like).
      
2.2 Choosing beta
-----------------

Suppose X is given.  We just need to solve:

    minimize: beta*sigma*|Y|_1 + 1/2*|D-X-B*Y-W|_F^2 

It is easy to see that the optimal Y is simply 

    SoftThresh(D-X-W,beta*sigma)

The shrinkage allows us to eliminate the effect of noise.

According to the Basis Pursuit De-Noising (BPDN) scheme proposed
in the following paper:

   "Atomic Decomposition by Basis Pursuit."   
   Scott Shaobing Chen, David L. Donoho, and Michael Saunders

in the context of standard compressive sensing

   minimize beta*sigma_d*|y|_1 + 1/2*|B*y-d|_2^2

a penalty term beta = sqrt(2*log(ry*cy)) should be used (assuming that
B's columns are distinct and have unit length).

In our context, we shall apply the same heuristic and set:

   beta*sigma = sqrt(2*log(prod(size(Y))*D_den))*sigma

That is

   beta = sqrt(2*log(prod(size(Y))*D_den))

3. Optimization algorithm
=========================

In this section, we show how to efficiently solve (3), i.e.:

  minimize:    alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2 
  subject to:  X + B*Y + Z + W = D
               W = E.*W

We will also show how to cope with unknown sigma.  

3.1. ADM Optimization Framework
-------------------------------

We develop an Alternating Direction Method motivated by the following
two papers:

  The Augmented Lagrange Multiplier Method for
  Exact Recovery of Corrupted Low-Rank Matrices
  http://decision.csl.illinois.edu/~yima/psfile/Lin09-MP.pdf

  Alternating Direction Algorithms for ``$\ell_1$-Problems in 
  Compressive Sensing
  http://www.caam.rice.edu/~yzhang/reports/tr0937.pdf

The key idea is to consider the augmented Langrangian function

  L(X,Y,Z,W,M,mu)
    = alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2
           + <M,D-X-B*Y-Z-W>
           + mu/2*|D-X-B*Y-Z-W|_F^2
           
where M is the Lagrangian multipliers, <M,N> = sum(M(:).*N(:)) is the
trace norm.

The algorithm progresses iteratively as follows:

   initialization:

        mu_0 = 0.1/|D|_2
        M_0  = mu_0*D;
        rho  = 1.05
        tol  = 1e-6
        Y_0  = 0
        Z_0  = 0
        W_0  = 0

   for k = 0 : infinity

       // update X, Y, Z, W in alternating directions
       X_{k+1} = argmin_X L(X,Y_k,Z_k,W_k,M_k,mu_k);
       Y_{k+1} = argmin_Y L(X_{k+1},Y,Z_k,W_k,M_k,mu_k);
       Z_{k+1} = argmin_Z L(X_{k+1},Y_{k+1},Z,W_k,M_k,mu_k);
       W_{k+1} = argmin_W L(X_{k+1},Y_{k+1},Z_{k+1},W,M_k,mu_k);

       // update sigma if not given
       if (est_sigma)
          sigma = updateNoise(X_{k+1}, Y_{k+1});
       end
       
       // update the Lagrangian multiplier
       M_{k+1} = M_k + mu_k*(D-X-B*Y-Z-W);

       // update mu
       mu_{k+1} = rho*mu_k;

       // convergence test
       if (|D-X_{k+1}-B*Y_{k+1}-Z_{k+1}-W_{k+1}|_F < tol*|D|_F)
          // convergence reached
          break
       end
       
   end   

3.2 Update X_{k+1}
------------------

Let J = D-B*Y_k-Z_k-W_k+M_k/mu_k.  We have:

  X_{k+1} = argmin_X L(X,Y_k,Z_k,W_k,M_k,mu_k);
          = argmin_X (alpha/mu_k)*|X|_* + 1/2*|J-X|_F^2
          = SVSoftThresh(J,alpha/mu_k)
        
3.4 Update Y_{k+1}
------------------    

Let J = D-X_{k+1}-Z_k-W_k+M_k/mu_k.  We have:
    
   Y_{k+1} = argmin_Y L(X_{k+1},Y,Z_k,W_k,M_k,mu_k)
           = argmin_Y (beta/mu_k)*|Y|_1 + 1/2*|J-B*Y|_F^2

* Case 1: B is an identity matrix

  In this case |J-B*Y|_F = |J-Y|_F.  Therefore,

   Y_{k+1} = argmin_Y (beta/mu_k)*|Y|_1 + 1/2*|J-Y|_F^2
           = SoftThresh(J,beta/mu_k)

* Case 2: B is not an identity matrix

  In this case, it is difficult to find the optimal Y exactly.
  Following the following paper

    Alternating Direction Algorithms for ``$\ell_1$-Problems in 
    Compressive Sensing
    http://www.caam.rice.edu/~yzhang/reports/tr0937.pdf
  
  we approximate 1/2*|J-B*Y|_F^2 as

         <g_k,Y-Y_k> + 1/(2*tau)*|Y-Y_k|_F^2

  where
      g_k = B'*(B*Y_k-J) is the gradient at Y=Y_k
      tau is a proximal parameter (default: tau = 0.9/normest(B'*B))

  We then set

    Y_{k+1} = argmin_Y (beta/mu_k)*|Y|_1 +
                       <g_k,Y-Y_k> + 1/(2*tau)*|Y-Y_k|_F^2

            = SoftThresh(Y_k-tau*g_k, tau*beta/mu_k)

3.5 Update Z_{k+1}
------------------    

Let J = D-X_{k+1}-B*Y_{k+1}-W_k+M_k/mu_k.  We have:
                    
    Z_{k+1} = argmin_Z L(X_{k+1},Y_{k+1},Z,W_k,M_k,mu_k);
            = argmin_Z 1/2/(mu*sigma)*|Z|_F^2 + 1/2*|J-Z|_F^2
            = 1/(1+1/(mu*sigma)) * J
              
3.6 Update W_{k+1}
------------------    

Let J = D-X_{k+1}-B*Y_{k+1}-Z_{k+1}+M_k/mu_k

  W_{k+1} = argmin_W L(X_{k+1},Y_{k+1},Z_{k+1},W,M_k,mu_k);
          = E.*J

4. Coping with Unknown sigma
============================

So far, we assume that the the sigma for measurement is known a
priori.  This in general is not true.  We therefore need to estimate
it from the input data.  Below we develop a simple procedure for
estimating sigma iteratively while estimating X, Y, Z, W.  First, I
will deal with the homogeneous noise case in which all elements of Z
are i.i.d. noise with unknown standard deviation sigma.  We then show
how to cope with the case when Z is heteroscedastic.

4.1 Homoscedastic Case
----------------------

Let J = D-X_{k+1}-B*Y_{k+1}.  A naive solution is to directly estimate

   sigma_{k+1} = std(J(:))                                    (4)

However, notice that D-X_{k+1}-B*Y_{k+1} both the genuine measurement
noise Z and the estimation error in X_{k+1} and Y_{k+1} due to the use
of soft-thresholding.  Therefore, (4) is likely to overestimate the
true noise level.

We propose the following simple procedure to remove the estimation
error on X_{k+1} and Y_{k+1} from J and thus estimate the true
variance of Z.

  (1) Compute noiseX = U*sign(S)*V' and noiseY = B*sign(Y)

  (2) Find coefficient q_X and q_Y to 

      minimize | J(~E) - q_X*noiseX(~E) - q_Y*noiseY(~E) |_F^2

  (3) Estimate

      sigma_{k+1} =

          std( J(~E) - q_X*noiseX(~E) - q_Y*noiseY(~E) )
     -------------------------------------------------------------
      sqrt( (1-rank(X)/min(size(X))) * (1-nnz(Y)/prod(size(Y))) )

  (4) Relaxation for better stability:

        sigma = sigma * (1-theta) + sigma_{k+1} * theta

      (currently, theta = 0.9)

Explanation:

  Essentially, we are assuming that the use of SVSoftThresh while
  estimating X_{k+1} injects noise proportional to noiseX =
  U*sign(S)*V' into J=D-X_{k+1}-B*Y_{k+1}.  Similarly, the use of
  SoftThresh while estimating Y_{k+1} injects noise proportional to noiseY
  = B*sign(Y) into J.

  Since we don't know the exact scaling factor for noiseX and noiseY,
  in step 2 we estimate the weights q_X and q_Y through least-squares
  fitting.  We then subtract q_X*noiseX and q_Y*noiseY when estimating
  sigma_{k+1} in step 3.

  But such least-squares fitting may end up overestimate q_X and q_Y,
  because the part of the true noise Z can get projected onto noiseX
  and noiseY.  Specifically, if we project Z onto noiseX, the variance
  captured by the projected Z is roughly rank(X)/min(size(X)).
  Similarly, if we project Z onto noiseY, the variance captured by the
  projected Z is roughly as nnz(Y)/prod(size(Y)).  Therefore, in step
  3 above, the denominator compensates for such loss of variance in Z.

4.2 Heteroscedastic Case
------------------------

When Z is heteroscedastic, we perform the following iterative
procedure to rescale entries of D.

   est_sig = true;
   for iter = 1:3

       [X,Y,Z,W] = lens(D,est_sig);

       // apply a robust scale estimator to estimate
       // scaling factors for rows and/or columns of D
       row_scale = mad(Z,[],1);
       col_scale = mad(Z,[],2);

       D = rescale(D,row_scale,col_scale).

   end

Our experience shows that typically few iterations (e.g. 3) is more
than enough.

5. Performance Optimization
===========================     

5.1 Fast SVD
------------

A key performance bottleneck is the need to perform SVD during
SVSoftThresh.   We propose two techniques to significantly improve the
efficiency of SVD.

(1) Use partial SVD.  We explicitly ask the user to provide an upper
    bound on the likely rank r, then we can use svds() instead of
    svd() for more efficient optimization.  In fact, we will use
    lansvd() in PROPACK, which is 3-4 times faster than svds(...)


(2) More importantly, we propose the following approximate SVD method.
    The key observation is that X tends to change slowly.  Thus, if we
    already have the SVD in iteration k, we can use this as a starting
    point to approximately compute SVD in iteration k+1.

    More precisely, let J_{k+1} = D-B*Y_k-Z_k-W_k+M_k/mu_k.  We have:

        X_{k+1} = SVSoftThresh(J_{k+1},alpha/mu_k)
        
    Suppose we have already recorded

        [U_k,S_k,V_k] = svds(J_k,r)

    We can then obtain

        [U_{k+1},S_{k+1},V_{k+1}] = ApproxSVD(J_{k+1},r)

    as follows:

       % J_{k+1} \approx (J_{k+1}*V) * V'
       [U,Ru] = qr(J_{k+1}*V,0);
  
       % J_{k+1} \approx U*(J_{k+1}'*U)'
       [V,Rv] = qr(X'*U,0);
  
       % J_{k+1} \approx: U*Ur*Sr*Vr'*V'
       [Ur,Sr,Vr] = svd(Rv');

       U_{k+1} = U*Ur;
       V_{k+1} = V*Vr;
       S_{k+1} = Sr;
       
    By using QR factorization on matrices with r columns and svd on
    r-by-r small matrices, we can sigificantly improve the efficiency.

    For initialization, we simply set U_0=orth(randn(m,r)),
    V_0=orth(randn(n,r)).     

5.2 Incorporate Hints on Non-zero Locations of Y
------------------------------------------------

If we know F, a superset of non-zero locations in Y.  We can directly
incorporate it into our formulation:

  minimize:    alpha*|X|_* + beta*|Y|_1 + 1/2/sigma*|Z|_F^2 
  subject to:  X + B*(Y.*F) + Z + W = D
               W = E.*W

In this case, we define beta to

   beta = sqrt(2*log(min(nnz(F),prod(size(Y))*D_den)))

The estimation for Y_{k+1} is similar, except that we need to ensure
Y_{k+1} = Y_{k+1}.*F   
    
5.3 Combine Soft Thresholding with Hard Thresholding
----------------------------------------------------

A problem with using soft-thresholding is that the resulting Z
contains both true measurement noise and estimation error.

To improve the estimation accuracy, we propose to apply Hard
Thresholding in the above optimization as a post-processing step.
Specifically,

   HardThresh(M_ij,thresh) = 0         if abs(M_ij) <  thresh
                             M_ij      if abs(M_ij) >= thresh


   SVHardThresh(M,thresh) = U*HardThresh(S,thresh)*V'
                     where [U,S,V] = svd(M)

Note that directly applying hard-thresholding does not work well
because hard-thresholding is non-convex and one can easily get stuck
at local minima.

Instead we propose to use the soft-thresholding solution to provide
hint on the real rank r and the non-zero locations of Y and then apply
hard-thresholding 

   (1) soft = 1.  F = ones(size(Y)). sigma0 = unknown.
       [X,Y,Z,W,sigma] = lens(D,A,B,C,E,F,r,soft,sigma0).

   (2) Update

       r = min(r,rank(X))
       F = (Y~=0)

   (3) soft = 0.
       [X,Y,Z,W] = lens(D,A,B,C,E,F,r,soft,sigma).

Our results suggest that such hard-thresholding results in significant
improvement on the estimation accuracy w.r.t. both the values and the
set of non-zero locations in Y.

                                                                                  

