function outCR = ConsistencyCheck(maxEigValue,targetN)
RIVector = [0 0 0.58 0.90 1.12 1.24 1.32 1.41 1.45 1.49 1.51 1.54 1.56 1.58 1.59 1.5943 1.6064 1.6133];
tempCI = (maxEigValue - targetN) / (targetN - 1);
outCR = tempCI / RIVector(targetN);
