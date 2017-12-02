%{
File Illustration:
Creation Time : 2017/5/9
Creator : SabreHawk - Zhiquan Wang

  TimeStep  |    Author     |  Comment
2017 /5 /9  | Zhiquan Wang  |  Create The File
2017 /5 /10 | Zhiquan Wang  |  Complete Function : Initialize Cluster Centers
2017 /5 /11 | Zhiquan Wang  |  Complete Function : Perturb Cluster Centers
            |               |                      To The Lowest Gradient Position In Neighborhood
2017 /5 /12 | Zhiquan Wang  |  Complete Function : Upadate The Cluster Centers & Perform SuperPixel
2017 /5 /18 | Zhiquan Wang  |  Complete Function : Enforce Superpixel Connectivity
2017 /6 /2  | Zhiquan Wang  |  Modify Function   :Modify The Implementation Of The Function (Function Uncompleted)
2017 /6 /11 | Zhiquan Wang  |  Modify Function   :Check BUG And Modify The Implementation Of The Function (Function Completed)
2017 /6 /13 | Zhiquan Wang  |  Modify Function   :Check BUG
2017 /6 /14 | Zhiquan Wang  |  Modify Function   :Check BUG
2017 /6 /19 | Zhiquan Wang  |  Modify Function   :Transform Script To Function
%}
%{
Method Illustration:
Function:
    [1] SuperPixel Segmentation : Merge The Pixels In The Input Image To SuperPixels
Input Parameters:
    [1] inImageMatrix - Target Segmentation Image Matrix
    [2] K - The Approximately Number Of Clustering Pixels
    [3] M - The Factor M In The Formula While Calculating Distance (Ds)
Output Paramenters:
    [1] outImageMatrix - The Segmented Image Which Assigned With Labels
%}

function [outImageMatrix,outClusterNum] = mySLIC(initialImageMatrix,K,M)
if size(size(initialImageMatrix)) == [1,2]
    initialImageMatrix = cat(3,initialImageMatrix,initialImageMatrix,initialImageMatrix);
end
inImageMatrix = rgb2lab(initialImageMatrix);

if nargin == 1
    K = 400;
    M = 40;
end
if nargin == 2
    M = 40;
end

[imHeight ,imWidth,imDepth] = size(inImageMatrix);                         % Get The Size Of Input Image
N = imHeight * imWidth;                                                    % The Numebr Of Pixels
S = ceil(sqrt(N/K));                                                       % The Size Of Each Initial SuperPixels
maxIterator = 15;                                                         % The Maximum Times Of Iterating
%=============================================================================================================%

%=============================================================================================================%
%Set Initial Position Of Each Clustering Pixel
outImageMatrix = zeros(imHeight,imWidth);
% initialize output Image Matrix
%Set The Num Of Rows And Columns
rowNum = fix(imHeight/S);
columnNum = fix(imWidth/S);

rowOffset = imHeight - rowNum * S;
if rowOffset < 0
    rowNum = rowNum - 1;
    rowOffset = imHeight - rowNum * S;
end
rowPerOffset = rowOffset / rowNum;
columnOffset = imWidth - columnNum * S;
if columnOffset < 0
    columnNum = columnNum - 1;
    columnOffset = imHeight - columnNum * S;
end
columnPerOffset = columnOffset / columnNum;
clusterMatrix = zeros(rowNum * columnNum , 6);                             % initialize A Matrix To Storage The Information Of Each Cluster(L,a,b,x,y,size)
clusterCounter = 0;                                                        % Count The Num Of Clustering Pixel While Initializing
for i = 1:rowNum
    for j = 1:columnNum
        %Find Position Of Clustering Pixel
        seedX = ceil((i - 1) * (S + rowPerOffset)  + S / 2);
        seedY = ceil((j - 1) * (S + columnPerOffset) + S / 2);
        %Assign The Values To Clustering Pixel
        clusterMatrix(clusterCounter+1,:) = [inImageMatrix(seedX,seedY,1) inImageMatrix(seedX,seedY,2) inImageMatrix(seedX,seedY,3) seedX seedY 0];
        clusterCounter = clusterCounter + 1;
    end
end

%=============================================================================================================%

%=============================================================================================================%
startTime = clock;
%Move Initial Clustering Pixel To The Lowest Gradient Position(Optional)
isNeedMovement = 0;                                                        % Choose Whether Skip This Step
offset = ceil(S / 4);                                                      % The Offset Of The Size Of Search Aera
if isNeedMovement == 1
    for i = 1:clusterCounter
        tempMinGradient = 1000000;
        tempX = 0;
        tempY = 0;
        for x = clusterMatrix(i,4) - offset:clusterMatrix(i,4)+ offset
            if x<=1 || x >= imHeight
                continue;
            end
            for y = clusterMatrix(i,5) - offset : clusterMatrix(i,5) + offset
                if y<=1 || y >= imWidth
                    continue;
                end
                currentGradient = SLIC_CalculateGradient(inImageMatrix,x,y);
                if currentGradient < tempMinGradient
                    tempMinGradient = currentGradient;
                    tempX = x;
                    tempY = y;
                end
            end
        end
        clusterMatrix(i,:) = [inImageMatrix(tempX,tempY,1),inImageMatrix(tempX,tempY,2),inImageMatrix(tempX,tempY,3),tempX,tempY,1];
        %{
        Trail Code While Coding
        inImageMatrix(tempX,tempY,1) = 0;
        inImageMatrix(tempX,tempY,2) = 255;
        inImageMatrix(tempX,tempY,3) = 0;
        %}
    end
end
%}
%{
figure;
imshow(lab2rgb(inImageMatrix);
%}

%=============================================================================================================%

%=============================================================================================================%

distanceMatrix = ones(imHeight,imWidth) * 100000;                          % Store The Distance From Each Pixel To Closest Matching Cluster Pixel
% And Initialize Its Value To Maximum
labelMatrix = zeros(imHeight,imWidth);                                     % Store The Label Which Indicate The Cluster Pixel Each Pixel Belongs To
neighborhoodSize = fix(S * 2);                                             % The Size Of Each ClusterPixels' Neighborhood
maxIteratorTimes = maxIterator;                                                    % The Maximum Times Of Iterating
if M == 0                                                                  % Factor M In The Formula While Calculating Distance (Ds)
    m = 40;
else
    m = M;
end

for itor_counter = 1 : maxIteratorTimes
    % %Test Code
    % flag = 1;
    for i = 1:clusterCounter
        for j = clusterMatrix(i,4) - neighborhoodSize:clusterMatrix(i,4) + neighborhoodSize
            if j <= 0 || j > imHeight
                continue;
            end
            for k = clusterMatrix(i,5) - neighborhoodSize : clusterMatrix(i,5) + neighborhoodSize
                if k <= 0 || k > imWidth
                    continue
                end
                %Calculate Distance (Ds)
                labDistance = (inImageMatrix(j,k,1) - clusterMatrix(i,1)) ^ 2 + ...
                    (inImageMatrix(j,k,2) - clusterMatrix(i,2)) ^ 2 + ...
                    (inImageMatrix(j,k,3) - clusterMatrix(i,3)) ^ 2 ;
                labDistance = sqrt(labDistance);
                xyDistance  = (j - clusterMatrix(i,4)) ^ 2 + ...
                    (k - clusterMatrix(i,5)) ^ 2 ;
                xyDistance = sqrt(xyDistance);
                Ds = labDistance + (m/S)*xyDistance;
                %                 if flag ==1
                %                     Ds
                %                     flag = 0;
                %                 end
                %Update DistanceMatrix
                if Ds < distanceMatrix(j,k)
                    distanceMatrix(j,k) = Ds;
                    labelMatrix(j,k) = i;
                end
            end
        end
    end
    sigmaSuperPixelMatrix = zeros(clusterCounter,5);
    for pixel_i = 1 : imHeight
        for pixel_j = 1 : imWidth
            sigmaSuperPixelMatrix(labelMatrix(pixel_i,pixel_j),:) = sigmaSuperPixelMatrix(labelMatrix(pixel_i,pixel_j),:) + [inImageMatrix(pixel_i,pixel_j,1),inImageMatrix(pixel_i,pixel_j,2),inImageMatrix(pixel_i,pixel_j,3),pixel_i,pixel_j];
            clusterMatrix(labelMatrix(pixel_i,pixel_j),6) = clusterMatrix(labelMatrix(pixel_i,pixel_j),6) + 1;
        end
    end
    for superpixel_counter = 1: clusterCounter
        sigmaSuperPixelMatrix(superpixel_counter,:) = sigmaSuperPixelMatrix(superpixel_counter,:) / clusterMatrix(superpixel_counter,6);
        clusterMatrix(superpixel_counter,:) = fix([sigmaSuperPixelMatrix(superpixel_counter,:),0]);
        
    end
end
%=============================================================================================================%
endTime = clock;
%=============================================================================================================%
%Enforce Superpixel Connectivity

superpixelMinSize = ceil(sqrt(N/k));
xDirectionMap = [-1,0,1,0];
yDirectionMap = [0,-1,0,1];
for clusterCounter_i = 1 : clusterCounter
    tempPixelMap = zeros(imHeight,imWidth);
    %Generate A Connection Map
    for height_i = 1:imHeight
        for width_i = 1:imWidth
            if labelMatrix(height_i,width_i) == clusterCounter_i
                tempPixelMap(height_i,width_i) = -1;
            end
        end
    end
    [connectionMap,connectionNum] = bwlabel(tempPixelMap,4); % Return A ConnectionMap Has The Same Size Of Target Matrix
    for connectionCounter_i = 1 : connectionNum
        [xIndex,yIndex] = find(connectionMap == connectionCounter_i);
        pixelNum = size(xIndex);
        if (pixelNum(1) < superpixelMinSize) && (pixelNum(1) > 0)
            for pixelNum_i = 1 : pixelNum(1)
                for direction_i = 1:4
                    tempX = xIndex(1) + xDirectionMap(direction_i);
                    tempY = yIndex(1) + yDirectionMap(direction_i);
                    if tempX>0&&tempX<=imHeight&&tempY>0&&tempY<=imWidth
                        labelMatrix(xIndex(pixelNum_i),yIndex(pixelNum_i)) = labelMatrix(tempX,tempY);
                        break;
                    end
                end
            end
        end
    end
end
%}
%=============================================================================================================%


%Test Code
% for i = 1 : clusterCounter
%     xx = clusterMatrix(i,4)
%     yy = clusterMatrix(i,5)
%     inImageMatrix(xx,yy,:) = [0,255,0];
% end
% 
% for i = 1 : imHeight
%     for j = 1 : imWidth
%         if i > 1 && j > 1 && i < imHeight && j < imWidth
%             if labelMatrix(i,j) ~= labelMatrix(i+1,j) ...
%                     || labelMatrix(i,j) ~= labelMatrix(i,j+1) ...
%                     || labelMatrix(i,j) ~= labelMatrix(i+1,j+1)
%                 inImageMatrix(i,j,:) = [0,255,0];
%             end
%         end
%     end
% end
%% TEST
% GaussFuzzyTemplateMatrix = GaussTemplate(0.635);
% directionVector = [-1,0;0,1;1,0;0,-1];
% for i = 1 : imHeight
%     for j = 1 : imWidth
%         for dirCounter = 1 : 4
%             tempX = i + directionVector(dirCounter,1);
%             tempY = j + directionVector(dirCounter,2);
%             if tempX > 0 && tempX <= imHeight && tempY > 0 && tempY <= imWidth
%                 if labelMatrix(tempX,tempY) ~= labelMatrix(i,j)
%                     inImageMatrix(i,j,:) = [0,255,0];
%                 end
%             end
%         end
%     end
% end
% figure;
% labelMatrix
% imshow(lab2rgb(inImageMatrix));
%}
etime(endTime,startTime);

outImageMatrix = labelMatrix;
outClusterNum = clusterCounter;


