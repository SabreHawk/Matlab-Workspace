function CubeCentrePositionMatrix = CubeCentreProducer(a,b,c)
if nargin == 0
    EllipseA = 20;
    EllipseB = 10;
    EllipseC = 10;
end
cubeCounter = 1;
for xCounter = -EllipseA:EllipseA
    for yCounter = -EllipseB:EllipseB
        for zCounter = -EllipseC:EllipseC
            if xCounter^2 / EllipseA^2 + yCounter^2 /EllipseB^2+ zCounter^2 /EllipseC^2 <= 1
                CubeCentrePositionMatrix(cubeCounter,:) = [xCounter,yCounter,zCounter];
                cubeCounter = cubeCounter + 1;
            end
        end
    end
end
