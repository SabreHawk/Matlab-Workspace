[x,y] = meshgrid(-10:1:10);
z =  sqrt(25 - x^2 - y^2);
mesh(x,y,z);
rotate3d on;

