function weightVector = FeatureVectorNormalization(inputVector)
vectorValueSum = sum(inputVector);
weightVector = inputVector / vectorValueSum;

