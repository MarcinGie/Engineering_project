% autor: E.Pastucha
% skrypt wczytuje wyniki przetwarzania sieci neuronowej na obrazach o
% zmniejszonej rozdzielczości,  przeszukuje obrazy w trzech petlach zmiany
% progu znajdując obszary zainteresowania do dalszego przetwarzania w
% oryginalnej rozdzielczoœci. Ustala ostateczną wielkość BoundingBox 


tic

dysk = strel('disk',2); 
dysk_2=strel('disk',6);
mimj_ideal=0.25;
fa_ideal=0.85;
dod_g=[0,-10,0,10];
dod_d=[0,0,0,10];
dod_l=[-10,0,10,0];
dod_p=[0,0,10,0];

for eee=1:119
    
    if R(eee,1).t==1
    DYL = imdilate(R(eee,1).K1_OST,dysk_2); %dylatacja tylko po to, żeby połączyć obszary leżące blisko w jeden
    
    IL=bwlabel(DYL);
    STATS = regionprops(IL, 'BoundingBox');
    R(eee,1).STATS=STATS;
    [a b]=size(STATS);
    
	for j=1:a 
        bb_pow= STATS(j,1).BoundingBox; %pierwszy zakres przetwarzania
        proba=0; %warunek p?tli 
        proba2=0; %warunek p?tli 2
        WYCINEK=imcrop(R(eee,1).K1, bb_pow);
        B=im2bw(WYCINEK, R(eee,1).prog); %progowanie na podstawie pierwszego progu automatycznego
        B1 = bwareaopen(B, 10); % usuni?cie ma?ych obiekt�w
        IL_OB=bwlabel(B1,8);
        if nnz(IL_OB)>0
            stat_at=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
            poloz_at=find([stat_at.Area] == max([stat_at.Area])); %znalezienie najwiekszego obiektu
            [fa1_at fa2_at]=size(stat_at(poloz_at,1).FilledImage); %pobranie rozmiarów bounding box obiektu
            FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at); %część obszaru zajęta przez znak
            mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength; %stusunek dlugosci bokow
            if stat_at(poloz_at,1).Orientation<-85 || stat_at(poloz_at,1).Orientation>85 %kąt między elipsą najwiekszego obiektu a osią X
            	pr_fa_at=0.50;
            else
            	pr_fa_at=0.30;
   98         end
%..................................................................................................................................................................................................................
            if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at
                R(eee,1).W_O(j,1).prog_i=R(eee,1).prog;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                proba3=0;
                SP_0=im2bw(WYCINEK,((R(eee,1).prog)+0.0001));
                SP = bwareaopen(SP_0, 50);
                SPIL=bwlabel(SP);
                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                sppol=find([spt.Area] == max([spt.Area]));
                if spt(sppol,1).Orientation<0 %wyznaczenie kąta dla imrotate
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
               	sp_fa=sprt(sprpol,1).Area/(spa*spb); %część obszaru zajęta przez znak
                ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                
                for i=R(eee,1).prog:-0.0001:0.7
                    if proba3==1, break, end % wyjście z pętli, jeżeli zaczyna się pogarszać
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramerów stat dla obrazu rozważanego
                    SN_0=im2bw(WYCINEK, i); %obraz binarny rozważany
                    SN = bwareaopen(SN_0, 50); %usunięcie obszarów poniżej 300 pikseli
                    SNIL=bwlabel(SN); % może zostać teoretycznie więcej niż 1 obszar, więc sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale też powierzchnia, żeby orientacja była barna od największego obszaru
                    % odnalezienie największego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie kąta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obrót obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 10);
                    SNRIL=bwlabel(SNR);
                    %odnalezeienie największego obszaru
                    snrt=regionprops(SNR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol=find([snrt.Area] == max([snrt.Area]));
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    % --------------------------------------------------------------------------------
                   	% obliczenie odlegości euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>3100
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(i+0.0001));
                      	R(eee,1).W_O(j,1).prog=i+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu późniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPR;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sp;
                        R(eee,1).W_O(j,1).iteracja=1;
                        proba=1;
                      	proba2=1;
                        proba3=1;
                  	elseif i==0.7
                       	%stat_kon=regionprops(SN,'BoundingBox');
                       	R(eee,1).W_O(j,1).bz=0;
                       	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(i));
                       	R(eee,1).W_O(j,1).prog=i;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu póŸniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPR;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sn;
                        R(eee,1).W_O(j,1).iteracja=1;
                        proba=1;
                       	proba2=1;
                        proba3=1;
                    else
                       ode_sp=ode_sn;
                       SPR=SNR;
                       SP=SN;
                    end
                    
                    tragedyjka=1;
                    while tragedyjka==1
                    	WYC=imcrop(R(eee,1).K1, bb_pow);
                        rozx=bb_pow(1,3);
                        rozy=bb_pow(1,4);
                        % obliczenie paramerów stat dla obrazu rozważanego
                        bbt_0=im2bw(WYC, i); %obraz binarny rozważany
                        bbt = bwareaopen(bbt_0, 50); %usunięcie obszarów poniżej 300 pikseli
                        bbtIL=bwlabel(bbt); % może zostać teoretycznie więcej niż 1 obszar, więc sprawdzenie
                        bbts=regionprops(bbtIL,'Area','BoundingBox'); %po pierwsze orientacja do obrotu, ale też powierzchnia, żeby orientacja była barna od największego obszaru
                        % odnalezienie największego obszaru
                        bbtpol=find([bbts.Area] == max([bbts.Area]));
                        tragedyjka=0;
                        if proba3==0 && bb_pow(1,3)<60 && bb_pow(1,4)<100
                            if bbts(bbtpol,1).BoundingBox(1,1)==0.5
                                bb_pow=bb_pow+dod_l;
                                tragedyjka=1;
                            end
                            if bbts(bbtpol,1).BoundingBox(1,2)==0.5
                                bb_pow=bb_pow+dod_g;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,1)+bbts(bbtpol,1).BoundingBox(1,3)>(rozy-1))
                                bb_pow=bb_pow+dod_p;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,2)+bbts(bbtpol,1).BoundingBox(1,4)>(rozx-1))
                                bb_pow= bb_pow+dod_d;
                                tragedyjka=1;
                            end
                        end
                    end
                end
            end
            clearvars -except i j a R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS
        end
%..................................................................................................................................................................................................................
      for i=1:-0.0001:0.7 % pętla właściwego doboru progu
            
            WYCINEK=imcrop(R(eee,1).K1, bb_pow);

            if proba==1, break, end % wyjœcie z petli po wykryciu pierwszego znaku
            
            B=im2bw(WYCINEK,i); % progowanie na podstawie dynamicznego progu
            
            B1 = bwareaopen(B, 50); % usuniêcie małych obiektów
            IL_OB=bwlabel(B1); % numerowanie pozostałych obiektów
            
            if nnz(IL_OB)>0
            stat=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage'); % statystyka pozostałych obiektów
            % nie powinno być wiecej niż jeden obiekt, ale jeżeli coś takiego się stanie, statystyka będzie brana pod uwagę dla największego obiektu
            polo=find([stat.Area] == max([stat.Area]));
            polozenie=polo(1,1);
            [fa1 fa2]=size(stat(polozenie,1).FilledImage); 
            FA=stat(polozenie,1).Area/(fa1*fa2); %część obszaru zajęta przez znak
            
            mimj=stat(polozenie,1).MinorAxisLength/stat(polozenie,1).MajorAxisLength; %stosunek x/y 
            if stat(polozenie,1).Orientation<-85 || stat(polozenie,1).Orientation>85
            	pr_fa=0.60;
            else
            	pr_fa=0.30;
            end
            
            
            if mimj<0.3 && mimj>0.1 && (stat(polozenie,1).Orientation<-60 || stat(polozenie,1).Orientation>60) && FA>pr_fa && stat(polozenie,1).Area>100 %wszystkie parametry wyznaczy³am na podstawie masek zbioru ucz¹cego, oczywiscie z dodatkowym buforem bezpieczeñstwa
                R(eee,1).W_O(j,1).prog_i=i;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                
                if stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)>150 
                    bb_pow=(stat(polozenie,1).BoundingBox)+[bb_pow(1,1),bb_pow(1,2),0,0];
                elseif stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)<=150 % po x przyci¹æ po y zostawiæ
                    bb_pow=[stat(polozenie,1).BoundingBox(1,1)+bb_pow(1,1),bb_pow(1,2),stat(polozenie,1).BoundingBox(1,3),bb_pow(1,4)];
                elseif stat(polozenie,1).BoundingBox(1,3)<50 && stat(polozenie,1).BoundingBox(1,3)>=150 % po y przyci¹æ po x zostawiæ
                    bb_pow=[bb_pow(1,1),stat(polozenie,1).BoundingBox(1,2)+bb_pow(1,2),bb_pow(1,3),stat(polozenie,1).BoundingBox(1,4)];
                end
                WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                SP_0=im2bw(WYCINEK,(i));
                SP = bwareaopen(SP_0, 50);
                SPIL=bwlabel(SP);
                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                sppol=find([spt.Area] == max([spt.Area]));
                if spt(sppol,1).Orientation<0 %wyznaczenie k¹ta dla imrotate
                	kat=-90-spt(sppol,1).Orientation;
                else
                  	kat=90-spt(sppol,1).Orientation;
                end
              	SPR_0=imrotate(SP,kat);
               	SPR = bwareaopen(SPR_0, 10);
               	sprt=regionprops(SPR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
               	sprpol=find([sprt.Area] == max([sprt.Area]));

               	sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
              	[spa spb]=size(sprt(sprpol,1).FilledImage);
                sp_fa=sprt(sprpol,1).Area/(spa*spb);
                ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                
                for z=(i-0.0001):-0.0001:0.7
                    if proba2==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramerów stat dla obrazu rozwa¿anego
                    SN_0=im2bw(WYCINEK, z); %obraz binarny rozwa¿any
                    SN = bwareaopen(SN_0, 50); %usuniêcie obszarów poni¿ej 300 pikseli
                    SNIL=bwlabel(SN); % mo¿e zostaæ teoretycznie wiêcej ni¿ 1 obszar, wiêc sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te¿ powierzchnia, ¿eby orientacja by³a barna od najwiêkszego obszaru
                    % odnalezienie najwiêkszego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie k¹ta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obrót obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 10);
                    SNRIL=bwlabel(SNR);
                    %odnalezeienie najwiêkszego obszaru
                    snrt=regionprops(SNR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol=find([snrt.Area] == max([snrt.Area]));
                    
                    
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    
                    
                    % --------------------------------------------------------------------------------
                
                   	% obliczenie odleg³oœci euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>2500 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! było 3100, sprawdzenie jak teraz
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z+0.0001));
                      	R(eee,1).W_O(j,1).prog=z+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu póŸniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPR;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sp;
                        R(eee,1).W_O(j,1).iteracja=2;
                        proba=1;
                      	proba2=1;
                  	elseif z==0.7
                       	%stat_kon=regionprops(SN,'BoundingBox');
                       	R(eee,1).W_O(j,1).bz=0;
                       	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z));
                       	R(eee,1).W_O(j,1).prog=z;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu póŸniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPR;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sn;
                        R(eee,1).W_O(j,1).iteracja=2;
                        proba=1;
                       	proba2=1;
                    else
                       ode_sp=ode_sn;
                       SPR=SNR;
                       SP=SN;
                    end
                    tragedyjka=1;
                    while tragedyjka==1
                        rozx=bb_pow(1,3);
                        rozy=bb_pow(1,4);
                        WYC=imcrop(R(eee,1).K1, bb_pow);
                        % obliczenie paramerów stat dla obrazu rozwa¿anego
                        bbt_0=im2bw(WYC, z); %obraz binarny rozwa¿any
                        bbt = bwareaopen(bbt_0, 50); %usuniêcie obszarów poni¿ej 300 pikseli
                        bbtIL=bwlabel(bbt); % mo¿e zostaæ teoretycznie wiêcej ni¿ 1 obszar, wiêc sprawdzenie
                        bbts=regionprops(bbtIL,'Area','BoundingBox'); %po pierwsze orientacja do obrotu, ale te¿ powierzchnia, ¿eby orientacja by³a barna od najwiêkszego obszaru
                        % odnalezienie najwiêkszego obszaru
                        bbtpol=find([bbts.Area] == max([bbts.Area]));
                        tragedyjka=0;
                        if proba==0 && proba2==0 && bb_pow(1,3)<60 && bb_pow(1,4)<100
                            if bbts(bbtpol,1).BoundingBox(1,1)==0.5
                                bb_pow=bb_pow+dod_l;
                                tragedyjka=1;
                            end
                            if bbts(bbtpol,1).BoundingBox(1,2)==0.5
                                bb_pow=bb_pow+dod_g;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,1)+bbts(bbtpol,1).BoundingBox(1,3)>(rozy-1))
                                bb_pow=bb_pow+dod_p;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,2)+bbts(bbtpol,1).BoundingBox(1,4)>(rozx-1))
                                bb_pow= bb_pow+dod_d;
                                tragedyjka=1;
                            end
                        end
                    end
                end
            end
            if proba==0 && i==0.7
                R(eee,1).W_O(j,1).bz=1;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
            end
            tragedyjka=1;
            
            while tragedyjka==1 
                rozx=bb_pow(1,3);
                rozy=bb_pow(1,4);
                WYC=imcrop(R(eee,1).K1, bb_pow);
                bbt=im2bw(WYC,i); % progowanie na podstawie dynamicznego progu
            
                bbt1 = bwareaopen(bbt, 50); % usuniêcie ma³ych obiektów
                bbtIL_OB=bwlabel(bbt1); % numerowanie pozosta³ych obiektów
                bbtstat=regionprops(bbtIL_OB,'Area','BoundingBox'); % statystyka pozosta³ych obiektów
                bbtpolo=find([stat.Area] == max([stat.Area]));
                bbtpolozenie=polo(1,1);
                tragedyjka=0;
                if  proba==0 && proba2==0  && bb_pow(1,3)<60 && bb_pow(1,4)<100
                    if bbtstat(bbtpolozenie,1).BoundingBox(1,1)==0.5 
                       bb_pow=bb_pow+dod_l;
                       tragedyjka=1;
                    end
                    if bbtstat(bbtpolozenie,1).BoundingBox(1,2)==0.5
                       bb_pow=bb_pow+dod_g;
                       tragedyjka=1;
                    end
                    if (bbtstat(bbtpolozenie,1).BoundingBox(1,1)+bbtstat(bbtpolozenie,1).BoundingBox(1,3)>(rozy-1))
                        bb_pow=bb_pow+dod_p;
                        tragedyjka=1;
                    end
                    if (bbtstat(bbtpolozenie,1).BoundingBox(1,2)+bbtstat(bbtpolozenie,1).BoundingBox(1,4)>(rozx-1))
                        bb_pow= bb_pow+dod_d;
                        tragedyjka=1;
                    end
                end
            end           
            elseif proba==0 && i==0.7 && nnz(IL_OB)==0
                R(eee,1).W_O(j,1).bz=1;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
             end
        end
      clearvars -except i j a z R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS       
%..................................................................................................................................................................................................................        
        for i=1:-0.0001:0.7 % pêtla w³aœciwego doboru progu wersja z dylatacj¹ 
            
            WYCINEK=imcrop(R(eee,1).K1, bb_pow);

            if proba==1, break, end % wyjœcie z petli po wykryciu pierwszego znaku
            
            B=im2bw(WYCINEK,i); % progowanie na podstawie dynamicznego progu
            B1 = bwareaopen(B, 10); % usuniêcie ma³ych obiektów
            Bdyl=imdilate(B1,dysk);
            
            IL_OB=bwlabel(Bdyl); % numerowanie pozosta³ych obiektów
            
            if nnz(IL_OB)>0
            stat=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage'); % statystyka pozosta³ych obiektów
            % nie powinno byæ wiecej ni¿ jeden obiekt, ale je¿eli coœ takiego siê stanie, statystyka bêdzie brana pod uwagê dla najwiêkszego obiektu
            polo=find([stat.Area] == max([stat.Area]));
            polozenie=polo(1,1);
            [fa1 fa2]=size(stat(polozenie,1).FilledImage); 
            FA=stat(polozenie,1).Area/(fa1*fa2); %czeœæ obszaru zajêta przez znak
            
            mimj=stat(polozenie,1).MinorAxisLength/stat(polozenie,1).MajorAxisLength; %stosunek x/y 
            if stat(polozenie,1).Orientation<-85 || stat(polozenie,1).Orientation>85
            	pr_fa=0.60;
            else
            	pr_fa=0.30;
            end
            
            gugu=nnz(IL_OB);
            if mimj<0.4 && mimj>0.1 && (stat(polozenie,1).Orientation<-60 || stat(polozenie,1).Orientation>60) && FA>pr_fa && gugu>450 %wszystkie parametry wyznaczy³am na podstawie masek zbioru ucz¹cego, oczywiscie z dodatkowym buforem bezpieczeñstwa
                R(eee,1).W_O(j,1).prog_i=i;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                
                if stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)>150 
                    bb_pow=(stat(polozenie,1).BoundingBox)+[bb_pow(1,1),bb_pow(1,2),0,0];
                elseif stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)<=150 % po x przyci¹æ po y zostawiæ
                    bb_pow=[stat(polozenie,1).BoundingBox(1,1)+bb_pow(1,1),bb_pow(1,2),stat(polozenie,1).BoundingBox(1,3),bb_pow(1,4)];
                elseif stat(polozenie,1).BoundingBox(1,3)<50 && stat(polozenie,1).BoundingBox(1,3)>=150 % po y przyci¹æ po x zostawiæ
                    bb_pow=[bb_pow(1,1),stat(polozenie,1).BoundingBox(1,2)+bb_pow(1,2),bb_pow(1,3),stat(polozenie,1).BoundingBox(1,4)];
                end
                WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                SP_0=im2bw(WYCINEK,(i));
                
                SP = bwareaopen(SP_0, 10);
                SPdyl=imdilate(SP,dysk);
                SPIL=bwlabel(SPdyl);
                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                sppol=find([spt.Area] == max([spt.Area]));
                if spt(sppol,1).Orientation<0 %wyznaczenie k¹ta dla imrotate
                	kat=-90-spt(sppol,1).Orientation;
                else
                  	kat=90-spt(sppol,1).Orientation;
                end
              	SPR_0=imrotate(SP,kat);
                SPR = bwareaopen(SPR_0, 5);
                SPRdyl=imdilate(SPR,dysk);
               	
               	sprt=regionprops(SPRdyl,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
               	sprpol=find([sprt.Area] == max([sprt.Area]));

               	sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength;
              	[spa spb]=size(sprt(sprpol,1).FilledImage);
                sp_fa=sprt(sprpol,1).Area/(spa*spb);
                ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                
                for z=(i-0.0001):-0.0001:0.7
                    if proba2==1, break, end % wyjœcie z pêtli, je¿eli zaczyna siê pogarszaæ
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramerów stat dla obrazu rozwa¿anego
                    SN_0=im2bw(WYCINEK, z); %obraz binarny rozwa¿any
                    SN = bwareaopen(SN_0, 10); %usuniêcie obszarów poni¿ej 300 pikseli
                    SNdyl=imdilate(SN,dysk);
                    
                    SNIL=bwlabel(SNdyl); % mo¿e zostaæ teoretycznie wiêcej ni¿ 1 obszar, wiêc sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te¿ powierzchnia, ¿eby orientacja by³a barna od najwiêkszego obszaru
                    % odnalezienie najwiêkszego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie k¹ta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obrót obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 5);
                    SNRIL=bwlabel(SNR_0);
                    %odnalezeienie najwiêkszego obszaru
                    snrt=regionprops(SNR_0,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol1=find([snrt.Area] == max([snrt.Area]));
                    snrpol=snrpol1(1,1);
                    
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    
                    
                    % --------------------------------------------------------------------------------
                
                   	% obliczenie odleg³oœci euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>2500 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! by³o 3100, sprawdzenie jak teraz
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z+0.0001));
                      	R(eee,1).W_O(j,1).prog=z+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu póŸniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPRdyl;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sp;
                        R(eee,1).W_O(j,1).iteracja=3;
                        proba=1;
                      	proba2=1;
                  	elseif z==0.7
                       	%stat_kon=regionprops(SN,'BoundingBox');
                       	R(eee,1).W_O(j,1).bz=0;
                       	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z));
                       	R(eee,1).W_O(j,1).prog=z;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametrów w celu póŸniejszego wykorzystania
                       	R(eee,1).W_O(j,1).SPR=SPRdyl;
                        R(eee,1).W_O(j,1).SP=SP;
                        R(eee,1).W_O(j,1).odl=ode_sn;
                        R(eee,1).W_O(j,1).iteracja=3;
                        proba=1;
                       	proba2=1;
                    else
                       ode_sp=ode_sn;
                       SPR=SNR_0;
                       SP=SN;
                    end
                    tragedyjka=1;
                    while tragedyjka==1
                        rozx=bb_pow(1,3);
                        rozy=bb_pow(1,4);
                        WYC=imcrop(R(eee,1).K1, bb_pow);
                        % obliczenie paramerów stat dla obrazu rozwa¿anego
                        bbt_0=im2bw(WYC, z); %obraz binarny rozwa¿any
                        bbt = bwareaopen(bbt_0, 10); %usuniêcie obszarów poni¿ej 300 pikseli
                        bbtdyl=imdilate(bbt,dysk);
                        
                        bbtIL=bwlabel(bbtdyl); % mo¿e zostaæ teoretycznie wiêcej ni¿ 1 obszar, wiêc sprawdzenie
                        bbts=regionprops(bbtIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te¿ powierzchnia, ¿eby orientacja by³a barna od najwiêkszego obszaru
                        % odnalezienie najwiêkszego obszaru
                        bbtpol=find([bbts.Area] == max([bbts.Area]));
                        tragedyjka=0;
                        if proba==0 && proba2==0 && bb_pow(1,3)<60 && bb_pow(1,4)<100
                            if bbts(bbtpol,1).BoundingBox(1,1)==0.5
                                bb_pow=bb_pow+dod_l;
                                tragedyjka=1;
                            end
                            if bbts(bbtpol,1).BoundingBox(1,2)==0.5
                                bb_pow=bb_pow+dod_g;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,1)+bbts(bbtpol,1).BoundingBox(1,3)>(rozy-1))
                                bb_pow=bb_pow+dod_p;
                                tragedyjka=1;
                            end
                            if (bbts(bbtpol,1).BoundingBox(1,2)+bbts(bbtpol,1).BoundingBox(1,4)>(rozx-1))
                                bb_pow= bb_pow+dod_d;
                                tragedyjka=1;
                            end
                        end
                    end
                end
            end
            if proba==0 && i==0.7
                R(eee,1).W_O(j,1).bz=1;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
            end
            tragedyjka=1;
            
            while tragedyjka==1
                rozx=bb_pow(1,3);
                rozy=bb_pow(1,4);
                tragedyjka=0;
                WYC=imcrop(R(eee,1).K1, bb_pow);
                bbt=im2bw(WYC,i); % progowanie na podstawie dynamicznego progu
                bbt1 = bwareaopen(bbt, 10); % usuniêcie ma³ych obiektów
                bbtdyl=imdilate(bbt1,dysk);
                bbtIL_OB=bwlabel(bbtdyl); % numerowanie pozosta³ych obiektów
                bbtstat=regionprops(bbtIL_OB,'Area','BoundingBox'); % statystyka pozosta³ych obiektów
                % nie powinno byæ wiecej ni¿ jeden obiekt, ale je¿eli coœ takiego siê stanie, statystyka bêdzie brana pod uwagê dla najwiêkszego obiektu
                bbtpolo=find([bbtstat.Area] == max([bbtstat.Area]));
                bbtpolozenie=bbtpolo(1,1);
                if  proba==0 && proba2==0  && bb_pow(1,3)<60 && bb_pow(1,4)<100
                    if bbtstat(bbtpolozenie,1).BoundingBox(1,1)==0.5 
                       bb_pow=bb_pow+dod_l;
                       tragedyjka=1;
                    end
                    if bbtstat(bbtpolozenie,1).BoundingBox(1,2)==0.5
                       bb_pow=bb_pow+dod_g;
                       tragedyjka=1;
                    end
                    if (bbtstat(bbtpolozenie,1).BoundingBox(1,1)+bbtstat(bbtpolozenie,1).BoundingBox(1,3)>(rozy-1))
                        bb_pow=bb_pow+dod_p;
                        tragedyjka=1;
                    end
                    if (bbtstat(bbtpolozenie,1).BoundingBox(1,2)+bbtstat(bbtpolozenie,1).BoundingBox(1,4)>(rozx-1))
                        bb_pow= bb_pow+dod_d;
                        tragedyjka=1;
                    end
                end
            end           
            elseif proba==0 && i==0.7 && nnz(IL_OB)==0
                R(eee,1).W_O(j,1).bz=1;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
             end
        end
        clearvars -except i j a z R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p  bb_pow proba proba2 STATS
    end
    
    end
    fprintf(' iteracja %d z 119 gotowa\n', eee)
    clearvars -except R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS
end

toc
clearvars -except R
%% obcięcie bounding box

for eee=1:119
    [a b]=size(R(eee,1).W_O);
    for i=1:a
        if R(eee,1).W_O(i,1).bz==0
            S=im2double(R(eee,1).W_O(i,1).SP);
            D=im2double(R(eee,1).W_O(i,1).SPR);
            stat=regionprops(S,'BoundingBox');
            statd=regionprops(D,'BoundingBox','Area');
            
            R(eee,1).W_O(i,1).bb_pr(1,1)=stat.BoundingBox(1,1)+R(eee,1).W_O(i,1).bb(1,1);
            R(eee,1).W_O(i,1).bb_pr(1,2)=stat.BoundingBox(1,2)+R(eee,1).W_O(i,1).bb(1,2);
            R(eee,1).W_O(i,1).bb_pr(1,3)=stat.BoundingBox(1,3);
            R(eee,1).W_O(i,1).bb_pr(1,4)=stat.BoundingBox(1,4);
            tt=statd.BoundingBox(1,3)*statd.BoundingBox(1,4);
            
            w(eee,i)=statd.Area/tt;
             
            if w(eee,i)<0.4
               R(eee,1).W_O(i,1).bz=1;
            end
            
            
        end
    end
end

clearvars -except R
