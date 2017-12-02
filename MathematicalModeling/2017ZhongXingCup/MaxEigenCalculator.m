function [maxEigValue, maxEigVector] = MaxEigenCalculator(inputMatrix)
[eigVectors, eigValues] = eig(inputMatrix);
maxEigValue = -999;
maxEigValuePosition = 0;
matrixSize = size(inputMatrix);
for circulation_i = 1:matrixSize
    for circulation_j = 1:matrixSize
        if maxEigValue < eigValues(circulation_i,circulation_j)
            maxEigValue = eigValues(circulation_i,circulation_j);
            maxEigValuePosition = circulation_j;
        end
    end
end
maxEigVector = eigVectors(:,maxEigValuePosition);