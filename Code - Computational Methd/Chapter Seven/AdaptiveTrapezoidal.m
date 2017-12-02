function AdaptiveTrapezoidal(a,b,eps)
m = 1
t0 = 0;
t2 = (f2(a) + f2(b))/4+f2(((a+b)/2))
while abs(t2-t0) > eps
    m = m+1
    p = t2;
    t1 = 0;
    n = 2^m;
    h = (b-a)/n;
    for k = 0:n - 1
        t1 = t1 + h * ((f2(a+k*h) + f2(a + (k+1) * h))/4 + f2(a + (k+1/2) * h ) /2);
    end
    t2 = t1
    t0= p;
end
I = t2