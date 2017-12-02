function [SoundWaveCrossEllipseTimeVector] = SoundWaveCrossTimeVectorProducer(LaunchPosition)
ReceiverPositionMatrix = accepter_matrix;
ReceiverPositionSize = size(ReceiverPositionMatrix);
SoundWaveCrossEllipseTimeVector = zeros(1,ReceiverPositionSize(1));
for lineCounter = 1 : ReceiverPositionSize(1)
    SoundWaveCrossEllipseTimeVector(lineCounter) = EllipseCrossTimeCalculator(LaunchPosition,ReceiverPositionMatrix(lineCounter,:));
end
SoundWaveCrossEllipseTimeVector = SoundWaveCrossEllipseTimeVector';