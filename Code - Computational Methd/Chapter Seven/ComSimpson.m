function I = ComSimpson(a,b,n)
n = 2;
h = (b-a)/2;
I1 = 0;
I2 = (f1(a)+f1(b))/h;
eps = 1.0e-4;
while abs(I2-I1)>eps
    n = n+1;
    h = (b-a) / n;
    I1 = I2;
    I2 = 0;
    for i = 0:n-1
        x = a + h * i;
        x1  =x+h;
        I2 = I2 + h/6* (f1(x) + 4*f1((x+x1)/2) + f1(x1));
    end
end
I = I2;