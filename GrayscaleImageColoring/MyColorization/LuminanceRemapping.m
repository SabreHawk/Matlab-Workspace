function outImageMatrix = LuminanceRemapping(inImageMatrix01,inImageMatrix02)
AveLValue01 = 0;
AveLValue02 = 0;
StandardDeviation01 = 0;
StandardDeviation02 = 0;

[ImageHeight01,ImageWidth01,h01] = size(inImageMatrix01);
[ImageHeight02,ImageWidth02,h02] = size(inImageMatrix02);

for Height_i = 1 : ImageHeight01
    for Width_j = 1 : ImageWidth01
        AveLValue01 = AveLValue01 + inImageMatrix01(Height_i,Width_j,1);
    end
end
for Height_i = 1 : ImageHeight02
    for Width_j = 1 : ImageWidth02
        AveLValue01 = AveLValue02 + inImageMatrix02(Height_i,Width_j,1);
    end
end
AveLValue01 = AveLValue01 / (ImageHeight01 * ImageWidth01);
AveLValue02 = AveLValue02 / (ImageHeight02 * ImageWidth02);

for Height_i = 1 :ImageHeight01
    for Width_j = 1 : ImageWidth01
        StandardDeviation01 = StandardDeviation01 + (inImageMatrix01(Height_i,Width_j,1) - AveLValue01)^2;
    end
end

for Height_i = 1 :ImageHeight02
    for Width_j = 1 : ImageWidth02
        StandardDeviation02 = StandardDeviation02 + (inImageMatrix02(Height_i,Width_j,1) - AveLValue02)^2;
    end
end

StandardDeviation01 = sqrt(StandardDeviation01/(ImageHeight01 * ImageWidth01));
StandardDeviation02 = sqrt(StandardDeviation02/(ImageHeight02 * ImageWidth02));
outImageMatrix = inImageMatrix02;
for Height_i = 1 : ImageHeight02
    for Width_j = 1 : ImageWidth02
        outImageMatrix(Height_i,Width_j,1) = (inImageMatrix02(Height_i,Width_j,1) - AveLValue02) * (StandardDeviation01 / StandardDeviation02) + AveLValue01;
    end
end





