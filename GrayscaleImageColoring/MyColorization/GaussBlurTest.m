testImage = imread('desImage11.jpg');
testImage = imresize(testImage,0.5);
[imageHeight,imageWidth,~] = size(testImage);
testImage = im2double(testImage);

GaussSigma = 10;
GaussFuzzyTemplateMatrix = GaussTemplate(GaussSigma);
ImpactRange = fix(GaussSigma * 3 + 1);
GaussTemplateLength = length(GaussFuzzyTemplateMatrix);
finalImageMatrix = zeros(imageHeight,imageWidth,3);
for i = 1 : imageHeight
    for j = 1 : imageWidth
        totalWeight = 0;
        for xCounter = 1 : GaussTemplateLength
            for yCounter = 1 :GaussTemplateLength
                tempX = xCounter+i-ImpactRange-1;
                tempY = yCounter+j-ImpactRange-1;
                
                if tempX > 0 && tempX <= imageHeight && tempY > 0 && tempY <= imageWidth
                    totalWeight = totalWeight + GaussFuzzyTemplateMatrix(xCounter,yCounter);
                    finalImageMatrix(i,j,1) = finalImageMatrix(i,j,1) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,1);
                    finalImageMatrix(i,j,2) = finalImageMatrix(i,j,2) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,2);
                    finalImageMatrix(i,j,3) = finalImageMatrix(i,j,3) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * testImage(tempX,tempY,3);
                end
                
            end    
        end
        for layerCounter = 1 : 3
            finalImageMatrix(i,j,layerCounter) = finalImageMatrix(i,j,layerCounter) / totalWeight;
        end
    end
end
figure;
subplot(2,1,1);imshow(testImage);
subplot(2,1,2);imshow(finalImageMatrix);


function [GaussTemplateMatrix] = GaussTemplate(sigma)
ImpactRange = fix(3*sigma + 1);
GaussTemplateMatrix = zeros(ImpactRange);
for xCounter = 1 : ImpactRange * 2+1
    for yCounter = 1 : ImpactRange * 2+1
        GaussTemplateMatrix(xCounter,yCounter) = 1/(2*pi*sigma^2)*exp(-((xCounter-ImpactRange-1)^2+(yCounter-ImpactRange-1)^2)/(2*sigma^2));
    end
end
end