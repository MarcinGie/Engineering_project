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
il_zdjec=14;

% R(eee,1).hueThresholdLow = double(0/255);
% R(eee,1).hueThresholdHigh = double(30/255);
% R(eee,1).saturationThresholdLow = double(0/255);
% R(eee,1).saturationThresholdHigh = double(255/255);
% R(eee,1).valueThresholdLow = double(0/255);
% R(eee,1).valueThresholdHigh = double(255/255);

for eee=1:il_zdjec %dla kazdego zdjecia
    
    if R(eee,1).t==1
        R(eee,1).ode_min=1;
        znaleziono_znak=0;
        fprintf('\nZDJECIE %d',eee);

        DYL = imdilate(R(eee,1).K1_OST,dysk); %dylatacja tylko po to, zeby polaczyc obszary lezce blisko w jeden
        P_WDZ = imfill(DYL, 'holes'); %wypelnienie dziur
        
        IL=bwlabel(P_WDZ);
        STATS = regionprops(IL, 'BoundingBox'); 
        R(eee,1).STATS=STATS;
        [a,b]=size(STATS);
        
        %sprawdzenie po wstepnym progowaniu
        for j=1:a %dla kazdego obiektu na zdjeciu
            R(eee,1).W(j,1).bz=1;
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

                if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at

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
                    sprpol=find([sprt.Area] == max([sprt.Area]));
                    sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
                    [spa,spb]=size(sprt(sprpol,1).FilledImage);
                    sp_fa=sprt(sprpol,1).Area/(spa*spb); %czesc obszaru zajeta przez znak
                    ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                    if ode_sp < 0.20
                        
                        t=sprintf('\nzdjecie %d obiekt %d cos jak znak: %f',eee,j,ode_sp);
                        SPR_cropped=imcrop(SPR,sprt(sprpol,1).BoundingBox);
                        R(eee,1).bz=0;
                        R(eee,1).W(j,1).bz=0;
                        R(eee,1).W(j,1).bb=bb_pow;
                        R(eee,1).W(j,1).SPR=SPR_cropped;
                        R(eee,1).W(j,1).ode=ode_sp;
                        
                        R(eee,1).W(j,1).hueThresholdLow=R(eee,1).hueThresholdLow;
                        R(eee,1).W(j,1).hueThresholdHigh=R(eee,1).hueThresholdHigh;
                        R(eee,1).W(j,1).saturationThresholdLow=R(eee,1).saturationThresholdLow;
                        R(eee,1).W(j,1).saturationThresholdHigh=R(eee,1).saturationThresholdHigh;
                        R(eee,1).W(j,1).valueThresholdLow=R(eee,1).valueThresholdLow;
                        R(eee,1).W(j,1).valueThresholdHigh=R(eee,1).valueThresholdHigh;
                        
                        znaleziono_znak=1;
                        fprintf(' znaleziono znak od razu');

                    end
                else
                    R(eee,1).bz=1;
                end
                
            end 
        end

        if znaleziono_znak==0
            %jesli nie znaleziono jeszcze znaku to jedziemy z przeszukiwaniem
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
                if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ;
                for s=s_low:s_interval:s_high-s_span
                    
                    if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ
                    for v=v_low:v_interval:v_high-v_span
                        
                        if znaleziono_znak==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ
                        
                        % Convert RGB image to HSV
                        hsvImage = R(eee,1).Or_hsv;
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
                        [a,b]=size(STATS);

                        for j=1:a %dla kazdego obiektu na zdjeciu
                            R(eee,1).W(j,1).bz=1;
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

                                if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at
                                    
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
                                    [a,b]=size(sprt);
                                    if a>0
                                        sprpol=find([sprt.Area] == max([sprt.Area]));
                                        sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
                                        [spa,spb]=size(sprt(sprpol,1).FilledImage);
                                        sp_fa=sprt(sprpol,1).Area/(spa*spb); %czesc obszaru zajeta przez znak
                                        ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                                        if ode_sp < 0.20
                                            if ode_sp<R(eee,1).ode_min %jesli sprawdzany obiekt ma lepsze ode niz najlepszy dotychczasowy
                                                R(eee,1).ode_min=ode_sp;
                                                
                                                if R(eee,1).ode_min < 0.1 %jesli dopasowanie jest wystarczajaco dobre to przerywamy
                                                    znaleziono_znak=1;
                                                    SPR_cropped=imcrop(SPR,sprt(sprpol,1).BoundingBox);
                                                    
                                                    R(eee,1).W(j,1).bz=0;
                                                    R(eee,1).W(j,1).bb=bb_pow;
                                                    R(eee,1).W(j,1).SPR=SPR_cropped;
                                                    R(eee,1).W(j,1).ode=ode_sp;
                                                    
                                                    R(eee,1).W(j,1).hueThresholdLow=h;
                                                    R(eee,1).W(j,1).hueThresholdHigh=h+h_span;
                                                    R(eee,1).W(j,1).saturationThresholdLow=s;
                                                    R(eee,1).W(j,1).saturationThresholdHigh=s+s_span;
                                                    R(eee,1).W(j,1).valueThresholdLow=v;
                                                    R(eee,1).W(j,1).valueThresholdHigh=v+v_span;
                                                    fprintf(' znaleziono znak po przeszukaniu');
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
            [a,b]=size(R(eee,1).W);
            for j=1:a
                if R(eee,1).W(j,1).bz==0
                    R(eee,1).bz=0;
                end
            end
        end
    end
    fprintf('\niteracja %d z 14 gotowa\n', eee)

end

for eee=1:il_zdjec
    figure;
    subplot(1,3,1);
    imshow(R(eee,1).K1_OST),title('calosc');
    if R(eee,1).bz==0
        [a,b] = size(R(eee,1).W);
        j=2;
        for i=1:a
            if R(eee,1).W(i,1).bz==0
                subplot(1,3,j);
                t=sprintf('\node %f',R(eee,1).W(i,1).ode);
                imshow(R(eee,1).W(i,1).SPR),title(t);
                j=j+1;
            end
        end

    end
end

toc
clearvars -except R
