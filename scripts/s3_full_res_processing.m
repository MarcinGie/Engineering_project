
% przetwarzanie w zakresie BoundingBox znalezionego w etapie r_2
% na pe?nej rozdzielczo?ci. Doprecyzowanie wysoko?ci progu i ostateczna
% decyzja czy mamy do czynienia ze znakiem

tic
close all;

sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\obrazy-uczenie\';

dysk = strel('disk',2); 
dysk_2=strel('disk',6);
mimj_ideal=0.25;
fa_ideal=0.85;

for eee=1:14
	[a,b]=size(R(eee,1).W);
    z=0;
    for j=1:a 
        if R(eee,1).W(j,1).bz==0
            z=z+1;
        	% przeliczenie BoundingBox z ukladu mniejszej rozdzielczosci na wieksza
            R(eee,1).TZ(z,1).BB=4*R(eee,1).W(j,1).bb;
            R(eee,1).TZ(z,1).Ow=imcrop(R(eee,1).O,R(eee,1).TZ(z,1).BB);
            Ow_hsv=rgb2hsv(R(eee,1).TZ(z,1).Ow);
            
            R(eee,1).TZ(z,1).Ow_hsv=Ow_hsv;
            
%             R(eee,1).T(z,1).hueThresholdLow=R(eee,1).W(j,1).hueThresholdLow;
%             R(eee,1).T(z,1).hueThresholdHigh=R(eee,1).W(j,1).hueThresholdHigh;
%             R(eee,1).T(z,1).saturationThresholdLow=R(eee,1).W(j,1).saturationThresholdLow;
%             R(eee,1).T(z,1).saturationThresholdHigh=R(eee,1).W(j,1).saturationThresholdHigh;
%             R(eee,1).T(z,1).valueThresholdLow=R(eee,1).W(j,1).valueThresholdLow;
%             R(eee,1).T(z,1).valueThresholdHigh=R(eee,1).W(j,1).valueThresholdHigh;
%              
%             progowanie;
%             
%             Convert RGB image to HSV
%             hsvImage = R(eee,1).TZ(z,1).Ow_hsv;
%             Extract out the H, S, and V images individually
%             hImage = hsvImage(:,:,1);
%             sImage = hsvImage(:,:,2);
%             vImage = hsvImage(:,:,3);
% 
%             Now apply each color band's particular thresholds to the color band
%             hueMask = (hImage >= double(R(eee,1).T(z,1).hueThresholdLow/255)) & (hImage <= double(R(eee,1).T(z,1).hueThresholdHigh/255));
%             saturationMask = (sImage >= double(R(eee,1).T(z,1).saturationThresholdLow/255)) & (sImage <= double(R(eee,1).T(z,1).saturationThresholdHigh/255));
%             valueMask = (vImage >= double(R(eee,1).T(z,1).valueThresholdLow/255)) & (vImage <= double(R(eee,1).T(z,1).valueThresholdHigh/255));
% 
%             Combine the masks to find where all 3 are "true."
%             orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);
%             
%             R(eee,1).T(z,1).K1_ost=orangeObjectsMask;
%             
%             figure;
%             subplot(1,2,1);
%             imshow(R(eee,1).W(j,1).SPR);
%             subplot(1,2,2);
%             imshow(R(eee,1).T(z,1).K1_ost,[]);
            
        end
    end
     fprintf('\nBoundingBox przeliczone. Iteracja %d z 14 gotowa Z=%d\n', eee,z);
end
%
for eee=1:14
    fprintf('\nZdjecie %d',eee);
    znaleziono_znak=0;
    [a,b]=size(R(eee,1).TZ);
    R(eee,1).tz_ode_min=1;
    for i=1:a
        x=0;
        R(eee,1).TZ(i,1).bz=1;
        fprintf(' %d znakow',a);
    	%przeszukujemy wyci?ty obszar na nowo
        h_interval=3;
        s_interval=5;
        v_interval=5;
        h_span=10;
        s_span=60;
        v_span=60;
        h_low=R(eee,1).hueThresholdLow;
        h_high=R(eee,1).hueThresholdHigh;
        s_low=R(eee,1).saturationThresholdLow;
        s_high=R(eee,1).saturationThresholdHigh;
        v_low=R(eee,1).valueThresholdLow;
        v_high=R(eee,1).valueThresholdHigh;
        for h=h_low:h_interval:h_high-h_span
            fprintf('H:%d-%d',h,h+h_span);
            if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ;
            for s=s_low:s_interval:s_high-s_span
%                 fprintf('S:%d-%d',s,s+s_span);
                if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ
                for v=v_low:v_interval:v_high-v_span

                    if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ

                    % Convert RGB image to HSV
                    hsvImage = R(eee,1).TZ(i,1).Ow_hsv;
                    % Extract out the H, S, and V images individually
                    hImage = hsvImage(:,:,1);
                    sImage = hsvImage(:,:,2);
                    vImage = hsvImage(:,:,3);

                    % Now apply each color band's particular thresholds to the color band
                    hueMask = (hImage >= double(h/255)) & (hImage <= double(h+h_span/255));
                    saturationMask = (sImage >= double(s/255)) & (sImage <= double(s+s_span/255));
                    valueMask = (vImage >= double(v/255)) & (vImage <= double(v+v_span/255));

                    % Combine the masks to find where all 3 are "true."
                    orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);

                    DYL = imdilate(orangeObjectsMask,dysk); %dylatacja tylko po to, zeby polaczyc obszary lezce blisko w jeden
                    P_WDZ = imfill(DYL, 'holes'); %wypelnienie dziur
                    IL=bwlabel(P_WDZ);
                    STATS = regionprops(IL, 'BoundingBox');
                    [c,d]=size(STATS);

                    for j=1:c %dla kazdego obiektu na zdjeciu
                        fprintf('');
                        
                        bb_pow= STATS(j,1).BoundingBox; %pierwszy zakres przetwarzania
                        WYCINEK=imcrop(IL, bb_pow);

                        B1 = bwareaopen(WYCINEK, 200); %usuniecie malych obiektów
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

                            if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at && stat_at(poloz_at,1).Area > 5000

                                SP_0=WYCINEK;
                                SP = bwareaopen(SP_0, 200);
                                SPIL = bwlabel(SP);
                                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                                sppol=find([spt.Area] == max([spt.Area]));
                                if spt(sppol,1).Orientation<0 %wyznaczenie kata dla imrotate
                                    kat=-90-spt(sppol,1).Orientation;
                                else
                                    kat=90-spt(sppol,1).Orientation;
                                end
                                SPR_0=imrotate(SP,kat);
                                SPR = bwareaopen(SPR_0, 200);
                                sprt=regionprops(SPR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                                [e,f]=size(sprt);
                                if e>0
                                    sprpol=find([sprt.Area] == max([sprt.Area]));
                                    sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
                                    [spa,spb]=size(sprt(sprpol,1).FilledImage);
                                    sp_fa=sprt(sprpol,1).Area/(spa*spb); %czesc obszaru zajeta przez znak
                                    ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                                    if ode_sp < 0.20
                                        if ode_sp<R(eee,1).tz_ode_min %jesli sprawdzany obiekt ma lepsze ode niz najlepszy dotychczasowy
                                            R(eee,1).tz_ode_min=ode_sp;

%                                              if R(eee,1).tz_ode_min < 0.14 %jesli dopasowanie jest wystarczajaco dobre to przerywamy
%                                                 znaleziono_znak=1;

                                                SPR_cropped=imcrop(SPR,sprt(sprpol,1).BoundingBox);
                                                x=x+1;
                                                fprintf('\n%d. ode:%f sp_fa:%f area:%d\n',x,ode_sp,sp_fa,sprt(sprpol,1).Area);
                                                R(eee,1).TZ(i,1).bz=0;
                                                R(eee,1).TZ(i,1).bb=sprt(sprpol,1).BoundingBox;
                                                R(eee,1).TZ(i,1).SPR=SPR_cropped;
                                                R(eee,1).TZ(i,1).ode=ode_sp;
                                                masked=imrotate(DYL,kat);
                                                masked=imcrop(masked,sprt(sprpol,1).BoundingBox);
                                                masked = bwareaopen(masked, 200);
                                                R(eee,1).TZ(i,1).masked=masked;
                                                R(eee,1).TZ(i,1).Sign(x,1).mask=masked;

                                                R(eee,1).TZ(i,1).hueThresholdLow=h;
                                                R(eee,1).TZ(i,1).hueThresholdHigh=h+h_span;
                                                R(eee,1).TZ(i,1).saturationThresholdLow=s;
                                                R(eee,1).TZ(i,1).saturationThresholdHigh=s+s_span;
                                                R(eee,1).TZ(i,1).valueThresholdLow=v;
                                                R(eee,1).TZ(i,1).valueThresholdHigh=v+v_span;
%                                                 fprintf(' znaleziono znak');
%                                              end
                                        end  
                                    end
                                end
                            end
                        end 
                    end
                end
            end
        end
    end 
    fprintf('\niteracja %d z 14 gotowa\n', eee)
end
toc

for eee=1:14
    figure;
    subplot(1,3,1);
    imshow(R(eee,1).K1_OST),title('calosc');
    if R(eee,1).bz==0
        [a,b] = size(R(eee,1).TZ);
        j=2;
        for i=1:a
            fprintf('\nzdjecie %d obiekt %d/%d bz %d',eee,i,a,R(eee,1).TZ(i,1).bz);
            if R(eee,1).TZ(i,1).bz==0
                subplot(1,3,2);
                t=sprintf('\node %f',R(eee,1).TZ(i,1).ode);
                imshow(R(eee,1).TZ(i,1).masked,[]),title(t);
                subplot(1,3,3);
                imshow(R(eee,1).TZ(i,1).SPR);
                if R(eee,1).TZ(i,1).bz==0
                    [c,d]=size(R(eee,1).TZ(i,1).Sign);
                    fprintf(' ilosc masek %d',c);
                    figure;
                    for j=1:c
                        subplot(5,9,j);
                        imshow(R(eee,1).TZ(i,1).Sign(j,1).mask,[]);
                    end
                end
            end
        end
    end
end
% 
% for eee=1:14
% 	[a,b]=size(R(eee,1).TZ);
%     z=0;
%     for j=1:a 
%         if R(eee,1).TZ(j,1).bz==0
%             z=z+1;
%         end
%     end
%     fprintf('\nzdjecie %d Z:%d',eee,z);
% end
