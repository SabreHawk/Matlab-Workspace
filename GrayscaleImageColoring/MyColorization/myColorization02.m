%{
File Illustration:
Creation Time : 2017/6/20
Creator : SabreHawk - Zhiquan Wang
Version : 1.1
  TimeStep  |    Author     |  Comment
2017 /6 /27 |  Zhiquan Wang | Complete Function : Copy Script Version 1.0 & Improve The Method
Missing TimeStep
2017 /7 /4  |  Zhiquan Wang | Complete Function
2017 /7 /5  |  Zhiquan Wang | Complete Function : New Method % New Functions
2017 /7 /23 |  Zhiquan Wang | Fix BUGS
Notice:
Version 1.0 6) Using Self Luminance Value To Search The Best Match SuperPixel
Version 1.1 6) Using Self And Aera Luminance Value With Min Max Mid ETCValues To Search For Matchest SuperPixels

Internal Functions:
1)function [outSegClusterValueVector,outSegClusterNumVector] = PixelValueDeployer(inInitialImage,inSuperPixelMatrix,inSuperPixelNum)
%}
 

%% 1)Read Grey Destination Image And Colorful Source Image
clear;  
clc;
DesGreyImage = imread('test1.jpg');
DesGreyImage = rgb2gray(DesGreyImage);
if size(size(DesGreyImage)) == [1,2]
    DesGreyImage = cat(3,DesGreyImage,DesGreyImage,DesGreyImage);
end
DesGreyImage = imresize(DesGreyImage,0.1);


SouColorImage = imread('test1.jpg');
SouColorImage = imresize(SouColorImage,0.1);
[DesGreyImageHeight,DesGreyImageWidth,h01] = size(DesGreyImage);
[SouColorImageHeight,SouColorImageWidth,h02] = size(SouColorImage);
%% 2)Transform Images From RGB Color Space To Lab Color Space;
labDesGreyImage = rgb2lab(DesGreyImage);
labSouColorImage = rgb2lab(SouColorImage);

%% 4)Segmentation Of Images Using SLIC SuperPixel
[SegDesGreyLabelMatrix, SegDesGreyLabelNum] = mySLIC(DesGreyImage,800);
[SegSouColorLabelMatrix, SegSouColorLabelNum] =  mySLIC(SouColorImage,800);


%% 3)Remapping L Value Of Source Image
labSouColorImage = LuminanceRemapping(labDesGreyImage,labSouColorImage);
%% 5)Extract Luminance Value Of Each SuperPixel In Images To Vector
[SegDesClusterValueVector,SegDesClusterNumVector] = PixelValueDeployer(labDesGreyImage,SegDesGreyLabelMatrix,SegDesGreyLabelNum);
[SegSouClusterValueVector,SegSouClusterNumVector] = PixelValueDeployer(labSouColorImage,SegSouColorLabelMatrix,SegSouColorLabelNum);
%% 6)Calculate Weight Of Each Pixel In Each Image
DesGreyWeightMatrix = PixelWeightCalculator(labDesGreyImage,SegDesGreyLabelMatrix,SegDesClusterValueVector,SegDesClusterNumVector);
SouColorWeightMatrix = PixelWeightCalculator(labSouColorImage,SegSouColorLabelMatrix,SegSouClusterValueVector,SegSouClusterNumVector);
%% 7)Search For The Best Match Of Grey Image SuperPixels From Sourece Image
[SegDesMatchLabelVector,SegDesMatchNumVector] = MatchSuperPixelsSearchor(SegDesClusterValueVector,SegDesClusterNumVector,SegSouClusterValueVector,SegSouClusterNumVector);
%% 8)Colorization Using Matched SuperPixel
resultImage = ImageColorization(labDesGreyImage,labSouColorImage,DesGreyWeightMatrix,SouColorWeightMatrix,SegDesGreyLabelMatrix,SegSouColorLabelMatrix,SegDesMatchLabelVector,SegDesMatchNumVector);
resultImage = lab2rgb(resultImage);
figure;
subplot(1,3,1);imshow(SouColorImage);
subplot(1,3,2);imshow(DesGreyImage);
subplot(1,3,3);imshow(resultImage);
figure;
imshow(resultImage);

%%Function Implementation
%%
function [outSegClusterValueVector,outSegClusterNumVector] = PixelValueDeployer(inInitialImage,inSuperPixelMatrix,inSuperPixelNum)
[imageHeight,imageWidth] = size(inSuperPixelMatrix);
segPixelNumVector = zeros(1,inSuperPixelNum);
segClusterValueVector = -1;
segClusterNumVector = zeros(1,inSuperPixelNum);
for LabelCounter = 1 : inSuperPixelNum
    tempSegPixelValueVector = zeros(1,1);
    % Extract Pixel Information For Each SuperPixel
    for ImageHeight_i = 1:imageHeight
        for ImageWidth_j = 1 : imageWidth
            tempLabel = inSuperPixelMatrix(ImageHeight_i,ImageWidth_j);
            if LabelCounter == tempLabel
                segPixelNumVector(LabelCounter) = segPixelNumVector(LabelCounter) + 1;
                tempSegPixelValueVector(segPixelNumVector(LabelCounter)) = inInitialImage(ImageHeight_i,ImageWidth_j,1);
            end
        end
    end
    % Cluster Pixels For Each SuperPixel
    tempClusterLabelMatrix = HierarchicalCluster(tempSegPixelValueVector);
    [~,PixelNum] = size(tempClusterLabelMatrix);
    tempClusterNum = tempClusterLabelMatrix(1,end);
    tempClusterAveValueVector = zeros(1,tempClusterNum);
    tempClusterNumValueVector = zeros(1,tempClusterNum);
    % Calculate Average Value For Each Cluster Of Each SuperPixel
    for PixelCounter_i = 1 : PixelNum
        tempPixelLabel = tempClusterLabelMatrix(1,PixelCounter_i);
        tempPixelValue = tempClusterLabelMatrix(2,PixelCounter_i);
        tempClusterAveValueVector(tempPixelLabel) = tempClusterAveValueVector(tempPixelLabel) + tempPixelValue;
        tempClusterNumValueVector(tempPixelLabel) = tempClusterNumValueVector(tempPixelLabel) + 1;
    end
    for ClusterCounter_i = 1 : tempClusterNum  
        tempClusterAveValueVector(ClusterCounter_i) = tempClusterAveValueVector(ClusterCounter_i) / tempClusterNumValueVector(ClusterCounter_i);
    end
    if LabelCounter ~= 1
        segClusterValueVector = [segClusterValueVector,tempClusterAveValueVector];
    else
        segClusterValueVector = tempClusterAveValueVector;
    end
    segClusterNumVector(LabelCounter) = tempClusterNum;
    if sum(segClusterNumVector) ~= length(segClusterValueVector)
        sum(segClusterNumVector)
        length(tempClusterAveValueVector)
        error('ERROR In Function : PixelValueDeployer - Length Of Vector');
    end
end
outSegClusterValueVector = segClusterValueVector;
outSegClusterNumVector = segClusterNumVector;
end
%%
function [outClusterLabelMatrix] = HierarchicalCluster(inDataVector,inThresholdValue)
if nargin == 1
    inThresholdValue = (max(inDataVector) - min(inDataVector)) * 0.15;
end
[VectorHeight,VectorLength] = size(inDataVector);
if VectorHeight ~= 1
    error('The Input Data Must Be A Vector');
end
orderDataVector = sort(inDataVector);
tempClusterLabelVector = zeros(1,VectorLength);
tempClusterLabelVector(1) = 1;
tempSumValueVector = zeros(1,VectorLength);
tempSumValueVector(1) = orderDataVector(1);
tempPixelNumVector = zeros(1,VectorLength);
tempPixelNumVector(1) = 1;
tempClusterLabel = 1;
for counter_i = 2 : VectorLength
    tempOffset = abs(orderDataVector(counter_i) - (tempSumValueVector(tempClusterLabel) / tempPixelNumVector(tempClusterLabel)));
    if tempOffset >= inThresholdValue
        tempClusterLabel = tempClusterLabel + 1;
    end
    tempSumValueVector(tempClusterLabel) = tempSumValueVector(tempClusterLabel) + orderDataVector(counter_i);
    tempPixelNumVector(tempClusterLabel) = tempPixelNumVector(tempClusterLabel) + 1;
    tempClusterLabelVector(counter_i) = tempClusterLabel;
end
outClusterLabelMatrix = [tempClusterLabelVector;orderDataVector];
end
%%
function [outWeightMatrix] = PixelWeightCalculator(inInitialImageMatrix,inSegLabelMatrix,inSegClusterValueVector,inSegClusterNumVector)
[imageHeight,imageWidth,~] = size (inInitialImageMatrix);
outWeightMatrix = zeros(imageHeight,imageWidth);
for imageHeight_i = 1 : imageHeight
    for imageWidth_j = 1 : imageWidth
        tempPixelLabel = inSegLabelMatrix(imageHeight_i,imageWidth_j);
        tempPixelValue = inInitialImageMatrix(imageHeight_i,imageWidth_j,1);
        
        tempMinOffset = 99999999;
        tempMatchCluster = -1;
        endIndex = sum(inSegClusterNumVector(1:tempPixelLabel));
        beginIndex = endIndex - inSegClusterNumVector(1:tempPixelLabel) + 1;
        for ClusterCounter_i = beginIndex : endIndex
            tempOffset =  abs(inSegClusterValueVector(ClusterCounter_i) - tempPixelValue);
            if  tempOffset < tempMinOffset
                tempMinOffset = tempOffset - tempPixelValue;
                tempMatchCluster = ClusterCounter_i;
            end
        end
        outWeightMatrix(imageHeight_i,imageWidth_j) = tempPixelValue * 0.5 +  inSegClusterValueVector(tempMatchCluster) * 0.5;
    end
end
end
%%
function [outSegDesMatchLabelVector,outSegDesMatchNumVector] = MatchSuperPixelsSearchor(inSegDesClusterValueVector,inSegDesClusterNumVector,inSegSouClusterValueVector,inSegSouClusterNumVector)
desClusterNum = length(inSegDesClusterValueVector);
souClusterNum = length(inSegSouClusterValueVector);
desSegNum = length(inSegDesClusterNumVector);
souSegNum = length(inSegSouClusterNumVector);
outSegDesMatchLabelVector = -1;
outSegDesMatchNumVector = zeros(1,desSegNum);
for desClusterCounter_i = 1 : desClusterNum
    tempMinOffset = 999999;
    tempMatchClusterLabel = -1;
    for souClusterCounter_i = 1 : souClusterNum
        tempOffset = abs(inSegDesClusterValueVector(desClusterCounter_i) - inSegSouClusterValueVector(souClusterCounter_i));
        if tempOffset < tempMinOffset
            tempMatchClusterLabel = souClusterCounter_i;
            tempMinOffset = tempOffset;
        end
    end
    tempDesLabelSum= 0;
    tempSouLabelSum = 0;
    for tempCounter_i = 1:desSegNum
        tempDesLabelSum = tempDesLabelSum + inSegDesClusterNumVector(tempCounter_i);
        if tempDesLabelSum >= desClusterCounter_i
            tempDesLabel = tempCounter_i;
            break;
        end
    end
    for tempCounter_i = 1:souSegNum
        tempSouLabelSum = tempSouLabelSum + inSegSouClusterNumVector(tempCounter_i);
        if tempSouLabelSum >= tempMatchClusterLabel
            tempSouLabel = tempCounter_i;
            break;
        end
    end
    if tempSouLabel == 76
        b = -2
    end
    if desClusterCounter_i ~= 1
        outSegDesMatchLabelVector = [outSegDesMatchLabelVector,tempSouLabel];
        outSegDesMatchNumVector(tempDesLabel) = outSegDesMatchNumVector(tempDesLabel) + 1;
    else
        outSegDesMatchLabelVector = tempSouLabel;
        outSegDesMatchNumVector(1) = 1;
    end
end
end
%%
function [outColorizedImageMatrix] = ImageColorization(inDesImage,inSouImage,inDesWeightMatrix,inSouWeightMatrix,inDesLabelMatrix,inSouLabelMatrix,inSegDesMatchLabelVector,inSegDesMatchNumVector)
[desImageHeight , desImageWidth,~] = size(inDesImage);
[souImageHeight , souImageWidth,~] = size(inSouImage);
outColorizedImageMatrix = inDesImage;
for desHeight_i = 1 : desImageHeight
    for desWidth_j = 1 : desImageWidth
        tempDesPixelLabel = inDesLabelMatrix(desHeight_i,desWidth_j);
        tempDesWeightValue = inDesWeightMatrix(desHeight_i,desWidth_j);
        matchSegEndIndex = sum(inSegDesMatchNumVector(1:tempDesPixelLabel));
        matchSegBeginIndex = matchSegEndIndex - inSegDesMatchNumVector(tempDesPixelLabel) + 1;
        tempMatchHeight= -1;
        tempMatchWidth = -1;
        tempMinOffset = 9999999999;
        for souHeight_i = 1 : souImageHeight
            for souWidth_j = 1 : souImageWidth
                tempSouPixelLabel = inSouLabelMatrix(souHeight_i,souWidth_j);
                for matchCounter_i = matchSegBeginIndex : matchSegEndIndex
                    if tempSouPixelLabel == inSegDesMatchLabelVector(matchCounter_i)
                        tempSouWeightValue = inSouWeightMatrix(souHeight_i,souWidth_j);
                        tempOffset = abs(tempSouWeightValue - tempDesWeightValue);
                        if tempOffset < tempMinOffset
                            tempMinOffset = tempOffset;
                            tempMatchHeight = souHeight_i;
                            tempMatchWidth = souWidth_j;
                        end
                    end
                end
            end
        end
        if tempMatchHeight == -1
            for matchCounter_i = matchSegBeginIndex : matchSegEndIndex
                inSegDesMatchLabelVector(matchCounter_i)
            end
             tempMinOffset
             inDesWeightMatrix(desHeight_i,desWidth_j)
             [matchSegBeginIndex,matchSegEndIndex]
             inSegDesMatchLabelVector(matchSegBeginIndex)
        end
        outColorizedImageMatrix(desHeight_i,desWidth_j,2) = inSouImage(tempMatchHeight,tempMatchWidth,2);
        outColorizedImageMatrix(desHeight_i,desWidth_j,3) = inSouImage(tempMatchHeight,tempMatchWidth,3);
    end
end
end
%%
