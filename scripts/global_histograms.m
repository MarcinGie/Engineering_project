
% wczytanie obrazu testowego, zapis do struktury R, nast?pnie wst?pne
% przetwarzanie, zastosowanie pierwszego okre?lonego arbitralnie progu, i pierwsza
% binaryzacja obrazów


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Wyciete\';
spis_tst = 'pliki.txt'; % spis plikow do testowania

fil_tst = fopen([sciezka_data spis_tst]);

%ladowanie, przyciecie i zmniejszenie zdjec
for eee=1:16
    nazwa_tst =fgetl(fil_tst);
    Obraz=imread([sciezka_data nazwa_tst]);
    [a,b,c]=size(Obraz);
    rozmiar_znaku=0;
    Znak=zeros(a,b,c);
    Znak=uint8(Znak);
    for x=1:a
        for y=1:b
            if  ~(Obraz(x,y,1)==255 && Obraz(x,y,2)==255 && Obraz(x,y,3)==255)
                rozmiar_znaku=rozmiar_znaku+1;
                Znak(x,y,1)=Obraz(x,y,1);
                Znak(x,y,2)=Obraz(x,y,2);
                Znak(x,y,3)=Obraz(x,y,3);
            end
        end
    end
    
    Or_hsv=rgb2hsv(Obraz);
%     figure;
%     subplot(1,3,1);
%     imshow(Obraz);
%     subplot(1,3,2);
%     imshow(Or_hsv);
%     subplot(1,3,3);
%     imshow(Znak);
    Or_h=uint8(ceil(Or_hsv(:,:,1)*255));
    Or_s=uint8(ceil(Or_hsv(:,:,2)*255));
    Or_v=uint8(ceil(Or_hsv(:,:,3)*255));
    H=zeros(1,rozmiar_znaku);
    S=zeros(1,rozmiar_znaku);
    V=zeros(1,rozmiar_znaku);
    i=0;
    for x=1:a
        for y=1:b
            if ~(Obraz(x,y,1)==255 && Obraz(x,y,2)==255 && Obraz(x,y,3)==255)
                i=i+1;
                H(i)=Or_h(x,y);
                S(i)=Or_s(x,y);
                V(i)=Or_v(x,y);
            end
        end
    end
    H_res=zeros(1,256);
    S_res=zeros(1,256);
    V_res=zeros(1,256);
    for i=1:rozmiar_znaku
        H_res(H(i)+1)=H_res(H(i)+1)+1;
        S_res(S(i)+1)=S_res(S(i)+1)+1;
        V_res(V(i)+1)=V_res(V(i)+1)+1;
    end
    Z(eee,1).H=H_res;
    Z(eee,1).S=S_res;
    Z(eee,1).V=V_res;
    t=sprintf('%d',rozmiar_znaku);
%     figure;
%     title(t);
%     subplot(3,1,1);
%     plot(H_res,'filled');
%     subplot(3,1,2);
%     plot(S_res,'filled');
%     subplot(3,1,3);
%     plot(V_res,'filled');
    fprintf('Zdjecie %s iteracja %d z 16 gotowa rozmiar %d\n', nazwa_tst, eee, rozmiar_znaku)
end

% figure;
% i=0;
% for eee=1:16
%     subplot(16,3,eee+i);
%     stem(Z(eee,1).H,'Marker','None'),title('Hue');
%     axis([0 256 0 inf]);
%     subplot(16,3,eee+i+1);
%     stem(Z(eee,1).S,'Marker','None'),title('Saturation');
%     axis([0 256 0 inf]);
%     subplot(16,3,eee+i+2);
%     stem(Z(eee,1).V,'Marker','None'),title('Value');
%     axis([0 256 0 inf]);
%     i=i+2;
% end

% figure;
% i=0;
% for eee=9:16
%     subplot(8,3,eee+i-8);
%     stem(Z(eee,1).H,'Marker','None'),title('Hue');
%     axis([0 256 0 inf]);
%     subplot(8,3,eee+i-7);
%     stem(Z(eee,1).S,'Marker','None'),title('Saturation');
%     axis([0 256 0 inf]);
%     subplot(8,3,eee+i-6);
%     stem(Z(eee,1).V,'Marker','None'),title('Value');
%     axis([0 256 0 inf]);
%     i=i+2;
% end

figure;
i=0;
for eee=1:16
    max(Z(eee,1).H)/sum(Z(eee,1).H)
    subplot(16,1,eee);
    stem(Z(eee,1).S,'Marker','.');
    axis([100 240 1 inf]);
end

toc