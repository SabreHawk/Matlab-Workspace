function I_n = ComTrapezoidal(a,b,n)

h = (b-a)/n;
for k = 0:n
    x(k+1) = a + k * h;
    if x(k+1) == 0
        x(k+1) = 10 ^(-10);
    end
end
I_1 = h/2 * (f1(x(1)) + f1(x(n+1)));
for i = 2:n
    F(i) = h*f1(x(i));
end
I_2 = sum(F);
I_n = I_1+I_2;
