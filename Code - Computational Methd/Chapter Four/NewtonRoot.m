function root = NewtonRoot(myTestFunction,myTestDFunction,p0,eps,max1)
for k = 1 : max1
    p1 = p0 - feval('myTestFunction',p0)/feval('myTestDFunction',p0);
    err = abs(p1-p0);
    p0 = p1;
    if err < eps|| feval('myTestFunction',p0) == 0
        break;
    end
end

root = p0;
