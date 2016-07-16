close all, clear all;
delimiterIn = ' ';
fileID = fopen('scalone_1-6_3Dkor.data');
Cdata=textscan(fileID,'%f %f %f %s');
H=ceil(Cdata{1}*255);
S=ceil(Cdata{2}*255);
V=ceil(Cdata{3}*255);
H_res=zeros(1,256);
S_res=zeros(1,256);
V_res=zeros(1,256);
for i=1:226384
    res=Cdata{4}{i};
    if strcmp(res,'W11p')
        H_res(H(i)+1)=H_res(H(i)+1)+1;
        S_res(S(i)+1)=S_res(S(i)+1)+1;
        V_res(V(i)+1)=V_res(V(i)+1)+1;
    end
end
[a,b]=size(H_res);
figure;
stem(H_res,'filled'),title('Hue');
figure;
stem(S_res,'filled'),title('Saturation');
figure;
stem(V_res,'filled'),title('Value');

H_fin=zeros(1,256);
S_fin=zeros(1,256);
V_fin=zeros(1,256);
for i=1:226384
    if (H(i)>=11 && H(i)<= 15)
        res=Cdata{4}{i};
        if strcmp(res,'W11p')
            H_fin(H(i)+1)=H_fin(H(i)+1)+1;
            S_fin(S(i)+1)=S_fin(S(i)+1)+1;
            V_fin(V(i)+1)=V_fin(V(i)+1)+1;
        end
    end
end

figure;
stem(H_fin,'filled'),title('Hue');
figure;
stem(S_fin,'filled'),title('Saturation');
figure;
stem(V_fin,'filled'),title('Value');