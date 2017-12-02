function [quatorFinalScore , Factor_SchemeLayerComparisonMatrix] = QuatorFinalScoreCalculator(inputAnalyzedScoreMatrix,inputQuatorIndex,inputCriterionComparisonMatrix,inputLastQuatorFinalScore)
criterionLayer_WeightVector = CriterionLayerWeightVectorInitializator(inputCriterionComparisonMatrix);
AnalyzedScoreMatrix = inputAnalyzedScoreMatrix(:,:,inputQuatorIndex);
if nargin == 4
    AnalyzedScoreMatrix = [AnalyzedScoreMatrix , inputLastQuatorFinalScore];
end
[EmployeeNum , FactorNum] = size(AnalyzedScoreMatrix);
Factor_SchemeLayerComparisonMatrix = zeros(EmployeeNum,EmployeeNum,FactorNum);
SchemeMatrix = zeros(EmployeeNum,FactorNum);
for FactorCounter_i = 1 : FactorNum
    Factor_SchemeLayerComparisonMatrix(:,:,FactorCounter_i) = SchemeLayerComparisonMatrixCalculator(AnalyzedScoreMatrix(:,FactorCounter_i));
    SchemeMatrix(:,FactorCounter_i) = CriterionLayerWeightVectorInitializator(Factor_SchemeLayerComparisonMatrix(:,:,FactorCounter_i));
end
%Calculate Final Score Of Each Employee - Quator One
quatorFinalScore = SchemeMatrix * criterionLayer_WeightVector;


