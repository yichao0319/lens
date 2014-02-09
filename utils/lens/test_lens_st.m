n = 64;
m = 64;
d = 16;
sigma = 1e-2;
ny = 2*min(m,n);

U = randn(n,d);
V = randn(m,d);
X = U*V'+ones(n,m)*1000;
Y = sparse(n,m);
Y(randsample(n*m,ny)) = sign(randn(ny,1));
% add noise
Z = (randn(n,m))*sigma;
% add a temporal stability term
v = randn(n,1);
T = zeros(n,m);
for i=2:m
    delta = 1e-2*rand(n,1);
    T(:,i) = T(:,i-1) + delta;
end
T = ones(n,m);
D = X+Y+Z; 
D = D+ones(n,m);
save('d1','D');

r = d;
A = speye(n,n);
B = speye(n,n);
C = speye(n,n);
E = rand(size(D)) < 0.2;
F = ones(n,m);
soft = 1;

% [x,y,z,w,sig] = lens(D,r,A,B,C,E,F,[],soft);
[x,y,z,w,u,v,s,t,sig] = lens_st(D,2*r,A,B,C,E,F,sigma,soft);
sig

M = ~E;
error_a = norm(X-x,'fro')/norm(X,'fro')
error_b = norm(Y.*M-y.*M,'fro')/norm(Y.*M,'fro')
error = error_a + error_b
prec = nnz(Y.*y.*M)/nnz((y~=0).*M)
recall = nnz(Y.*y.*M)/nnz((Y~=0).*M)
jaccard =nnz(Y.*y.*M)/nnz(((Y~=0)|(y~=0)).*M)

F = y~=0;
r = min(r,rank(x));

soft = 0;
% [x,y,z,w] = lens(D,r,A,B,C,E,F,sig,soft);
% [x,y,z,w,sig] = lens_st(D,r,A,B);      
[x,y,z,w,u,v,s,t,sig] = lens_st(D,2*r,A,B,C,E,F,sig,soft);    

M = ~E;
error_a = norm(X-x,'fro')/norm(X,'fro')
error_b = norm(Y.*M-y.*M,'fro')/norm(Y.*M,'fro')
error = error_a + error_b
prec = nnz(Y.*y.*M)/nnz((y~=0).*M)
recall = nnz(Y.*y.*M)/nnz((Y~=0).*M)
jaccard =nnz(Y.*y.*M)/nnz(((Y~=0)|(y~=0)).*M)

fprintf('missing: %d %f\n', length(find(E==1)), length(find(E==1))/2500);
