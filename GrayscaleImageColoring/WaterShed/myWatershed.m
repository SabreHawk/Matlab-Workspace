
imName = 'colorImage05.jpg';
sourcePic = imread(imName);
grayPic = rgb2gray(sourcePic);
figure;
imshow(grayPic);
hy = fspecial('sobel');
hx = hy';
grayPicY = imfilter(double(grayPic),hy,'replicate');
grayPicX = imfilter(double(grayPic),hx,'replicate');
gradmag = sqrt(grayPicY.^2 + grayPicX.^2);
L = watershed(gradmag);
Lrgb = label2rgb(L);
figure;
imshow(Lrgb);