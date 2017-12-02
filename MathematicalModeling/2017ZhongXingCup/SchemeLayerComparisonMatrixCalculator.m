function outComparisonMatrix = SchemeLayerComparisonMatrixCalculator(inputVector)
matrixSize = size(inputVector);
outComparisonMatrix = zeros();

for matrixCounter_i = 1 : matrixSize(1)
    for matrixCounter_j = 1 : matrixSize(1)
        outComparisonMatrix (matrixCounter_i,matrixCounter_j) = inputVector(matrixCounter_i) / inputVector(matrixCounter_j);
    end
end
