function outputVector = ZScoreNormalization(inputVector)
averageValue = mean(inputVector);
standardDeviationValue = std(inputVector);
outputVector = (inputVector - averageValue) ./ standardDeviationValue;