function [d]=main(jpg)
close all
clc
[filename,filepath]=uigetfile('.jpg','输入一个需要识别的车牌图像');
file=strcat(filepath,filename); 
I=imread(file);
figure(1),imshow(I);title('原图')
I1=rgb2gray(I);
figure(2),subplot(1,2,1),imshow(I1);title('灰度图');
figure(2),subplot(1,2,2),imhist(I1);title('灰度图直方图');
%I1=medfilt2(I1);
%figure,imshow(I1);title('中值滤波');
I2=edge(I1,'roberts',0.15,'both'); 
figure(3),imshow(I2);title('robert算子边缘检测')
se=[1;1;1];
I3=imerode(I2,se);
figure(4),imshow(I3);title('腐蚀后图像');
se=strel('rectangle',[25,25]);
I4=imclose(I3,se);
figure(5),imshow(I4);title('平滑图像的轮廓');
I5=bwareaopen(I4,2000);
figure(6),imshow(I5);title('从对象中移除小对象');
[y,x,z]=size(I5);
myI=double(I5);
tic
 Blue_y=zeros(y,1);
 for i=1:y
    for j=1:x
             if(myI(i,j,1)==1) 
 
                Blue_y(i,1)= Blue_y(i,1)+1;
            end  
     end       
 end
 [temp MaxY]=max(Blue_y);
 PY1=MaxY;
 while ((Blue_y(PY1,1)>=5)&&(PY1>1))
        PY1=PY1-1;
 end    
 PY2=MaxY;
 while ((Blue_y(PY2,1)>=5)&&(PY2<y))
        PY2=PY2+1;
 end
 IY=I(PY1:PY2,:,:);
 %%%%%% X方向 %%%%%%%%%
 Blue_x=zeros(1,x);
 for j=1:x
     for i=PY1:PY2
            if(myI(i,j,1)==1)
                Blue_x(1,j)= Blue_x(1,j)+1;               
            end  
     end       
 end
 
 PX1=1;
 while ((Blue_x(1,PX1)<3)&&(PX1<x))
       PX1=PX1+1;
 end    
 PX2=x;
 while ((Blue_x(1,PX2)<3)&&(PX2>PX1))
        PX2=PX2-1;
 end
 PX1=PX1-1;
 PX2=PX2+1;
  dw=I(PY1:PY2-8,PX1:PX2,:);
 t=toc; 
%figure(17),subplot(1,2,1),imshow(IY),title('行方向合理区域');
%figure(17),subplot(1,2,2),imshow(dw),title('定位剪切后的彩色车牌图像')
imwrite(dw,'dw.jpg');
[fn,pn,fi]=uigetfile('dw.jpg','输入一个定位裁剪后的车牌图像');
I=imread([pn fn]);
jpg=strcat(filepath,filename);
a=imread('dw.jpg');
b=rgb2gray(a);
imwrite(b,'1.车牌灰度图像.jpg');
%figure(18);subplot(3,2,1),imshow(b),title('1.车牌灰度图像')
g_max=double(max(max(b)));
g_min=double(min(min(b)));
T=round(g_max-(g_max-g_min)/3); 
[m,n]=size(b);
d=(double(b)>=T);  
imwrite(d,'2.车牌二值图像.jpg');
%figure(18);subplot(3,2,2),imshow(d),title('2.车牌二值图像')
%figure(18),subplot(3,2,3),imshow(d),title('3.均值滤波前')
 
 
h=fspecial('average',3);
d=im2bw(round(filter2(h,d)));
imwrite(d,'4.均值滤波后.jpg');
%figure(9),subplot(3,2,4),imshow(d),title('4.均值滤波后')
 
 
% se=strel('square',3);  
% 'line'/'diamond'/'ball'...
se=eye(2); % eye(n) returns the n-by-n identity matrix 单位矩阵
[m,n]=size(d);
if bwarea(d)/m/n>=0.365
    d=imerode(d,se);
elseif bwarea(d)/m/n<=0.235
    d=imdilate(d,se);
end
imwrite(d,'5.膨胀或腐蚀处理后.jpg');
%figure(18),subplot(3,2,5),imshow(d),title('5.膨胀或腐蚀处理后')
 
 
d=qiege(d);
[m,n]=size(d);
figure,subplot(2,1,1),imshow(d),title(n)
k1=1;k2=1;s=sum(d);j=1;
while j~=n
    while s(j)==0
        j=j+1;
    end
    k1=j;
    while s(j)~=0 && j<=n-1
        j=j+1;
    end
    k2=j-1;
    if k2-k1>=round(n/6.5)
        [val,num]=min(sum(d(:,[k1+5:k2-5])));
        d(:,k1+num+5)=0;  
    end
end
% 再切割
d=qiege(d);
% 切割出 7 个字符
y1=10;y2=0.25;flag=0;word1=[];
while flag==0
    [m,n]=size(d);
    left=1;wide=0;
    while sum(d(:,wide+1))~=0
        wide=wide+1;
    end
    if wide<y1   
        d(:,[1:wide])=0;
        d=qiege(d);
    else
        temp=qiege(imcrop(d,[1 1 wide m]));
        [m,n]=size(temp);
        all=sum(sum(temp));
        two_thirds=sum(sum(temp([round(m/3):2*round(m/3)],:)));
        if two_thirds/all>y2
            flag=1;word1=temp;   
        end
        d(:,[1:wide])=0;d=qiege(d);
    end
end
 
[word2,d]=getword(d);
 
[word3,d]=getword(d);
 
[word4,d]=getword(d);
 
[word5,d]=getword(d);
 
[word6,d]=getword(d);
 
[word7,d]=getword(d);
subplot(5,7,1),imshow(word1),title('1');
subplot(5,7,2),imshow(word2),title('2');
subplot(5,7,3),imshow(word3),title('3');
subplot(5,7,4),imshow(word4),title('4');
subplot(5,7,5),imshow(word5),title('5');
subplot(5,7,6),imshow(word6),title('6');
subplot(5,7,7),imshow(word7),title('7');
[m,n]=size(word1);
 
 
word1=imresize(word1,[40 20]);
word2=imresize(word2,[40 20]);
word3=imresize(word3,[40 20]);
word4=imresize(word4,[40 20]);
word5=imresize(word5,[40 20]);
word6=imresize(word6,[40 20]);
word7=imresize(word7,[40 20]);
 
subplot(5,7,15),imshow(word1),title('1');
subplot(5,7,16),imshow(word2),title('2');
subplot(5,7,17),imshow(word3),title('3');
subplot(5,7,18),imshow(word4),title('4');
subplot(5,7,19),imshow(word5),title('5');
subplot(5,7,20),imshow(word6),title('6');
subplot(5,7,21),imshow(word7),title('7');
imwrite(word1,'1.jpg');
imwrite(word2,'2.jpg');
imwrite(word3,'3.jpg');
imwrite(word4,'4.jpg');
imwrite(word5,'5.jpg');
imwrite(word6,'6.jpg');
imwrite(word7,'7.jpg');
liccode=char(['0':'9' 'A':'Z' '辽粤豫鄂鲁陕京津']);%京津沪渝冀豫云辽黑湘皖鲁新苏浙赣鄂桂甘晋蒙陕吉闽贵粤青藏川宁琼
SubBw2=zeros(40,20);
l=1;
for I=1:7;
    ii=int2str(I);
    t=imread([ii,'.jpg']);
    SegBw2=imresize(t,[40 20],'nearest');
    SegBw2=double(SegBw2)>20;
    if l==1 %第一位汉字识别
        kmin=37;
        kmax=43;
    elseif l==2 %第二位字母识别
        kmin=11;
        kmax=36;
    else l>=3   %第三位后字母或数字识别
        kmin=1;
        kmax=36;
    end
    for k2=kmin:kmax
        fname=strcat('字符模板\',liccode(k2),'.jpg');
        SamBw2=imread(fname);
        SamBw2=double(SamBw2)>1;
        for i=1:40
            for j=1:20
                SubBw2(i,j)=SegBw2(i,j)-SamBw2(i,j);
            end
        end
        %相当于两幅图相减得第三幅图

        Dmax=0;%统计两幅图像不同点个数，并保存下来
        for k1=1:40;
            for l1=1:20
                if(SubBw2(k1,l1)>0 | SubBw2(k1,l1)<0)
                    Dmax=Dmax+1;
                end
            end
        end
        Error(k2)=Dmax;
    end

    Error1=Error(kmin:kmax);%找到图像差别最少的
    MinError=min(Error1);
    findc=find(Error1==MinError);

    Code(l*2-1)=liccode(findc(1)+kmin-1);%根据图像，找到对应的字库
    Code(l*2)=' ';
    l=l+1;
end
figure;
imshow(dw),title(['车牌号码：',Code],'Color','b');
