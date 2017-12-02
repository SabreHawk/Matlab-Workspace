%{
File Illustration:
Creation Time : 2017/6/20
Creator : SabreHawk - Zhiquan Wang

  TimeStep  |    Author     |  Comment
2017 /6 /20 | Zhiquan Wang  |  Create The File & initial Implementation (1~2)
2017 /6 /22 | Zhiquan Wang  |  Complete Function : Step 3 ~ 8 [Function : LuminanceRemapping]
2017 /6 /27 | Zhiquan Wang  |  Modify Function   : Transform Implementation To Function 
 
Notice:
Version 1.0 6) Using Self Luminance Value To Search The Best Match SuperPixel
Version 1.1 6) Using Self And Aera Luminance Value To Search Top N Match SuperPixel
%}

% 1)Read Grey Destination Image Anf Colorful Source Image
clear;
clc;
DesGreyImage = imread('desImage05.jpg');
SouColorImage = imread('colorImage05.jpg');
[DesGreyImageHeight,DesGreyImageWidth,h01] = size(DesGreyImage);
[SouColorImageHeight,SouColorImageWidth,h02] = size(SouColorImage);
if size(size(DesGreyImage)) == [1,2]
    DesGreyImage = cat(3,DesGreyImage,DesGreyImage,DesGreyImage);
end

% 4)Segmentation Of Images Using SLIC SuperPixel 
[SegDesGreyLabelMatrix, SegDesGreyLabelNum] = mySLIC(DesGreyImage,800);
[SegSouColorLabelMatrix, SegSouColorLabelNum] =  mySLIC(SouColorImage,800);

% 2)Transform Images From RGB Color Space To Lab Color Space;
labDesGreyImage = rgb2lab(DesGreyImage);
labSouColorImage = rgb2lab(SouColorImage);
% 3)Remapping L Value Of Source Image
labSouColorImage = LuminanceRemapping(labDesGreyImage,labSouColorImage);

% 5)Calculate Average Grey Value Of Each SuperPixel In Images
SegDesAveLValueVector = zeros(1,SegDesGreyLabelNum);
SegDesAveLNumVector = zeros(1,SegDesGreyLabelNum);
SegSouAveLValueVector = zeros(1,SegSouColorLabelNum);
SegSouAveLNumVector =zeros(1,SegSouColorLabelNum);

for ImageHeight_i = 1:DesGreyImageHeight
    for ImageWidth_j = 1 : DesGreyImageWidth
        tempLabel = SegDesGreyLabelMatrix(ImageHeight_i,ImageWidth_j);
        SegDesAveLValueVector(tempLabel) = SegDesAveLValueVector(tempLabel) + labDesGreyImage(ImageHeight_i,ImageWidth_j,1);
        SegDesAveLNumVector(tempLabel) = SegDesAveLNumVector(tempLabel) + 1;
    end
end

for ImageHeight_i = 1 :SouColorImageHeight
    for ImageWidth_j = 1 : SouColorImageWidth
        tempLabel = SegSouColorLabelMatrix(ImageHeight_i,ImageWidth_j);
        SegSouAveLValueVector(tempLabel) = SegSouAveLValueVector(tempLabel) + labSouColorImage(ImageHeight_i,ImageWidth_j,1);
        SegSouAveLNumVector(tempLabel) = SegSouAveLNumVector(tempLabel) + 1;
    end
end

for LabelCounter_i = 1 : SegDesGreyLabelNum
    if SegDesAveLNumVector(LabelCounter_i) ~= 0
        SegDesAveLValueVector(LabelCounter_i) = SegDesAveLValueVector(LabelCounter_i) / SegDesAveLNumVector(LabelCounter_i);
    end
end

for LabelCounter_i = 1 : SegSouColorLabelNum
    if SegSouAveLNumVector(LabelCounter_i) ~= 0
        SegSouAveLValueVector(LabelCounter_i) = SegSouAveLValueVector(LabelCounter_i) / SegSouAveLNumVector(LabelCounter_i);
    end
end

% 6)Search For The Best Match Of Grey Image SuperPixels From Sourece Image
DesMatchLabelVector = size(1,SegDesGreyLabelNum);
for LabelCounter_i = 1 : SegDesGreyLabelNum
    tempMatchSuperPixel = -1;
    tempSuperPixelOffsetValue = 99999999;
    for LabelCounter_j = 1 : SegSouColorLabelNum
        tempOffset = SegDesAveLValueVector(LabelCounter_i) - SegSouAveLValueVector(LabelCounter_j);
        if abs(tempOffset) < abs(tempSuperPixelOffsetValue)
            tempSuperPixelOffsetValue = tempOffset;
            tempMatchSuperPixel = LabelCounter_j;
        end
    end
    DesMatchLabelVector(LabelCounter_i) = tempMatchSuperPixel;
end
% 7)Calculate Weight Of Each Pixel In Each Image
DesGreyWeightMatrix= size(DesGreyImageHeight,DesGreyImageWidth);
SouColorWeightMatrix= size(SouColorImageHeight,SouColorImageWidth);
for Height_i = 1 : DesGreyImageHeight
    for Width_j = 1 : DesGreyImageWidth
        tempPixelLabel = SegDesGreyLabelMatrix(Height_i,Width_j);
        DesGreyWeightMatrix(Height_i,Width_j) = labDesGreyImage(Height_i,Width_j,1) / 2 + SegDesAveLValueVector(tempPixelLabel) / 2;
    end
end

for Height_i = 1 : SouColorImageHeight
    for Width_j = 1 : SouColorImageWidth
        tempPixelLabel = SegSouColorLabelMatrix(Height_i,Width_j);
        SouColorWeightMatrix(Height_i,Width_j) = labSouColorImage(Height_i,Width_j,1) / 2 + SegSouAveLValueVector(tempPixelLabel) / 2;
    end
end

% 8)Colorization Using Matched SuperPixel
resultImage = labDesGreyImage;
for DesHeight_i = 1 : DesGreyImageHeight
    for DesWidth_j = 1 : DesGreyImageWidth
        tempDesPixelLabel = DesMatchLabelVector(SegDesGreyLabelMatrix(DesHeight_i,DesWidth_j));
        tempTargetX = -1;
        tempTargetY = -1;
        tempMinOffset = 999999;
        for SouHeight_i = 1 : SouColorImageHeight
            for SouWidth_j = 1 : SouColorImageWidth
                if SegSouColorLabelMatrix(SouHeight_i,SouWidth_j) == tempDesPixelLabel 
                    tempOffset = DesGreyWeightMatrix(DesHeight_i,DesWidth_j) - SouColorWeightMatrix(SouHeight_i,SouWidth_j);
                    if abs(tempOffset) < abs(tempMinOffset)
                        tempMinOffset = tempOffset;
                        tempTargetX = SouHeight_i;
                        tempTargetY = SouWidth_j;
                    end
                end
            end
        end
        resultImage(DesHeight_i,DesWidth_j,2) = labSouColorImage(tempTargetX,tempTargetY,2);
        resultImage(DesHeight_i,DesWidth_j,3) = labSouColorImage(tempTargetX,tempTargetY,3);
    end
end

resultImage = lab2rgb(resultImage);
figure;
subplot(1,3,1);imshow(SouColorImage);
subplot(1,3,2);imshow(DesGreyImage);
subplot(1,3,3);imshow(resultImage);
figure;
imshow(resultImage);


        


    



