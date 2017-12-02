clear 
clc


grayDestinationImageName = 'pic1-5.jpg';
colorSourceImageName= 'pic1-4.jpg';
figure;
imshow(grayDestinationImageName);
figure;
imshow(colorOSurceImageName);

initialSourcePic = double(imread(grayDestinationImageName));
if size(size(initialSourcePic)) == [1,2]
    initialSourcePic = cat(3,initialSourcePic,initialSourcePic,initialSourcePic);
end

initialColorPic = double(imread(colorSourceImageName));

%%initialSourcePic = cat(3,initialSourcePic,initialSourcePic,initialSourcePic);
[Width, Height ,Depth] = size(initialSourcePic);
LABSourceImage = rgb2lab(initialSourcePic);
LABColorImage =  rgb2lab(initialColorPic);

LSourceImage = LABSourceImage(:,:,1);
ASourceImage = LABSourceImage(:,:,2);
BSourceImage = LABSourceImage(:,:,3);

LColorImage = LABColorImage(:,:,1);
AColorImage = LABColorImage(:,:,2);
BColorImage = LABColorImage(:,:,3);


meanLSourceImage = mean(mean(LSourceImage));
meanASourceImage = mean(mean(ASourceImage));
meanBSourceImage = mean(mean(BSourceImage));

meanLColorImage = mean(mean(LColorImage));
meanAColorImage = mean(mean(AColorImage));
meanBColorImage = mean(mean(BColorImage));


SigmaLSourceImage = 0;
SigmaASourceImage = 0;
SigmaBSourceImage = 0;

SigmaLColorImage = 0;
SigmaAColorImage = 0;
SigmaBColorImage = 0;

for i = 1:Width
    for j = 1:Height
        SigmaLSourceImage = SigmaLSourceImage + (LSourceImage(i,j) - meanLSourceImage) ^ 2;
        SigmaASourceImage = SigmaASourceImage + (ASourceImage(i,j) - meanASourceImage) ^ 2;
        SigmaBSourceImage = SigmaBSourceImage + (BSourceImage(i,j) - meanBSourceImage) ^ 2;

    end
end
[cWidth, cHeight,cDepth] = size(LABColorImage);


for i = 1:cWidth
    for j = 1:cHeight
        SigmaLColorImage = SigmaLColorImage + (LColorImage(i,j) - meanLColorImage) ^ 2;
        SigmaAColorImage = SigmaAColorImage + (AColorImage(i,j) - meanAColorImage) ^ 2;
        SigmaBColorImage = SigmaBColorImage + (BColorImage(i,j) - meanBColorImage) ^ 2;
    end
end
SigmaLSourceImage = sqrt(SigmaLSourceImage);
SigmaASourceImage = sqrt(SigmaASourceImage);
SigmaBSourceImage = sqrt(SigmaBSourceImage);

SigmaLColorImage = sqrt(SigmaLColorImage);
SigmaAColorImage = sqrt(SigmaAColorImage);
SigmaBColorImage = sqrt(SigmaBColorImage);
%
LTargetImage = zeros([Width,Height]);
ATargetImage = zeros([Width,Height]);
BTargetImage = zeros([Width,Height]);
for i =1:Width
    for j = 1:Height
        LTargetImage(i,j) = (LSourceImage(i,j) - meanLSourceImage) * (SigmaLColorImage/SigmaLSourceImage) + meanLColorImage;
        ATargetImage(i,j) = (ASourceImage(i,j) - meanASourceImage) * (SigmaAColorImage/SigmaASourceImage) + meanAColorImage;
        BTargetImage(i,j) = (BSourceImage(i,j) - meanBSourceImage) * (SigmaBColorImage/SigmaBSourceImage) + meanBColorImage;
    end
end

resultImage = cat(3,LTargetImage,ATargetImage,BTargetImage);
resultImage = lab2rgb(resultImage);
imshow(resultImage);
