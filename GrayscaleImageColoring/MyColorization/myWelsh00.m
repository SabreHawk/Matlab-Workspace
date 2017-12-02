%This File's Function Is Transferring Color To Grey Image Using Welsh
%Algorithm
clc
clear 
grayDestinationImageName = 'desImage15.jpg';
colorSourceImageName= 'colorImage15.jpg';
imshow(colorSourceImageName);
figure;
%=Read Destination Greyscale Image And Color SourceImage
destinationImage = imread(grayDestinationImageName);
destinationImage = rgb2gray(destinationImage);
if size(size(destinationImage)) == [1,2]
    destinationImage = cat(3,destinationImage,destinationImage,destinationImage);
end
destinationImage = imresize(destinationImage,0.1);

%destinationImage = rgb2gray(destinationImage);
colorSourceImage = imread(colorSourceImageName);
colorSourceImage = imresize(colorSourceImage,0.1);
%=Convert Each Image From RGB Color Space To LAB Color Space 
labDesImageMatrix = rgb2lab(destinationImage);
labSouImageMatrix = rgb2lab(colorSourceImage);
%Get LAB Vector Information From Each Image
LDesImageMatrix = labDesImageMatrix(:,:,1);
ADesImageMatrix = labDesImageMatrix(:,:,2);
BDesImageMatrix = labDesImageMatrix(:,:,3);

LSouImageMatrix = labSouImageMatrix(:,:,1);
ASouImageMatrix = labSouImageMatrix(:,:,2);
BSouImageMatrix = labSouImageMatrix(:,:,3);

%figure;imshow(lab2rgb(labSouImageMatrix));
subplot(2,1,1);imshow(lab2rgb(labDesImageMatrix));
%figure;imshow(lab2rgb(cat(3,LSouImageMatrix,ASouImageMatrix,BSouImageMatrix)));

%=Get Mean LAB Values From Each Image
meanLDesImage = mean(mean(LDesImageMatrix));
meanADesImage = mean(mean(ADesImageMatrix));
meanBDesImage = mean(mean(BDesImageMatrix));

meanLSouImage = mean(mean(LSouImageMatrix));
meanASouImage = mean(mean(ASouImageMatrix));
meanBSouImage = mean(mean(BSouImageMatrix));
[souHeight, souWidth, souDepth] = size(labSouImageMatrix);
[desHeight, desWidth, desDepth] = size(labDesImageMatrix);
%=The sigma L Values Of Each Image
%{

sigmaLDesImage = 0;
sigmaADesImage = 0;
sigmaBDesImage = 0;
sigmaLSouImage = 0;
sigmaASouImage = 0;
sigmaBSouImage = 0;
for i = 1:desHeight
    for j = 1:desWidth
        sigmaLDesImage = sigmaLDesImage + ((LDesImageMatrix(i,j) - meanLDesImage) ^ 2);
        sigmaADesImage = sigmaADesImage + ((ADesImageMatrix(i,j) - meanADesImage) ^ 2);
        sigmaBDesImage = sigmaBDesImage + ((BDesImageMatrix(i,j) - meanBDesImage) ^ 2);
    end
end
for i = 1:souHeight
    for j = 1:souWidth
        sigmaLSouImage = sigmaLSouImage + ((LSouImageMatrix(i,j) - meanLSouImage) ^ 2);
        sigmaASouImage = sigmaASouImage + ((ASouImageMatrix(i,j) - meanASouImage) ^ 2);
        sigmaBSouImage = sigmaBSouImage + ((BSouImageMatrix(i,j) - meanBSouImage) ^ 2);
    end
end
sigmaLDesImage = sqrt(sigmaLDesImage);
sigmaADesImage = sqrt(sigmaADesImage);
sigmaBDesImage = sqrt(sigmaBDesImage);

sigmaLSouImage = sqrt(sigmaLSouImage);
sigmaASouImage = sqrt(sigmaASouImage);
sigmaBSouImage = sqrt(sigmaBSouImage);

%= Re-mapping L Value Of The ColorSource Image

neighbourhoodLength = 5;
modifiedLSouImageMatrix = zeros(souHeight,souWidth);
for i = 1:souHeight
    for j = 1:souWidth
        LSouImageMatrix(i,j) = (sigmaLDesImage/sigmaLSouImage) * (LSouImageMatrix (i,j) - meanLSouImage) + meanLDesImage; 
    end
end
%}
% Calculate Power of Sou Image
PowerSouImageMatrix = zeros(souHeight,souWidth);
PowerDesImageMatrix = zeros(desHeight,desWidth);
neihoodMeanLSouImageMatrix = zeros(souHeight,souWidth);
neihoodMeanLDesImageMatrix = zeros(desHeight,desWidth);
for i = 1:souHeight
    for j = 1:souWidth
        numCount = 0;
        for a = -2:2
            for b = -2:2    
                if(i+a>0&&j+b>0&&i+a<souHeight+1&&j+b<souWidth+1)
                    neihoodMeanLSouImageMatrix(i,j) = neihoodMeanLSouImageMatrix(i,j) + LSouImageMatrix(i+a,j+b);
                    numCount = numCount + 1;
                end
            end
        end
        neihoodMeanLSouImageMatrix(i,j) = neihoodMeanLSouImageMatrix(i,j) / numCount;
    end
end

for i = 1:souHeight
    for j = 1:souWidth
        PowerSouImageMatrix(i,j) = LSouImageMatrix(i,j); % + neihoodMeanLSouImageMatrix(i,j) / 2;
    end
end

for i = 1:desHeight
    for j = 1:desWidth
        numCount = 0;
        for a = -2:2
            for b = -2:2
                if(i+a>0&&j+b>0&&i+a<desHeight+1&&j+b<desWidth+1)%Keep Each Pixel In The Matrix
                    neihoodMeanLDesImageMatrix(i,j) = neihoodMeanLDesImageMatrix(i,j) + LDesImageMatrix(i+a,j+b);
                    numCount = numCount + 1;
                end
            end
        end
        neihoodMeanLDesImageMatrix(i,j) = neihoodMeanLDesImageMatrix(i,j) / numCount;
    end
end

for i = 1:desHeight
    for j = 1:desWidth
        PowerDesImageMatrix(i,j) = LDesImageMatrix(i,j);% / 2 + neihoodMeanLDesImageMatrix(i,j) / 2;
    end
end

% Search for matching

for i = 1:desHeight
    for j = 1:desWidth
        tempMin = 10000000;
        tempPos = [0,0];
        testCount = 0;
        for m = 1:souHeight
            for n = 1:souWidth
                if abs(PowerDesImageMatrix(i,j) - PowerSouImageMatrix(m,n)) < tempMin
                    tempMin = abs(PowerDesImageMatrix(i,j) - PowerSouImageMatrix(m,n));
                    tempPos = [m,n];
                end
            end
        end
        labDesImageMatrix(i,j,2) = labSouImageMatrix(tempPos(1),tempPos(2),2);
        labDesImageMatrix(i,j,3) = labSouImageMatrix(tempPos(1),tempPos(2),3);
    end
end
   
resultImageMatrix = lab2rgb(labDesImageMatrix);
subplot(2,1,2);imshow(resultImageMatrix);


        
