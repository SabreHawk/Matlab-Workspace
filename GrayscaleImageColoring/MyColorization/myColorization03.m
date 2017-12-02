clear;
clc;

%% 1)Read Grey Destination Image And Colorful Source Image And Resize Images
clear;
clc;
disp('Step One : Read Images');
resizeScale = 0.5;
DesGreyImage = imread('desImage06.jpg');
DesGreyImage = im2double(DesGreyImage);
if size(size(DesGreyImage)) == [1,2]
    DesGreyImage = cat(3,DesGreyImage,DesGreyImage,DesGreyImage);
end
DesGreyImage = rgb2gray(DesGreyImage);
if size(size(DesGreyImage)) == [1,2]
    DesGreyImage = cat(3,DesGreyImage,DesGreyImage,DesGreyImage);
end
DesGreyImage = imresize(DesGreyImage,resizeScale);
SouColorImage = imread('colorImage06.jpg');
SouColorImage= im2double(SouColorImage);
SouColorImage = imresize(SouColorImage,resizeScale);
[DesGreyImageHeight,DesGreyImageWidth,~] = size(DesGreyImage);
[SouColorImageHeight,SouColorImageWidth,~] = size(SouColorImage);

%% 2)Transform Images From RGB Color Space To Lab Color Space;
disp('Step Two : Transform Color Space');
labDesGreyImage = rgb2lab(DesGreyImage);
initLabDesGreyImage = labDesGreyImage;
labSouColorImage = rgb2lab(SouColorImage);

%% 3)Segmentation Of Images Using SLIC SuperPixel
disp('Step Three : SLIC Segmentation');
[SegDesGreyLabelMatrix, SegDesGreyLabelNum] = mySLIC(DesGreyImage,50);
[SegSouColorLabelMatrix, SegSouColorLabelNum] =  mySLIC(SouColorImage,50);
desSegLabelMax = max(max(SegDesGreyLabelMatrix));
souSegLabelMax = max(max(SegSouColorLabelMatrix));

%% 4)Remapping L Value Of Source Image
disp('Step Four : Remapping');
labSouColorImage = LuminanceRemapping(labDesGreyImage,labSouColorImage);
labDesGreyImage = LuminanceRemapping(labSouColorImage,DesGreyImage);
%% 5) Build Pixel Struct Matrix
disp('Step Five : Build Pixel Information Matrix');
desPixelMatrix = PixelMatrixBuilder(labDesGreyImage,SegDesGreyLabelMatrix);
souPixelMatrix = PixelMatrixBuilder(labSouColorImage,SegSouColorLabelMatrix);

%% 6)Assign Pixel Cluster Information In Each SuperPixel
disp('Step Six : Assign Pixel Cluster Information');
desPixelMatrix = PixelClusterInfoMaker(desPixelMatrix);
souPixelMatrix = PixelClusterInfoMaker(souPixelMatrix);

%% 7)Calculate Pixel Weight
disp('Step Seven : Calculate Pixel Weight');
desPixelMatrix = PixelWeightCalculator(desPixelMatrix);
souPixelMatrix = PixelWeightCalculator(souPixelMatrix);

%% 8) Search For Matchest Pixel In Colorful Source Image And Colorization
disp('Step Eight : Match Pixels');
desMatchLabelMatrix = PixelMatchSearchor(desPixelMatrix,desSegLabelMax,souPixelMatrix);

%% 9) Assgin A B Value From Colorful Source Image To Grey Destination Image
disp('Step Nine : Assign Colorful Information');
colorizedImageMatrix = PixelNodeColorization(desPixelMatrix,desSegLabelMax,desMatchLabelMatrix,souPixelMatrix,initLabDesGreyImage);
colorizedImageMatrix = lab2rgb(colorizedImageMatrix);
% gausFilter = fspecial('gaussian',[5 5],1.6);
% finalImageMatrix=imfilter(colorizedImageMatrix,gausFilter,'replicate');

%% 10) Specified Pixels Gauss Fuzzy
disp('Step Ten : Image Gauss Fuzzy');
GaussSigma = 1;
GaussFuzzyTemplateMatrix = GaussTemplate(GaussSigma);
ImpactRange = fix(GaussSigma * 3 + 1);
GaussTemplateLength=  length(GaussFuzzyTemplateMatrix);
finalImageMatrix = colorizedImageMatrix;
directionVector = [-1,0;0,1;1,0;0,-1];
for i = 1 : DesGreyImageHeight
    for j = 1 : DesGreyImageWidth
        isLabelBorder = 0;
        for dirCounter = 1 : 4
            tempX = i + directionVector(dirCounter,1);
            tempY = j + directionVector(dirCounter,2);
            
            if tempX > 0 && tempX <= DesGreyImageHeight && tempY > 0 && tempY <= DesGreyImageWidth
                if SegDesGreyLabelMatrix(tempX,tempY) ~= SegDesGreyLabelMatrix(i,j)
                    isLabelBorder = 1;
                    break;
                end
            end
        end
        if isLabelBorder == 1
            GaussValueMatrix = zeros(GaussTemplateLength,GaussTemplateLength,3);
            totalWeight = 0;
            finalImageMatrix(i,j,:) = zeros(3,1);
            for xCounter = 1 : GaussTemplateLength
                for yCounter = 1 :GaussTemplateLength
                    tempX = xCounter+i-ImpactRange-1;
                    tempY = yCounter+j-ImpactRange-1;
                    if tempX > 0 && tempX <= DesGreyImageHeight && tempY > 0 && tempY <= DesGreyImageWidth
                        totalWeight = totalWeight + GaussFuzzyTemplateMatrix(xCounter,yCounter);
                        finalImageMatrix(i,j,1) = finalImageMatrix(i,j,1) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * colorizedImageMatrix(tempX,tempY,1);
                        finalImageMatrix(i,j,2) = finalImageMatrix(i,j,2) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * colorizedImageMatrix(tempX,tempY,2);
                        finalImageMatrix(i,j,3) = finalImageMatrix(i,j,3) + GaussFuzzyTemplateMatrix(xCounter,yCounter) * colorizedImageMatrix(tempX,tempY,3);
                    end
                end
            end
            finalImageMatrix(i,j,:) = finalImageMatrix(i,j,:)./totalWeight;
        end
    end
end


%% 11) Show Result Image
figure;
subplot(1,3,1);imshow(SouColorImage);
subplot(1,3,2);imshow(DesGreyImage);
%%subplot(2,2,3);imshow(colorizedImageMatrix);
subplot(1,3,3);imshow(finalImageMatrix);
figure;
imshow(finalImageMatrix);
%%
function [outPixelMatrix] = PixelMatrixBuilder(inInitialMatrix,inSegLabelMatrix)
[imageHeight,imageWidth,~] = size(inInitialMatrix);
outPixelMatrix(imageHeight,imageWidth).x = -1;
outPixelMatrix(imageHeight,imageWidth).y = -1;
outPixelMatrix(imageHeight,imageWidth).L = -1;
outPixelMatrix(imageHeight,imageWidth).A = -1;
outPixelMatrix(imageHeight,imageWidth).B = -1;
outPixelMatrix(imageHeight,imageWidth).Weight = -1;
outPixelMatrix(imageHeight,imageWidth).SuperPixelLabel = -1;
outPixelMatrix(imageHeight,imageWidth).ClusterLabel = -1;
outPixelMatrix(imageHeight,imageWidth).ClusterValue = -1;

for height_i = 1 : imageHeight
    for width_j = 1 : imageWidth
        outPixelMatrix(height_i,width_j).x= height_i;
        outPixelMatrix(height_i,width_j).y = width_j;
        outPixelMatrix(height_i,width_j).L = inInitialMatrix(height_i,width_j,1);
        outPixelMatrix(height_i,width_j).A = inInitialMatrix(height_i,width_j,2);
        outPixelMatrix(height_i,width_j).B = inInitialMatrix(height_i,width_j,3);
        outPixelMatrix(height_i,width_j).Weight = -1;
        outPixelMatrix(height_i,width_j).SuperPixelLabel = inSegLabelMatrix(height_i,width_j);
        outPixelMatrix(height_i,width_j).ClusterLabel = -1;
        outPixelMatrix(height_i,width_j).ClusterValue = -1;
    end
end

end
%%
function [outPixelMatrix] = PixelClusterInfoMaker(inPixelMatrix,inThreshold)
outPixelMatrix = inPixelMatrix;
[imageHeight,imageWidth] = size(inPixelMatrix);
for height_i = 1 : imageHeight
    for width_j = 1 : imageWidth
        tempClusterLabel = inPixelMatrix(height_i,width_j).ClusterLabel;
        tempSuperPixelLabel = inPixelMatrix(height_i,width_j).SuperPixelLabel;
        if tempClusterLabel ~= -1
            continue;
        end
        PixelNodeVector(1) = inPixelMatrix(height_i,width_j);
        for i = 1 : length(PixelNodeVector)
            if PixelNodeVector(i).SuperPixelLabel ~= tempSuperPixelLabel
                aaaaaaaaaaaaaaaaa = -1
            end
        end
        %size(PixelNodeVector)
        for height_ii = 1 : imageHeight
            for width_jj = 1 : imageWidth
                if inPixelMatrix(height_ii,width_jj).SuperPixelLabel == tempSuperPixelLabel
                    PixelNodeVector = [PixelNodeVector,inPixelMatrix(height_ii,width_jj)];
                end
            end
        end
        %[height_i,width_j]
        % tempSuperPixelLabel
        %PixelNodeVector(1).SuperPixelLabel
        
        [orderedPixelNodeVector,orderedPixelNodeIndex] = sort([PixelNodeVector.L]);
        if nargin == 1
            inThreshold = (max(orderedPixelNodeVector) - min(orderedPixelNodeVector)) * 0.2;
        end
        pixelNodeNum = length(orderedPixelNodeVector);
        tempClusterSumVector = zeros(1,pixelNodeNum);
        tempClusterSumVector(1) = orderedPixelNodeVector(1,1);
        tempClusterNumVector = zeros(1,pixelNodeNum);
        tempClusterNumVector(1) = 1;
        tempClusterCounter = 1;
        for pixelNode_i = 2 : pixelNodeNum
            tempLValue = orderedPixelNodeVector(pixelNode_i);
            tempPreClusterAveValue = tempClusterSumVector(tempClusterCounter) / tempClusterNumVector(tempClusterCounter);
            tempOffset = abs(tempLValue - tempPreClusterAveValue);
            if tempOffset > inThreshold
                tempClusterCounter = tempClusterCounter + 1;
            end
            tempClusterNumVector(tempClusterCounter) = tempClusterNumVector(tempClusterCounter) + 1;
            tempClusterSumVector(tempClusterCounter) = tempClusterSumVector(tempClusterCounter) + tempLValue;
            
        end
        if pixelNodeNum ~= sum(tempClusterNumVector)
            error = 129
            %% error("ERROR In Function : PixelClusterInfoMaker");
            
        end
        for cluster_i = 1 : tempClusterCounter
            tempAveValue = tempClusterSumVector(cluster_i) / tempClusterNumVector(cluster_i);
            endIndex = sum(tempClusterNumVector(1:cluster_i));
            startIndex = endIndex - tempClusterNumVector(cluster_i) + 1;
            for pixel_i = startIndex : endIndex
                tempX = PixelNodeVector(orderedPixelNodeIndex(pixel_i)).x;
                tempY = PixelNodeVector(orderedPixelNodeIndex(pixel_i)).y;
                inPixelMatrix(tempX,tempY).ClusterLabel = cluster_i;
                inPixelMatrix(tempX,tempY).ClusterValue = tempAveValue;
            end
        end
        clear PixelNodeVector
    end
end
outPixelMatrix = inPixelMatrix;
end
%%
function [outPixelMatrix] = PixelWeightCalculator(inPixelMatrix)
outPixelMatrix = inPixelMatrix;
[imageHeight,imageWidth] = size(inPixelMatrix);
for height_i = 1 : imageHeight
    for width_j = 1 : imageWidth
        outPixelMatrix(height_i,width_j).Weight = outPixelMatrix(height_i,width_j).L * 0.7 + outPixelMatrix(height_i,width_j).ClusterValue * 0.3;
    end
end
end
%%
function [outMatchMatrix] = PixelMatchSearchor(inDesPixelMatrix,inDesLabelMax,inSouPixelMatrix)
[desImageHeight,desImageWidth] = size(inDesPixelMatrix);
[souImageHeight,souImageWidth] = size(inSouPixelMatrix);
outMatchMatrix = zeros(desImageHeight,desImageWidth);
for superpixel_i = 1 : inDesLabelMax
    for desHeight_i = 1 : desImageHeight
        for desWidth_j = 1 : desImageWidth
            if outMatchMatrix(desHeight_i,desWidth_j) ~= 0
                continue;
            end
            if superpixel_i == inDesPixelMatrix(desHeight_i,desWidth_j).SuperPixelLabel
                tempDesClusterValue = inDesPixelMatrix(desHeight_i,desWidth_j).ClusterValue;
                tempMinOffset = 9999999;
                tempMatchLabel = -1;
                for souHeight_i = 1 : souImageHeight
                    for souWidth_j = 1 : souImageWidth
                        tempSouClusterValue = inSouPixelMatrix(souHeight_i,souWidth_j).ClusterValue;
                        tempOffset = abs(tempDesClusterValue - tempSouClusterValue);
                        if tempOffset < tempMinOffset
                            tempMinOffset = tempOffset;
                            tempMatchLabel = inSouPixelMatrix(souHeight_i,souWidth_j).SuperPixelLabel;
                        end
                    end
                end
                outMatchMatrix(desHeight_i,desWidth_j) = tempMatchLabel;
                for desHeight_ii = 1 : desImageHeight
                    for desWidth_jj = 1 : desImageWidth
                        if inDesPixelMatrix(desHeight_ii,desWidth_jj).ClusterValue == tempDesClusterValue && ...
                                inDesPixelMatrix(desHeight_ii,desWidth_jj).SuperPixelLabel == superpixel_i
                            outMatchMatrix(desHeight_ii,desWidth_jj) = tempMatchLabel;
                        end
                    end
                end
            end
        end
    end
end
end
%%
function [outColorizedMatrix] = PixelNodeColorization(inDesPixelMatrix,inDesLabelMax,inMatchLabelMatrix,inSouPixelMatrix,inDesInitialMatrix)
[desImageHeight,desImageWidth] = size(inDesPixelMatrix);
[souImageHeight,souImageWidth] = size(inSouPixelMatrix);
outColorizedMatrix = inDesInitialMatrix;
[h,w,l] = size(inDesPixelMatrix);
tempImage = zeros(h,w,l);
for i = 1 : h
    for j = 1 : w
        tempImage(i,j,1) = inDesPixelMatrix(i,j).L;
        tempImage(i,j,2) = inDesPixelMatrix(i,j).A;
        tempImage(i,j,3) = inDesPixelMatrix(i,j).B;
    end
end
figure;
imshow(lab2rgb(tempImage));
for superpixel_i = 1 : inDesLabelMax
    superpixel_i
    matchSuperPixelVector = zeros(1,inDesLabelMax);
    for desHeight_i = 1 :desImageHeight
        for desWidth_j = 1 : desImageWidth
            if inDesPixelMatrix(desHeight_i,desWidth_j).SuperPixelLabel == superpixel_i
                matchSuperPixelVector(inMatchLabelMatrix(desHeight_i,desWidth_j)) = 1;
            end
        end
    end
    if sum(matchSuperPixelVector) == 0
        continue;
    end
    for desHeight_ii = 1 : desImageHeight
        for desWidth_jj = 1 : desImageWidth
            if inDesPixelMatrix(desHeight_ii,desWidth_jj).SuperPixelLabel == superpixel_i
                tempMinOffset = 999999;
                tempMatchX = -1;
                tempMatchY = -1;
                for souHeight_i = 1:souImageHeight
                    for souWidth_j = 1 : souImageWidth
                        if matchSuperPixelVector(inSouPixelMatrix(souHeight_i,souWidth_j).SuperPixelLabel) == 1
                            tempOffset = abs(inDesPixelMatrix(desHeight_ii,desWidth_jj).Weight - inSouPixelMatrix(souHeight_i,souWidth_j).Weight);
                            if tempOffset < tempMinOffset
                                tempMinOffset = tempOffset;
                                tempMatchX = souHeight_i;
                                tempMatchY = souWidth_j;
                            end
                        end
                    end
                end
                %[desHeight_ii,desWidth_jj;tempMatchX,tempMatchY]
                %                 if tempMinOffset > 1
                %                     for souHeight_ii = 1 :souImageHeight
                %                         for souWidth_jj = 1 : souImageWidth
                %                             tempOffset = abs(inDesPixelMatrix(desHeight_ii,desWidth_jj).Weight - inSouPixelMatrix(souHeight_ii,souWidth_jj).Weight);
                %                             if tempOffset < tempMinOffset
                %                                 tempMinOffset = tempOffset;
                %                                 tempMatchX = souHeight_ii;
                %                                 tempMatchY = souWidth_jj;
                %                             end
                %                         end
                %                     end
                %                 end
                outColorizedMatrix(desHeight_ii,desWidth_jj,2) = inSouPixelMatrix(tempMatchX,tempMatchY).A;
                outColorizedMatrix(desHeight_ii,desWidth_jj,3) = inSouPixelMatrix(tempMatchX,tempMatchY).B;
            end
        end
    end
end
end
%%
function [GaussTemplateMatrix] = GaussTemplate(sigma)
ImpactRange = fix(3*sigma + 1);
GaussTemplateMatrix = zeros(ImpactRange);
for xCounter = 1 : ImpactRange * 2+1
    for yCounter = 1 : ImpactRange * 2+1
        GaussTemplateMatrix(xCounter,yCounter) = 1/(2*pi*sigma^2)*exp(-((xCounter-ImpactRange-1)^2+(yCounter-ImpactRange-1)^2)/(2*sigma^2));
    end
end
end








