function [outClusterLabelVector,outClusterNum] = HierarchicalCluster(inDataVector,inThresholdValue)
orderDataVector = sort(inDataVector);
[VectorHeight,VectorLength] = size(orderDataVector);
outClusterLabelVector = zeros(VectorHeight,VectorLength);
outClusterLabelVector(1) = 1;
tempClusterLabel = 1;
for counter_i = 2 : VectorLength
    tempOffset = orderDataVector(counter_i) - orderDatraVector(counter_i-1);
    if tempOffset >= inThresholdvalue
        tempClusterLabel = tempClusterLabel + 1;
    end
    outClusterLabelVector(counter_i) = tempClusterLabel;
end
outClusterNum = tempClusterLabel;

        