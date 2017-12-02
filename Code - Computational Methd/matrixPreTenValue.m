iniMatrix = load('iniMatrix.txt');
invMatrix = load('invMatrix.txt');
b = round(1000*rand(2000,1));
c = gmres(iniMatrix,b);
fprintf('Matlab Result');
x = iniMatrix\b;
for i = 1:10
    x(i,1)
end
fprintf('My Reuslt');
y = invMatrix * b;
for i = 1:10
    y(i,1)
end



