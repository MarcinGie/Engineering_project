% przeszukuje obrazy w trzech petlach zmiany
% progu znajduj?c obszary zainteresowania do dalszego przetwarzania w
% oryginalnej rozdzielczo?ci. Ustala ostateczn? wielko?? BoundingBox 

tic

close all;
warning('off','all'); %pojawialy sie tylko warningi o pustych klastrach

dysk = strel('disk',2); 
dysk_2=strel('disk',6);
mimj_ideal=0.267;
fa_ideal=0.85;
il_zdjec=6;

% R(eee,1).hueThresholdLow = double(0/255);
% R(eee,1).hueThresholdHigh = double(30/255);
% R(eee,1).saturationThresholdLow = double(0/255);
% R(eee,1).saturationThresholdHigh = double(255/255);
% R(eee,1).valueThresholdLow = double(0/255);
% R(eee,1).valueThresholdHigh = double(255/255);

for eee=6:il_zdjec %dla kazdego zdjecia
    R(eee,1).h=zeros(1,255);
    R(eee,1).s=zeros(1,255);
    R(eee,1).v=zeros(1,255);
    if R(eee,1).t==1
        
        znaleziono_znak=0;
        fprintf('\nZDJECIE %d',eee);
        
        for h=0:1
            fprintf('\nh=%d',h);
            
            for s=0:255 %dla kazdego klastra
                fprintf(' s=%d',s);
                for v=0:255 %dla kazdego obiektu w klastrze
                   
                    % Convert RGB image to HSV
                    hsvImage = R(eee,1).Or_hsv;
                    % Extract out the H, S, and V images individually
                    hImage = hsvImage(:,:,1);
                    sImage = hsvImage(:,:,2);
                    vImage = hsvImage(:,:,3);

                    % Now apply each color band's particular thresholds to the color band
                    hueMask = (hImage == h) ;
                    saturationMask = (sImage == s);
                    valueMask = (vImage == v);

                    % Combine the masks to find where all 3 are "true."
                    orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);
                    
%                     DYL = imdilate(orangeObjectsMask,dysk); %dylatacja tylko po to, zeby polaczyc obszary lezce blisko w jeden
%                     P_WDZ = imfill(DYL, 'holes'); %wypelnienie dziur
                    IL=bwlabel(orangeObjectsMask);
                    STATS = regionprops(IL, 'BoundingBox'); 
                    R(eee,1).STATS=STATS;
                    [a,b]=size(STATS);
                    
                    for j=1:a
                    bb_pow= STATS(j,1).BoundingBox; %pierwszy zakres przetwarzania
                    WYCINEK=imcrop(IL, bb_pow);

                    B1 = bwareaopen(WYCINEK, 200); % usuniecie malych obiektów
                    IL_OB=bwlabel(B1,8);
                    if nnz(IL_OB)>0
                        stat_at=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
                        poloz_at=find([stat_at.Area] == max([stat_at.Area])); %znalezienie najwiekszego obiektu
                        [fa1_at,fa2_at]=size(stat_at(poloz_at,1).FilledImage); %pobranie rozmiarów bounding box obiektu
                        FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at); %czesc obszaru zajeta przez znak
                        mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength; %stusunek dlugosci boków
                        if stat_at(poloz_at,1).Orientation<-85 || stat_at(poloz_at,1).Orientation>85 %kat miedzy elipsa najwiekszego obiektu a osia X
                            pr_fa_at=0.60;
                        else
                            pr_fa_at=0.30;
                        end
            
                        if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at && stat_at(poloz_at,1).Area>6500
                                    fprintf('(1)');
                                    R(eee,1).h(h)=1;
                                    R(eee,1).s(s)=1;
                                    R(eee,1).v(v)=1;
                        else
                            fprintf('(0)');
                            R(eee,1).bz=1;
                        end
                         clearvars -except h s v R il_zdjec eee dysk dysk_2 mimj_ideal fa_ideal bb_pow proba proba2 STATS znaleziono_znak IL nColors
                    end
                end
                
                end
            end
        end
    end
end

H=zeros(1,255);
S=zeros(1,255);
V=zeros(1,255);

for eee=6:il_zdjec
    H=H+R(eee,1).h;
    S=S+R(eee,1).s;
    V=V+R(eee,1).v;
end
figure;
subplot(3,1,1);
plot(H);
subplot(3,1,2);
plot(S);
subplot(3,1,3);
plot(V);

toc
clearvars -except R
