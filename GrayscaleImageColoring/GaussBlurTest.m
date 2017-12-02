testImage = imread('desImage15.jpg');

GaussSigma = 0.435;
GaussFuzzyTemplateMatrix = GaussTemplate(GaussSigma);
ImpactRange = round(GaussSigma * 3);
GaussTemplateLength=  length(GaussFuzzyTemplateMatrix);
finalImageMatrix = testImage;
directionVector = [-1,0;0,1;1,0;0,-1];
for i = 1 : DesGreyImageHeight
    for j = 1 : DesGreyImageWidth
        GaussValueMatrix = zeros(GaussTemplateLength,GaussTemplateLength,2);
        for xCounter = 1 : GaussTemplateLength
            for yCounter = 1 :GaussTemplateLength
                tempX = xCounter+i-ImpactRange-1;
                tempY = yCounter+j-ImpactRange-1;
                if tempX > 0 && tempX <= DesGreyImageHeight && tempY > 0 && tempY <= DesGreyImageWidth
                    GaussValueMatrix(xCounter,yCounter,1) = GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,1);
                    GaussValueMatrix(xCounter,yCounter,2) = GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,2);
                    GaussValueMatrix(xCounter,yCounter,3) = GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,3);
                end
            end
        end
        finalImageMatrix(i,j,1) = sum(sum(GaussValueMatrix(:,:,1)));
        finalImageMatrix(i,j,2) = sum(sum(GaussValueMatrix(:,:,2)));
        finalImageMatrix(i,j,3) = sum(sum(GaussValueMatrix(:,:,3)));
    end
end

function [GaussTemplateMatrix] = GaussTemplate(sigma)
ImpactRange = fix(3*sigma + 1);
GaussTemplateMatrix = zeros(ImpactRange);
for xCounter = 1 : ImpactRange * 2+1
    for yCounter = 1 : ImpactRange * 2+1
        GaussTemplateMatrix(xCounter,yCounter) = 1/(2*pi*sigma^2)*exp(-((xCounter-ImpactRange-1)^2+(yCounter-ImpactRange-1)^2)/(2*sigma^2));
    end
end
end