function labMatrix = RGBToLAB(rgbSourceMatrix)
%==============================
% GRB Color Space To CIE XYZ Color Space Matrix 
rgb2xyzMatrix = [0.5141 0.3239 0.1604;0.2651 0.6702 0.0641;0.0241 0.1228 0.8444];
% XYZ Color Space To CIE LMS Color Space Matrix
xyz2lmsMatrix = [0.3897 0.6890 -0.0787;-0.2298 1.1834 0.0464;0 0 1.0000];
% GRB Color Space To CIE LMS Color Spacec Matrix
rgb2lmsMatrix = xyz2lmsMatrix * rgb2xyzMatrix;
% L'M'S' Color Space To LAB Color Space Matrix
lms2labMatrix = [1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)] * [1 1 1;1 1 -2;1 -1 0];
%=======================
mSize = size(size(rgbSourceMatrix));
if mSize(2)== 2
    rgbSourceMatrix = cat(3,rgbSourceMatrix,rgbSourceMatrix,rgbSourceMatrix);
end

RSourceMatrix = rgbSourceMatrix(:,:,1);
GSourceMatrix = rgbSourceMatrix(:,:,2);
BSourceMatrix = rgbSourceMatrix(:,:,3);
[SWidth,SHeight,~] = size(rgbSourceMatrix);

%============LAB MATRIX
L1 = zeros(SWidth,SHeight);
Alpha1 = zeros(SWidth,SHeight);
Beta1 = zeros(SWidth,SHeight);

%=============LMS MATRIX
l1 = zeros(SWidth,SHeight);
m1 = zeros(SWidth,SHeight);
s1 = zeros(SWidth,SHeight);

% RGB Color Space To LMS Color Space

for i = 1:SWidth
    for j = 1:SHeight
        temp = rgb2lmsMatrix* [RSourceMatrix(i,j) ;GSourceMatrix(i,j) ;BSourceMatrix(i,j)];
        l1(i,j) = temp(1);
        m1(i,j) = temp(2);
        s1(i,j) = temp(3);
        for k = 1:3
            if temp(k) < 0
                temp(k) = 0;
            end
        end
    end
end

% LMS To L'M'S'
l1 = log10(l1);
m1 = log10(m1);
s1 = log10(s1);

for i = 1:SWidth
    for j = 1:SHeight
        temp = lms2labMatrix * [l1(i,j);m1(i,j);s1(i,j)];
        L1(i,j) = temp(1);
        Alpha1(i,j) = temp(2);
        Beta1(i,j) = temp(3);
        for k = 1:3
            if temp(k) < 0
                temp(k) = 0;
            end
        end
    end
end
labMatrix = cat(3,L1,Alpha1,Beta1);
end





