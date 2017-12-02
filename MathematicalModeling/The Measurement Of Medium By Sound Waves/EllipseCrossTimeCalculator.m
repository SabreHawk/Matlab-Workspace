function [TotalCrossTime] = EllipseCrossTimeCalculator(launchPosition,receiverPosition)
SpherePropagationVelocity = 10;
EllipsePropagationVelocity = 20;
SphereCentrePosition = [0 0 0];
SphereRadius = 5;
LaunchLineVector = launchPosition - receiverPosition;
LaunchLineLength = sqrt(LaunchLineVector(1)^2 + LaunchLineVector(2)^2 + LaunchLineVector(3)^2);
ReceiverToCentreVector = SphereCentrePosition - receiverPosition;
ReceiverToCentreLength = sqrt(ReceiverToCentreVector(1)^2+ReceiverToCentreVector(2)^2+ReceiverToCentreVector(3)^2);

CentreProjectionLength = ReceiverToCentreLength * (LaunchLineVector * ReceiverToCentreVector') / (LaunchLineLength * ReceiverToCentreLength);
CentreToLineLength = sqrt(ReceiverToCentreLength^2 - CentreProjectionLength^2);
SphereCrossLength = 2 * sqrt( SphereRadius^2 - CentreToLineLength^2);
if SphereRadius - CentreToLineLength < 0
    SphereCrossLength = 0;
    %disp("Didn't Touch Sphere");
end
EllipseCrossLength = LaunchLineLength - SphereCrossLength;
EllipseCrossTime = EllipseCrossLength / EllipsePropagationVelocity;
SphereCrossTime = SphereCrossLength / SpherePropagationVelocity;
TotalCrossTime = EllipseCrossTime + SphereCrossTime;


