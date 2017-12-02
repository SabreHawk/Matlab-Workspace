function I = NewtonCotes(a,b)
I = (b-a)/90 * (7 * f(a) + 32 * f((3*a+b)/4)+12*f((a+b)/2) + 32 * f((a + 3 * b ) / 4) + 7 * f(b));