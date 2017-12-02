function rgbMatrix = LABToRGB(labMatrix)

%==============================
% GRB Color Space To CIE XYZ Color Space Matrix 
rgb2xyzMatrix = [0.5141 0.3239 0.1604;0.2651 0.6702 0.0641;0.0241 0.1228 0.8444];
% XYZ Color Space To CIE LMS Color Space Matrix
xyz2lmsMatrix = [0.3897 0.6890 -0.0787;-0.2298 1.1834 0.0464;0 0 1.0000];
% GRB Color Space To CIE LMS Color Spacec Matrix
rgb2lmsMatrix = xyz2lmsMatrix * rgb2xyzMatrix;
% L'M'S' Color Space To LAB Color Space Matrix
lms2labMatrix = [1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)] * [1 1 1;1 1 -2;1 -1 0];

[Width, Height,depth] = size(labMatrix);

Rrgb = zeros(Width,Height);
Grgb = zeros(Width,Height);
Brgb = zeros(Width,Height);

Llab = labMatrix(:,:,1);
Alab = labMatrix(:,:,2);
Blab = labMatrix(:,:,3);

for i = 1:Width
    for j = 1:Height
        temp = inv(lms2labMatrix) * [Llab(i,j);Alab(i,j);Blab(i,j)];
        Rrgb(i,j) = temp(1); Grgb(i,j) = temp(2); Brgb(i,j) = temp(3);
    end
end

Rrgb = power(10,Rrgb);
Grgb = power(10,Grgb);
Brgb = power(10,Brgb);

for i = 1:Width
    for j = 1:Height
        temp = inv(rgb2lmsMatrix) * [Rrgb(i,j) ;Grgb(i,j);Brgb(i,j)];
        Rrgb(i,j) = temp(1);
        Grgb(i,j) = temp(2);
        Brgb(i,j) = temp(3);
        if Rrgb(i,j) >255 
            Rrgb(i,j) = 255;
        elseif Rrgb(i,j) < 0
                Rrgb(i,j) = 0;
        end
        
        if Grgb(i,j) >255 
            Grgb(i,j) = 255;
        elseif Grgb(i,j) < 0
                Grgb(i,j) = 0;
        end
        
        if Brgb(i,j) >255 
            Brgb(i,j) = 255;
        elseif Brgb(i,j) < 0
               Brgb(i,j) = 0;
        end
    end
end

rgbMatrix=uint8(cat(3,Rrgb,Grgb,Brgb));
