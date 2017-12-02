function [x,n] = Jacobi(A,b,x0,eps,varargin)
if nargin == 3
    eps = 1.0e-6;
    M = 200;
elseif nargin < 3
    eooer
    return
elseif nargin == 5
    M = varargin{1};
end

D = diag(diag(A));
L = -tril(A,-1);
U = -triu(A,1);
B = D\(L+U);
f = D\b;
x = B * x0 + f;
n = 1;
while norm(x-x0) >= eps
    x0 = x;
    x = B * x0 + f;
    n = n + 1;
    if n >= M
        disp('Too many times of iterator');
        return
    end
end
end
