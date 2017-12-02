%{
File Illustration:
Creation Time : 2017/5/9
Creator : SabreHawk - Zhiquan Wang

 TimeStep  |    Author     |  Comment
2017 /5 /9 | Zhiquan Wang  |  Create The File & Complete The Function
%}
%{
Method Illustration:
Funciton :
%}
function outGradient = SLIC_CalculateGradient(inMatrix,m,n)
upPixel = inMatrix(m-1,n,:);
downPixel = inMatrix(m+1,n,:);
leftPixel = inMatrix(m,n-1,:);
rightPixel = inMatrix(m,n+1,:);

xDistance = (upPixel(1) - downPixel(1))^2 +...
            (upPixel(2) - downPixel(2))^2 +...
            (upPixel(3) - downPixel(3))^2;
yDistance = (leftPixel(1) - rightPixel(1))^2 +...
            (leftPixel(2) - rightPixel(2))^2 +...
            (leftPixel(3) - rightPixel(3))^2;
xDistance = sqrt(xDistance);
yDistance = sqrt(yDistance);
outGradient = xDistance + yDistance;

%{
Creation Time : 2017/5/9
Creator : SabreHawk - Zhiquan Wang

Version : 2017/5/9
Writer : SabreHawk - Zhiquan Wang
%}

