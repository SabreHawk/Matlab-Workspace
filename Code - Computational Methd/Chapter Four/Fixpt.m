function r = Fixpt(myTestFunction,p0,tol,max1)
P(1) = p0;
for k = 2 : max1
    P(k) = feval('myTestFunction',P(k-1));
    err = abs(P(k)-P(k-1));
    if err<tol
        r = P(k);
        break;
    end
end
