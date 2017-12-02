%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++Reinhard算法++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%=========================打开参考文件==============
clc
clear
Ref=double(imread('colorImage05.jpg'));

RefR=Ref(:,:,1);
RefG=Ref(:,:,2);
RefB=Ref(:,:,3);
%=========================打开源文件==============
Sou=double(imread('desImage05.jpg'));
SouR=Sou(:,:,1);
SouG=Sou(:,:,2);
SouB=Sou(:,:,3);
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
imshow(imread('colorImage05.jpg'));
figure;
imshow(imread('desImage05.jpg'));
figure;
%++++++++++++++++++++++++++转换到lab空间+++++++++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%===============================定义转换函数===============================
con1=[0.3811,0.5783,0.0402;
      0.1967,0.7244,0.0782;
      0.0241,0.1288,0.8444];
con2=[1 1 1;1 1 -2;1 -1 0];
con3=[1/sqrt(3) 0 0;0 1/sqrt(6) 0;0 0 1/sqrt(2)];
%============================参考图像转到lab空间============================
[width,height,depth]=size(Ref);
l1=zeros(width,height);
alpha1=zeros(width,height);
beta1=zeros(width,height);
%================转到LMS==============%
L1=zeros(width,height);
M1=zeros(width,height);
S1=zeros(width,height);
for i=1:width
    for j=1:height
        m=con1*[RefR(i,j);RefG(i,j);RefB(i,j)];
        L1(i,j)=m(1);
        M1(i,j)=m(2);
        S1(i,j)=m(3);
    end
end
%================取LMS对数============%
L1=log10(L1);
M1=log10(M1);
S1=log10(S1);
%==============转至lab空间============%
for i=1:width
    for j=1:height
        m=con3*con2*[L1(i,j);M1(i,j);S1(i,j)];
        l1(i,j)=m(1);
        alpha1(i,j)=m(2);
        beta1(i,j)=m(3);
    end
end

pic = cat(3,l1,alpha1,beta1);
imshow(pic);
%=============================源图像转到lab空间============================
[wid,hei,dep]=size(Sou);
l2=zeros(wid,hei);
alpha2=zeros(wid,hei);
beta2=zeros(wid,hei);
%================中转到LMS==============%
L2=zeros(wid,hei);
M2=zeros(wid,hei);
S2=zeros(wid,hei);
for i=1:wid
    for j=1:hei        
        m=con1*[SouR(i,j);SouG(i,j);SouB(i,j)];
        L2(i,j)=m(1);
        M2(i,j)=m(2);
        S2(i,j)=m(3);
    end
end
%===============取LMS对数=============%
L2=log10(L2);
M2=log10(M2);
S2=log10(S2);
%==============转至lab空间============%
for i=1:wid
    for j=1:hei
        m=con3*con2*[L2(i,j);M2(i,j);S2(i,j)];
        l2(i,j)=m(1);
        alpha2(i,j)=m(2);
        beta2(i,j)=m(3);
    end
end
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++在lab空间进行改变+++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%=========================求取参考图像各种均值===========================
lm1=mean(mean(l1));
am1=mean(mean(alpha1));
bm1=mean(mean(beta1));
%=========================求取源图像各种均值===========================
lm2=mean(mean(l2));
am2=mean(mean(alpha2));
bm2=mean(mean(beta2));
%=========================求取参考图像各种标准方差===========================
sigm1=0;
for i=1:width
    for j=1:height
        sigm1=sigm1+(l1(i,j)-lm1)^2;
    end
end

sigm1=sqrt(sigm1);
sigm2=0;
for i=1:width
    for j=1:height
        sigm2=sigm2+(alpha1(i,j)-am1)^2;
    end
end
sigm2=sqrt(sigm2);
sigm3=0;
for i=1:width
    for j=1:height
        sigm3=sigm3+(beta1(i,j)-bm1)^2;
    end
end
sigm3=sqrt(sigm3);
%==========================求取源图像各种标准方差============================
sigm11=0;
for i=1:wid
    for j=1:hei
        sigm11=sigm11+(l2(i,j)-lm2)^2;
    end
end
sigm11=sqrt(sigm11);
sigm22=0;
for i=1:wid
    for j=1:hei
        sigm22=sigm22+(alpha2(i,j)-am2)^2;
    end
end
sigm22=sqrt(sigm22);
sigm33=0;
for i=1:wid
    for j=1:hei
        sigm33=sigm33+(beta2(i,j)-bm2)^2;
    end
end
sigm33=sqrt(sigm33);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++求取目标图像的lab+++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
l3=zeros(wid,hei);
alpha3=zeros(wid,hei);
beta3=zeros(wid,hei);
for i=1:wid
    for j=1:hei
        l3(i,j)=(l2(i,j)-lm2)*sigm1/sigm11+lm1;
        alpha3(i,j)=(alpha2(i,j)-am2)*sigm2/sigm22+am1;
        beta3(i,j)=(beta2(i,j)-bm2)*sigm3/sigm33+bm1;
    end
end
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%+++++++++++++++++++++++++++++++反变换到LMS++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


L3=zeros(wid,hei);
M3=zeros(wid,hei);
S3=zeros(wid,hei);
for i=1:wid
    for j=1:hei
        m=inv(con3*con2)*[l3(i,j);alpha3(i,j);beta3(i,j)];
        L3(i,j)=m(1);
        M3(i,j)=m(2);
        S3(i,j)=m(3);
    end
end
%==================================LMS取指数===============================
L3=power(10,L3);
M3=power(10,M3);
S3=power(10,S3);
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++转换到RGB++++++++++++++++++++++++++++++++++++++
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
TarR=zeros(wid,hei);
TarG=zeros(wid,hei);
TarB=zeros(wid,hei);
for i=1:wid
    for j=1:hei
        m=inv(con1)*[L3(i,j);M3(i,j);S3(i,j)];
        TarR(i,j)=m(1);
        if TarR(i,j)>255
           TarR(i,j)=255; 
        elseif TarR(i,j)<0
           TarR(i,j)=0;  
        end
        TarG(i,j)=m(2);
        if TarG(i,j)>255
           TarG(i,j)=255; 
        elseif TarG(i,j)<0
           TarG(i,j)=0;  
        end
        TarB(i,j)=m(3);
        if TarB(i,j)>255
           TarB(i,j)=255; 
        elseif TarB(i,j)<0
           TarB(i,j)=0;  
        end        
    end
end
Tar=uint8(cat(3,TarR,TarG,TarB));
imshow(Tar);