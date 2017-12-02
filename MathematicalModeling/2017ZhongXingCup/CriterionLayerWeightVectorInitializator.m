function [criterionLayer_WeightVector] = CriterionLayerWeightVectorInitializator(inputCriterionComparionMatrix)
%Calculate Max EigenValue And Related EigenVector
[maxCriterionLayer_EigValue , maxCriterionLayer_EigVector] = MaxEigenCalculator(inputCriterionComparionMatrix);

%Normalize EigenVector
criterionLayer_WeightVector = FeatureVectorNormalization(maxCriterionLayer_EigVector);
criterionLayer_TargetN = size(criterionLayer_WeightVector);
%Check Consistency
criterionLayer_CR = ConsistencyCheck(maxCriterionLayer_EigValue,criterionLayer_TargetN(1));
if criterionLayer_CR >= 0.1
    disp("Sonsistenct Check Illegally");
    disp(criterionLayer_CR);
end