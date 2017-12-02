function [x,det,flag] = Gauss(A,b)

[n,m] = size(A);
nb = length(b);
if(n~=m)
    error('The rows and columns of matrix A must must br wqual!');
    return;
end

if(m~=nb)
    error('The columns of A must br equal the length of b');
    return;
end
flag = 'OK';
det = 1;
x =zeros(n,1);
for k = 1:n-1
    max1= 0;
    for i = k:n-1
        if abs(A(i,k))>max1
            max1 = abs(A(i,k));
            r = i;
        end
    end
    if max1<1e-10
        flag = 'failure';
        return;
    end
    if r>k
        for j = k:n
            z = A(k,j);
            A(k,j) = A(r,j);
            A(r,j) = z;
        end
        z = b(k);
        b(k) = b(r);
        b(r) = z;
        det = -det;
    end
    %
    for i = k+1:n
        m = A(i,k)/A(k,k);
        for j = k+1:n
            A(i,j) = A(i,j) - m*A(k,j);
        end
        b(i) = b(i) - m*b(k);
    end
    det = det * A(k,k);
end
det = det * A(n,n);
if abs(A(n,n))<1e-10
    flag = 'failure';
    return ;
end

for k = n:-1:1
    for j = k+1:n
        b(k) = b(k)-A(k,j) * x(j);
    end
    x(k) = b(k)/A(k,k);
end
x(k) = b(k)/A(k,k);
end

