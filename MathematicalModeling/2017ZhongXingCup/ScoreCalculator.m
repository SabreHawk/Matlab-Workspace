%{
  File Illustration:
  Creation Time : 2017/6/4
  Creator : SabreHawk - Zhiquan Wang
 
  TimeStep  |    Author     |  Comment
  2017/6/4  | Zhiquan Wang  | Complete Function : Calculate Score And
                                                  Percentage Of Each Emplyee Of Each Quator
  2017/6/5  | Zhiquan Wang  | Complete Function : Calculate
                                                  Horizontal Comparison Degree
  2017/6/8  | Zhiquan Wang  | Modify Function : Factor Di
  Script Illustration:
  Function:
   Calculate The Employee's Score , Percentage And Horizontal Comparison
   Degree Of Each Quator
  Method:
    
%}


%1)Calcualte Each Employee's Di Score & Score & Rate
function resultMatrix = ScoreCalculator(inputScoreMatrix,inputScoreModel)
[employeeNum, missionNum] = size(inputScoreMatrix);
resultMatrix = zeros(employeeNum,3);
%1.1)Calculate The Percentage Of Completion Of Mission & Score
for employeeCounter_i = 1 : employeeNum
    totalScore = 0;
    score = 0;
    for missionCounter_j = 1 : missionNum
        if inputScoreMatrix(employeeCounter_i,missionCounter_j) ~= -1
            totalScore = totalScore + inputScoreModel(missionCounter_j);
            if inputScoreMatrix(employeeCounter_i,missionCounter_j) > inputScoreModel(missionCounter_j)
                inputScoreMatrix(employeeCounter_i,missionCounter_j)  = inputScoreModel(missionCounter_j);
            end
            score = score + inputScoreMatrix(employeeCounter_i,missionCounter_j);
        end
    end
    resultMatrix(employeeCounter_i,1) = score/totalScore;
    resultMatrix(employeeCounter_i,2) = score;
end

%1.2)Calculate The Horizontal Comparison Degree Compared By Employees Under The Same Mission
horizontalComparisonDegreeMatrix = zeros(employeeNum,missionNum);
ASumScore = 0; %The Sum Of Missions Of All The Employee
for missionCounter_j = 1 : missionNum
    singleMissionScoreSum = 0;
    singleMissionNum = 0;
    singleMissionMaxScore =  max(inputScoreMatrix(:,missionCounter_j));
    for employeeCounter_i = 1 : employeeNum
        if inputScoreMatrix(employeeCounter_i,missionCounter_j) ~= -1
            singleMissionScoreSum = singleMissionScoreSum + inputScoreMatrix(employeeCounter_i,missionCounter_j);
            singleMissionNum = singleMissionNum + 1;
            ASumScore = ASumScore + inputScoreModel(missionCounter_j);
        end
    end
    singleMissionAverageScore = singleMissionScoreSum / singleMissionNum;
    for employeeCounter_ii = 1 : employeeNum
        if inputScoreMatrix(employeeCounter_ii,missionCounter_j) ~= -1
            horizontalComparisonDegreeMatrix(employeeCounter_ii,missionCounter_j) = ((inputScoreMatrix(employeeCounter_ii,missionCounter_j)/singleMissionAverageScore) - 1 ) * (singleMissionAverageScore / singleMissionMaxScore) + 1;
            if singleMissionAverageScore == 0
                horizontalComparisonDegreeMatrix(employeeCounter_ii,missionCounter_j) = 0;
            end
        else
            horizontalComparisonDegreeMatrix(employeeCounter_ii,missionCounter_j) = -1;
        end
    end
end
%horizontalComparisonDegreeMatrix
%Summarize Horizontal Comparison Matrix To A Final Comparison Degree Vector
for employeeCounter_i = 1 : employeeNum
    tempMissionNum = 0;
    for missionCounter_j = 1 : missionNum
        if horizontalComparisonDegreeMatrix(employeeCounter_i,missionCounter_j) ~= -1
            resultMatrix(employeeCounter_i,3) = resultMatrix(employeeCounter_i,3) + horizontalComparisonDegreeMatrix(employeeCounter_i,missionCounter_j);
            tempMissionNum = tempMissionNum + 1;
        end
    end
    resultMatrix(employeeCounter_i,3) = resultMatrix(employeeCounter_i,3) / tempMissionNum;
end
resultMatrix(:,2) = resultMatrix(:,2) ./ ASumScore;
