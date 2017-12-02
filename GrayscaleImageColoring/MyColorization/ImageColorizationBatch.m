desImage = "desImage";
souImage = "souImage";
ID = '01';

for id = 10:17
    ID  = int2str(id);
    if id<10
        ID = ['0',ID];
    end
    desImageName = ['desImage',ID,'.jpg'];
    souImageName = ['colorImage',ID,'.jpg'];
    desImageMatrix = imread(desImageName);
    souImageMatrix =  imread(souImageName);
    disp(['------Start Colorization - ',ID]);
    imageColorization(desImageMatrix,souImageMatrix,0.2);
end