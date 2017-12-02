%{
  File Illustration:
  Creation Time : 2017/6/4
  Creator : SabreHawk - Zhiquan Wang
 
  TimeStep  |    Author     |  Comment
  2017/6/4  | Zhiquan Wang  | Complete Step : Analyze Initial Data
  2017/6/5  | Zhiquan Wang  | Complete Step : 1) Initialize Criterion Layer Comparison Matrix Of Quator One
                                              2) Initialize Comparion Matrix Of Factor P S M Of Scheme Layer Of Quator One
  2017/6/6  | Zhiquan Wang  | Complete Step : 1) Optimize Code Implementation Of Total Flow
                                              2) Complete All The Steps
  2017/6/7  | Zhiquan Wang  | Complete Step : Change The Computational Method Of Factor - Tendency
  2017/6/8  | Zhiquan Wang  | Modify The Calculator Of Factor
  Script Illustration:
  Function:
  Method:
%}

clc
clear
load('initialData.mat');
%4 6 8 3 16
% Analyze Initial Data
AnalyzedEmployeeInfoMatrix = cat(3,ScoreCalculator(EMPLOYEESCOREMATRIX_QUATORONE,SCOREMODEl_QUATORONE),...
    ScoreCalculator(EMPLOYEESCOREMATRIX_QUATORTWO,SCOREMODEl_QUATORTWO),...
    ScoreCalculator(EMPLOYEESCOREMATRIX_QUATORTHREE,SCOREMODEl_QUATORTHREE));

%Initialize Comparion Matrix Of Criterion Layer - Quator One
%Set Comparison Matrix Of Criterion Layer
Criterion_ComparisonMatrix_SquareThree = ...
    [1   1/2 2;
    2   1   4;
    1/2 1/4 1];
%Calculate Final Score Of Each Employee - Quator One
[singleScoreMatrix_QuatorOne,Factor_SchemeLayerComparisonMatrixQuatorOne]= QuatorFinalScoreCalculator(AnalyzedEmployeeInfoMatrix,1,Criterion_ComparisonMatrix_SquareThree);
finalScoreMatrix_QuatorOne = singleScoreMatrix_QuatorOne;
%Initialize Comparion Matrix Of Criterion Layer - Quator One
Criterion_ComparisonMatrix_QuatorTwoThree = ...
    [1   1/2  2   7;
    2   1    4   9;
    1/2 1/4  1   7;
    1/7 1/9  1/7 1];
%Calculate Final Score Of Each Employee - Quator Two
singleScoreMatrix_QuatorTwo = QuatorFinalScoreCalculator(AnalyzedEmployeeInfoMatrix,2,Criterion_ComparisonMatrix_SquareThree);
tendencyVector_QuatorTwo = singleScoreMatrix_QuatorTwo ./ singleScoreMatrix_QuatorOne;
[finalScoreMatrix_QuatorTwo,Factor_SchemeLayerComparisonMatrixQuatorTwo] = QuatorFinalScoreCalculator(AnalyzedEmployeeInfoMatrix,2,Criterion_ComparisonMatrix_QuatorTwoThree,tendencyVector_QuatorTwo);
%Calculate Final Score Of Each Employee - Quator Three
singleScoreMatrix_QuatorThree= QuatorFinalScoreCalculator(AnalyzedEmployeeInfoMatrix,3,Criterion_ComparisonMatrix_SquareThree);
tendencyVector_QuatorThree = singleScoreMatrix_QuatorThree ./ singleScoreMatrix_QuatorTwo;
[finalScoreMatrix_QuatorThree,Factor_SchemeLayerComparisonMatrixQuatorThree] = QuatorFinalScoreCalculator(AnalyzedEmployeeInfoMatrix,3,Criterion_ComparisonMatrix_QuatorTwoThree,tendencyVector_QuatorThree);
%[finalScore_QuatorOne , finalOrder_QuatorOne] = sort(finalScoreMatrix_QuatorOne,'descend')
%[finalScore_QuatorTwo , finalOrder_QuatorTwo] = sort(finalScoreMatrix_QuatorTwo,'descend')
%[finalScore_QuatorThree , finalOrder_QuatorThree] = sort(finalScoreMatrix_QuatorThree,'descend')

%Calculate Final Score Of Each Employee - Three Quators
finalScoreMatrix = ZScoreNormalization(finalScoreMatrix_QuatorOne)+ZScoreNormalization(finalScoreMatrix_QuatorTwo)+ZScoreNormalization(finalScoreMatrix_QuatorThree);
%finalScoreMatrix = finalScoreMatrix_QuatorOne+finalScoreMatrix_QuatorTwo+finalScoreMatrix_QuatorThree;
[finalScore , finalRank] = sort(finalScoreMatrix,'descend');
a = [finalScore,finalRank]
%=====================================================================%
%Method One
%disp(AnalyzedEmployeeInfoMatrix(:,1,1));
%disp(AnalyzedEmployeeInfoMatrix(:,1,2));
%disp(AnalyzedEmployeeInfoMatrix(:,1,3));

tempFinalScoreMatrix =  AnalyzedEmployeeInfoMatrix(:,1,1) + AnalyzedEmployeeInfoMatrix(:,1,2) + AnalyzedEmployeeInfoMatrix(:,1,1);
[tempfinalScore , tempfinalRank] = sort(tempFinalScoreMatrix,'descend');

%Method Two
MissionScoreSum_QuatorOne = 0;
[eNum01,mNum01] = size(EMPLOYEESCOREMATRIX_QUATORONE);
for missionCounter_j = 1 : mNum01
    for employeeCounter_i = 1 : eNum01
        if EMPLOYEESCOREMATRIX_QUATORONE(employeeCounter_i,missionCounter_j) ~= -1
            MissionScoreSum_QuatorOne = MissionScoreSum_QuatorOne + SCOREMODEl_QUATORONE(missionCounter_j);
        end
    end
end
MissionScoreSum_QuatorOne;
tempScore_QuatorOne = AnalyzedEmployeeInfoMatrix(:,2,1) ./ MissionScoreSum_QuatorOne;

MissionScoreSum_QuatorTwo = 0;
[eNum02,mNum02] = size(EMPLOYEESCOREMATRIX_QUATORTWO);
for missionCounter_j = 1 : mNum02
    for employeeCounter_i = 1 : eNum02
        if EMPLOYEESCOREMATRIX_QUATORTWO(employeeCounter_i,missionCounter_j) ~= -1
            MissionScoreSum_QuatorTwo = MissionScoreSum_QuatorTwo + SCOREMODEl_QUATORTWO(missionCounter_j);
        end
    end
end
MissionScoreSum_QuatorTwo;
tempScore_QuatorTwo = AnalyzedEmployeeInfoMatrix(:,2,2) ./ MissionScoreSum_QuatorTwo;


MissionScoreSum_QuatorThree = 0;
[eNum03,mNum03] = size(EMPLOYEESCOREMATRIX_QUATORTHREE);
for missionCounter_j = 1 : mNum03
    for employeeCounter_i = 1 : eNum03
        if EMPLOYEESCOREMATRIX_QUATORTHREE(employeeCounter_i,missionCounter_j) ~= -1
            MissionScoreSum_QuatorThree = MissionScoreSum_QuatorThree + SCOREMODEl_QUATORTHREE(missionCounter_j);
        end
    end
end
MissionScoreSum_QuatorThree;
tempScore_QuatorThree = AnalyzedEmployeeInfoMatrix(:,2,3) ./ MissionScoreSum_QuatorThree;

tempFinalScore = tempScore_QuatorOne + tempScore_QuatorTwo + tempScore_QuatorThree;
[finalScoreT , finalRankT] = sort(tempFinalScore,'descend');
