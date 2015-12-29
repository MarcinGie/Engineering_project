% przeszukuje obrazy w kilku (?) petlach zmiany
% progu znajdujac obszary zainteresowania do dalszego przetwarzania w
% oryginalnej rozdzielczosci. Ustala ostateczna wielkosc BoundingBox 

tic

dysk = strel('disk',2); 
dysk_2=strel('disk',6);
mimj_ideal=0.25;
fa_ideal=0.85;

for eee=1:14 %dla kazdego obrazu
    
    if R(eee,1).t==1
        DYL = imdilate(R(eee,1).K1_OST,dysk_2); %dylatacja tylko po to, zeby polaczyc obszary lezace blisko w jeden

        IL=bwlabel(DYL);
        STATS = regionprops(IL, 'BoundingBox');
        R(eee,1).STATS=STATS;
        [a,b]=size(STATS);

        for j=1:a %dla kazdego obiektu
            bb_pow= STATS(j,1).BoundingBox; %pierwszy zakres przetwarzania
            WYCINEK=imcrop(R(eee,1).Or_hsv, bb_pow);
            
            % Convert RGB image to HSV
            hsvImage = WYCINEK;
            % Extract out the H, S, and V images individually
            hImage = hsvImage(:,:,1);
            sImage = hsvImage(:,:,2);
            vImage = hsvImage(:,:,3);

            %progowanie na podstawie pierwszego progu automatycznego
            hueMask = (hImage >= R(eee,1).hueThresholdLow) & (hImage <= R(eee,1).hueThresholdHigh);
            saturationMask = (sImage >= R(eee,1).saturationThresholdLow) & (sImage <= R(eee,1).saturationThresholdHigh);
            valueMask = (vImage >= R(eee,1).valueThresholdLow) & (vImage <= R(eee,1).valueThresholdHigh);

            orangeObjectsMask = uint8(hueMask & saturationMask & valueMask); 

            B1 = bwareaopen(orangeObjectsMask, 100); % usuniecie malych obiektów
            IL_OB=bwlabel(B1,8);
            if nnz(IL_OB)>0
                stat_at=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
                poloz_at=find([stat_at.Area] == max([stat_at.Area])); %znalezienie najwiekszego obiektu
                [fa1_at,fa2_at]=size(stat_at(poloz_at,1).FilledImage); %pobranie rozmiarów bounding box obiektu
                FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at); %cz??? obszaru zaj?ta przez znak
                mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength; %stusunek dlugosci bokow
                if stat_at(poloz_at,1).Orientation<-85 || stat_at(poloz_at,1).Orientation>85 %k?t mi?dzy elips? najwiekszego obiektu a osi? X
                    pr_fa_at=0.50;
                else
                    pr_fa_at=0.30;
                end
    
                if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at
                    R(eee,1).W_O(j,1).hueThresholdLow = R(eee,1).hueThresholdLow;
                    R(eee,1).W_O(j,1).hueThresholdHigh = R(eee,1).hueThresholdHigh;
                    R(eee,1).W_O(j,1).saturationThresholdLow = R(eee,1).saturationThresholdLow;
                    R(eee,1).W_O(j,1).saturationThresholdHigh = R(eee,1).saturationThresholdHigh;
                    R(eee,1).W_O(j,1).valueThresholdLow = R(eee,1).valueThresholdLow;
                    R(eee,1).W_O(j,1).valueThresholdHigh = R(eee,1).valueThresholdHigh;
                    R(eee,1).W_O(j,1).bb_i=bb_pow;
                    R(eee,1).W_O(j,1).IL_OB=IL_OB;
                    R(eee,1).W_O(j,1).bz=0;
%                     R(eee,1).
%                     proba3=0;

                    %progowanie na podstawie pierwszego progu automatycznego
                    hueMask = (hImage >= R(eee,1).W_O(j,1).hueThresholdLow) & (hImage <= R(eee,1).W_O(j,1).hueThresholdHigh);
                    saturationMask = (sImage >= R(eee,1).W_O(j,1).saturationThresholdLow) & (sImage <= R(eee,1).W_O(j,1).saturationThresholdHigh);
                    valueMask = (vImage >= R(eee,1).W_O(j,1).valueThresholdLow) & (vImage <= R(eee,1).W_O(j,1).valueThresholdHigh);

                    orangeObjectsMask = uint8(hueMask & saturationMask & valueMask); 

                    SP_0=orangeObjectsMask;
                    SP = bwareaopen(SP_0, 50);
                    SPIL=bwlabel(SP);
                    spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                    sppol=find([spt.Area] == max([spt.Area]));
                    if spt(sppol,1).Orientation<0 %wyznaczenie kata dla imrotate
                        kat=-90-spt(sppol,1).Orientation;
                    else
                        kat=90-spt(sppol,1).Orientation;
                    end
                    SPR_0=imrotate(SP,kat);
                    SPR = bwareaopen(SPR_0, 50);
                    sprt=regionprops(SPR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    sprpol=find([sprt.Area] == max([sprt.Area]));
                    sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
                    [spa spb]=size(sprt(sprpol,1).FilledImage);
                    sp_fa=sprt(sprpol,1).Area/(spa*spb); %czesc obszaru zajeta przez znak
                    ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                    fprintf('znaleziono znak ode:%f',ode_sp);
                    figure;
                    imshow(SPR);

%                     for i=R(eee,1).prog:-0.0001:0.7
%                         if proba3==1, break, end % wyj?cie z p?tli, je?eli zaczyna si? pogarsza?
%                         %-----------------------------------------------------------
%                         WYCINEK=imcrop(R(eee,1).K1, bb_pow);
%                         % obliczenie parametrów stat dla obrazu rozwa?anego
%                         SN_0=im2bw(WYCINEK, i); %obraz binarny rozwa?any
%                         SN = bwareaopen(SN_0, 50); %usuni?cie obszarów poni?ej 300 pikseli
%                         SNIL=bwlabel(SN); % moÅ¼e zostaÄ‡ teoretycznie wi?cej ni? 1 obszar, wi?c sprawdzenie
%                         snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te? powierzchnia, ?eby orientacja by?a barna od najwi?kszego obszaru
%                         % odnalezienie najwi?kszego obszaru
%                         snpol=find([snt.Area] == max([snt.Area]));
% 
%                         if snt(snpol,1).Orientation<0 %wyznaczenie k?ta dla imrotate
%                             kat=-90-snt(snpol,1).Orientation;
%                         else
%                             kat=90-snt(snpol,1).Orientation;
%                         end
%                         % obrót obrazu
%                         SNR_0=imrotate(SN,kat);
%                         SNR = bwareaopen(SNR_0, 10);
%                         SNRIL=bwlabel(SNR);
%                         %odnalezienie najwi?kszego obszaru
%                         snrt=regionprops(SNR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
%                         snrpol=find([snrt.Area] == max([snrt.Area]));
%                         sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
%                         [sna snb]=size(snrt(snrpol,1).FilledImage);
%                         sn_fa=snrt(snrpol,1).Area/(sna*snb);
%                         % --------------------------------------------------------------------------------
%                         % obliczenie odlego?ci euklidesowej
%                         ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
% 
%                         if ode_sn>ode_sp %& sprt(sprpol,1).Area>3100
%                             %stat_kon=regionprops(SP,'BoundingBox');
%                             R(eee,1).W_O(j,1).bz=0;
%                             R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(i+0.0001));
%                             R(eee,1).W_O(j,1).prog=i+0.0001;
%                             R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu pó?niejszego wykorzystania
%                             R(eee,1).W_O(j,1).SPR=SPR;
%                             R(eee,1).W_O(j,1).SP=SP;
%                             R(eee,1).W_O(j,1).odl=ode_sp;
%                             R(eee,1).W_O(j,1).iteracja=1;
%                             proba=1;
%                             proba2=1;
%                             proba3=1;
%                         elseif i==0.7
%                             %stat_kon=regionprops(SN,'BoundingBox');
%                             R(eee,1).W_O(j,1).bz=0;
%                             R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(i));
%                             R(eee,1).W_O(j,1).prog=i;
%                             R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu pó?niejszego wykorzystania
%                             R(eee,1).W_O(j,1).SPR=SPR;
%                             R(eee,1).W_O(j,1).SP=SP;
%                             R(eee,1).W_O(j,1).odl=ode_sn;
%                             R(eee,1).W_O(j,1).iteracja=1;
%                             proba=1;
%                             proba2=1;
%                             proba3=1;
%                         else
%                            ode_sp=ode_sn;
%                            SPR=SNR;
%                            SP=SN;
%                         end
% 
%                         tragedyjka=1;
%                         while tragedyjka==1
%                             WYC=imcrop(R(eee,1).K1, bb_pow);
%                             rozx=bb_pow(1,3);
%                             rozy=bb_pow(1,4);
%                             % obliczenie paramerów stat dla obrazu rozwa?anego
%                             bbt_0=im2bw(WYC, i); %obraz binarny rozwa?any
%                             bbt = bwareaopen(bbt_0, 50); %usunicie obszarów poni?ej 300 pikseli
%                             bbtIL=bwlabel(bbt); % mo?e zosta? teoretycznie wi?cej ni? 1 obszar, wi?c sprawdzenie
%                             bbts=regionprops(bbtIL,'Area','BoundingBox'); %po pierwsze orientacja do obrotu, ale te? powierzchnia, ?eby orientacja by?a barna od najwi?kszego obszaru
%                             % odnalezienie najwi?kszego obszaru
%                             bbtpol=find([bbts.Area] == max([bbts.Area]));
%                             tragedyjka=0;
%                             if proba3==0 && bb_pow(1,3)<60 && bb_pow(1,4)<100
%                                 if bbts(bbtpol,1).BoundingBox(1,1)==0.5
%                                     bb_pow=bb_pow+dod_l;
%                                     tragedyjka=1;
%                                 end
%                                 if bbts(bbtpol,1).BoundingBox(1,2)==0.5
%                                     bb_pow=bb_pow+dod_g;
%                                     tragedyjka=1;
%                                 end
%                                 if (bbts(bbtpol,1).BoundingBox(1,1)+bbts(bbtpol,1).BoundingBox(1,3)>(rozy-1))
%                                     bb_pow=bb_pow+dod_p;
%                                     tragedyjka=1;
%                                 end
%                                 if (bbts(bbtpol,1).BoundingBox(1,2)+bbts(bbtpol,1).BoundingBox(1,4)>(rozx-1))
%                                     bb_pow= bb_pow+dod_d;
%                                     tragedyjka=1;
%                                 end
%                             end
%                         end
%                     end
                end
                clearvars -except i j a R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS
            end
        end
    
    end
    fprintf(' iteracja %d z 119 gotowa\n', eee)
    clearvars -except R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS
end

toc
clearvars -except R

% % obci?cie bounding box
% for eee=1:14
%     [a b]=size(R(eee,1).W_O);
%     for i=1:a
%         if R(eee,1).W_O(i,1).bz==0
%             S=im2double(R(eee,1).W_O(i,1).SP);
%             D=im2double(R(eee,1).W_O(i,1).SPR);
%             stat=regionprops(S,'BoundingBox');
%             statd=regionprops(D,'BoundingBox','Area');
%             
%             R(eee,1).W_O(i,1).bb_pr(1,1)=stat.BoundingBox(1,1)+R(eee,1).W_O(i,1).bb(1,1);
%             R(eee,1).W_O(i,1).bb_pr(1,2)=stat.BoundingBox(1,2)+R(eee,1).W_O(i,1).bb(1,2);
%             R(eee,1).W_O(i,1).bb_pr(1,3)=stat.BoundingBox(1,3);
%             R(eee,1).W_O(i,1).bb_pr(1,4)=stat.BoundingBox(1,4);
%             tt=statd.BoundingBox(1,3)*statd.BoundingBox(1,4);
%             
%             w(eee,i)=statd.Area/tt;
%              
%             if w(eee,i)<0.4
%                R(eee,1).W_O(i,1).bz=1;
%             end
%             
%         end
%     end
% end

clearvars -except R
