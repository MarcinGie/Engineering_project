% autor: E.Pastucha
% skrypt wczytuje wyniki przetwarzania sieci neuronowej na obrazach o
% zmniejszonej rozdzielczo�ci,  przeszukuje obrazy w trzech petlach zmiany
% progu znajduj�c obszary zainteresowania do dalszego przetwarzania w
% oryginalnej rozdzielczo�ci. Ustala ostateczn� wielko�� BoundingBox 


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
    DYL = imdilate(R(eee,1).K1_OST,dysk_2); %dylatacja tylko po to, �eby po��czy� obszary le��ce blisko w jeden
    
    IL=bwlabel(DYL);
    STATS = regionprops(IL, 'BoundingBox');
    R(eee,1).STATS=STATS;
    [a b]=size(STATS);
    
	for j=1:a
        bb_pow= STATS(j,1).BoundingBox; %pierwszy zakres przetwarzania
        proba=0; %warunek p�tli 
        proba2=0; %warunek p�tli 2
        WYCINEK=imcrop(R(eee,1).K1, bb_pow);
        B=im2bw(WYCINEK, R(eee,1).prog); %progowanie na podstawie pierwszego progu automatycznego
        B1 = bwareaopen(B, 10); % usuni�cie ma�ych obiekt�w
        IL_OB=bwlabel(B1,8);
        if nnz(IL_OB)>0
            stat_at=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
            poloz_at=find([stat_at.Area] == max([stat_at.Area]));
            [fa1_at fa2_at]=size(stat_at(poloz_at,1).FilledImage); 
            FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at); 
            mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength;
            if stat_at(poloz_at,1).Orientation<-85 || stat_at(poloz_at,1).Orientation>85
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
                if spt(sppol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
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
               	sp_fa=sprt(sprpol,1).Area/(spa*spb);
                ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
                
                for i=R(eee,1).prog:-0.0001:0.7
                    if proba3==1, break, end % wyj�cie z p�tli, je�eli zaczyna si� pogarsza�
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramer�w stat dla obrazu rozwa�anego
                    SN_0=im2bw(WYCINEK, i); %obraz binarny rozwa�any
                    SN = bwareaopen(SN_0, 50); %usuni�cie obszar�w poni�ej 300 pikseli
                    SNIL=bwlabel(SN); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                    % odnalezienie najwi�kszego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obr�t obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 10);
                    SNRIL=bwlabel(SNR);
                    %odnalezeienie najwi�kszego obszaru
                    snrt=regionprops(SNR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol=find([snrt.Area] == max([snrt.Area]));
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    % --------------------------------------------------------------------------------
                   	% obliczenie odleg�o�ci euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>3100
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(i+0.0001));
                      	R(eee,1).W_O(j,1).prog=i+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                        % obliczenie paramer�w stat dla obrazu rozwa�anego
                        bbt_0=im2bw(WYC, i); %obraz binarny rozwa�any
                        bbt = bwareaopen(bbt_0, 50); %usuni�cie obszar�w poni�ej 300 pikseli
                        bbtIL=bwlabel(bbt); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                        bbts=regionprops(bbtIL,'Area','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                        % odnalezienie najwi�kszego obszaru
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
      for i=1:-0.0001:0.7 % p�tla w�a�ciwego doboru progu
            
            WYCINEK=imcrop(R(eee,1).K1, bb_pow);

            if proba==1, break, end % wyj�cie z petli po wykryciu pierwszego znaku
            
            B=im2bw(WYCINEK,i); % progowanie na podstawie dynamicznego progu
            
            B1 = bwareaopen(B, 50); % usuni�cie ma�ych obiekt�w
            IL_OB=bwlabel(B1); % numerowanie pozosta�ych obiekt�w
            
            if nnz(IL_OB)>0
            stat=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage'); % statystyka pozosta�ych obiekt�w
            % nie powinno by� wiecej ni� jeden obiekt, ale je�eli co� takiego si� stanie, statystyka b�dzie brana pod uwag� dla najwi�kszego obiektu
            polo=find([stat.Area] == max([stat.Area]));
            polozenie=polo(1,1);
            [fa1 fa2]=size(stat(polozenie,1).FilledImage); 
            FA=stat(polozenie,1).Area/(fa1*fa2); %cze�� obszaru zaj�ta przez znak
            
            mimj=stat(polozenie,1).MinorAxisLength/stat(polozenie,1).MajorAxisLength; %stosunek x/y 
            if stat(polozenie,1).Orientation<-85 || stat(polozenie,1).Orientation>85
            	pr_fa=0.60;
            else
            	pr_fa=0.30;
            end
            
            
            if mimj<0.3 && mimj>0.1 && (stat(polozenie,1).Orientation<-60 || stat(polozenie,1).Orientation>60) && FA>pr_fa && stat(polozenie,1).Area>100 %wszystkie parametry wyznaczy�am na podstawie masek zbioru ucz�cego, oczywiscie z dodatkowym buforem bezpiecze�stwa
                R(eee,1).W_O(j,1).prog_i=i;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                
                if stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)>150 
                    bb_pow=(stat(polozenie,1).BoundingBox)+[bb_pow(1,1),bb_pow(1,2),0,0];
                elseif stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)<=150 % po x przyci�� po y zostawi�
                    bb_pow=[stat(polozenie,1).BoundingBox(1,1)+bb_pow(1,1),bb_pow(1,2),stat(polozenie,1).BoundingBox(1,3),bb_pow(1,4)];
                elseif stat(polozenie,1).BoundingBox(1,3)<50 && stat(polozenie,1).BoundingBox(1,3)>=150 % po y przyci�� po x zostawi�
                    bb_pow=[bb_pow(1,1),stat(polozenie,1).BoundingBox(1,2)+bb_pow(1,2),bb_pow(1,3),stat(polozenie,1).BoundingBox(1,4)];
                end
                WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                SP_0=im2bw(WYCINEK,(i));
                SP = bwareaopen(SP_0, 50);
                SPIL=bwlabel(SP);
                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                sppol=find([spt.Area] == max([spt.Area]));
                if spt(sppol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
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
                    if proba2==1, break, end % wyj�cie z p�tli, je�eli zaczyna si� pogarsza�
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramer�w stat dla obrazu rozwa�anego
                    SN_0=im2bw(WYCINEK, z); %obraz binarny rozwa�any
                    SN = bwareaopen(SN_0, 50); %usuni�cie obszar�w poni�ej 300 pikseli
                    SNIL=bwlabel(SN); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                    % odnalezienie najwi�kszego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obr�t obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 10);
                    SNRIL=bwlabel(SNR);
                    %odnalezeienie najwi�kszego obszaru
                    snrt=regionprops(SNR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol=find([snrt.Area] == max([snrt.Area]));
                    
                    
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    
                    
                    % --------------------------------------------------------------------------------
                
                   	% obliczenie odleg�o�ci euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>2500 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! by�o 3100, sprawdzenie jak teraz
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z+0.0001));
                      	R(eee,1).W_O(j,1).prog=z+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                        % obliczenie paramer�w stat dla obrazu rozwa�anego
                        bbt_0=im2bw(WYC, z); %obraz binarny rozwa�any
                        bbt = bwareaopen(bbt_0, 50); %usuni�cie obszar�w poni�ej 300 pikseli
                        bbtIL=bwlabel(bbt); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                        bbts=regionprops(bbtIL,'Area','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                        % odnalezienie najwi�kszego obszaru
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
            
                bbt1 = bwareaopen(bbt, 50); % usuni�cie ma�ych obiekt�w
                bbtIL_OB=bwlabel(bbt1); % numerowanie pozosta�ych obiekt�w
                bbtstat=regionprops(bbtIL_OB,'Area','BoundingBox'); % statystyka pozosta�ych obiekt�w
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
        for i=1:-0.0001:0.7 % p�tla w�a�ciwego doboru progu wersja z dylatacj� 
            
            WYCINEK=imcrop(R(eee,1).K1, bb_pow);

            if proba==1, break, end % wyj�cie z petli po wykryciu pierwszego znaku
            
            B=im2bw(WYCINEK,i); % progowanie na podstawie dynamicznego progu
            B1 = bwareaopen(B, 10); % usuni�cie ma�ych obiekt�w
            Bdyl=imdilate(B1,dysk);
            
            IL_OB=bwlabel(Bdyl); % numerowanie pozosta�ych obiekt�w
            
            if nnz(IL_OB)>0
            stat=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage'); % statystyka pozosta�ych obiekt�w
            % nie powinno by� wiecej ni� jeden obiekt, ale je�eli co� takiego si� stanie, statystyka b�dzie brana pod uwag� dla najwi�kszego obiektu
            polo=find([stat.Area] == max([stat.Area]));
            polozenie=polo(1,1);
            [fa1 fa2]=size(stat(polozenie,1).FilledImage); 
            FA=stat(polozenie,1).Area/(fa1*fa2); %cze�� obszaru zaj�ta przez znak
            
            mimj=stat(polozenie,1).MinorAxisLength/stat(polozenie,1).MajorAxisLength; %stosunek x/y 
            if stat(polozenie,1).Orientation<-85 || stat(polozenie,1).Orientation>85
            	pr_fa=0.60;
            else
            	pr_fa=0.30;
            end
            
            gugu=nnz(IL_OB);
            if mimj<0.4 && mimj>0.1 && (stat(polozenie,1).Orientation<-60 || stat(polozenie,1).Orientation>60) && FA>pr_fa && gugu>450 %wszystkie parametry wyznaczy�am na podstawie masek zbioru ucz�cego, oczywiscie z dodatkowym buforem bezpiecze�stwa
                R(eee,1).W_O(j,1).prog_i=i;
                R(eee,1).W_O(j,1).bb_i=bb_pow;
                R(eee,1).W_O(j,1).IL_OB=IL_OB;
                
                if stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)>150 
                    bb_pow=(stat(polozenie,1).BoundingBox)+[bb_pow(1,1),bb_pow(1,2),0,0];
                elseif stat(polozenie,1).BoundingBox(1,3)>50 && stat(polozenie,1).BoundingBox(1,3)<=150 % po x przyci�� po y zostawi�
                    bb_pow=[stat(polozenie,1).BoundingBox(1,1)+bb_pow(1,1),bb_pow(1,2),stat(polozenie,1).BoundingBox(1,3),bb_pow(1,4)];
                elseif stat(polozenie,1).BoundingBox(1,3)<50 && stat(polozenie,1).BoundingBox(1,3)>=150 % po y przyci�� po x zostawi�
                    bb_pow=[bb_pow(1,1),stat(polozenie,1).BoundingBox(1,2)+bb_pow(1,2),bb_pow(1,3),stat(polozenie,1).BoundingBox(1,4)];
                end
                WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                SP_0=im2bw(WYCINEK,(i));
                
                SP = bwareaopen(SP_0, 10);
                SPdyl=imdilate(SP,dysk);
                SPIL=bwlabel(SPdyl);
                spt=regionprops(SPIL,'Area','Orientation','BoundingBox');
                sppol=find([spt.Area] == max([spt.Area]));
                if spt(sppol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
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
                    if proba2==1, break, end % wyj�cie z p�tli, je�eli zaczyna si� pogarsza�
                    %-----------------------------------------------------------
                    WYCINEK=imcrop(R(eee,1).K1, bb_pow);
                    % obliczenie paramer�w stat dla obrazu rozwa�anego
                    SN_0=im2bw(WYCINEK, z); %obraz binarny rozwa�any
                    SN = bwareaopen(SN_0, 10); %usuni�cie obszar�w poni�ej 300 pikseli
                    SNdyl=imdilate(SN,dysk);
                    
                    SNIL=bwlabel(SNdyl); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                    snt=regionprops(SNIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                    % odnalezienie najwi�kszego obszaru
                    snpol=find([snt.Area] == max([snt.Area]));
                    
                    if snt(snpol,1).Orientation<0 %wyznaczenie k�ta dla imrotate
                    	kat=-90-snt(snpol,1).Orientation;
                    else
                    	kat=90-snt(snpol,1).Orientation;
                    end
                    % obr�t obrazu
                    SNR_0=imrotate(SN,kat);
                    SNR = bwareaopen(SNR_0, 5);
                    SNRIL=bwlabel(SNR_0);
                    %odnalezeienie najwi�kszego obszaru
                    snrt=regionprops(SNR_0,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
                    snrpol1=find([snrt.Area] == max([snrt.Area]));
                    snrpol=snrpol1(1,1);
                    
                    sn_mimj=(snrt(snrpol,1).MinorAxisLength)/(snrt(snrpol,1).MajorAxisLength);
                    [sna snb]=size(snrt(snrpol,1).FilledImage);
                    sn_fa=snrt(snrpol,1).Area/(sna*snb);
                    
                    
                    % --------------------------------------------------------------------------------
                
                   	% obliczenie odleg�o�ci euklidesowej
                   	ode_sn=sqrt(((sn_mimj-mimj_ideal)^2)+((sn_fa-fa_ideal)^2));
                    
                   	if ode_sn>ode_sp %& sprt(sprpol,1).Area>2500 %!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! by�o 3100, sprawdzenie jak teraz
                    	%stat_kon=regionprops(SP,'BoundingBox');
                     	R(eee,1).W_O(j,1).bz=0;
                      	R(eee,1).W_O(j,1).OB=im2bw(WYCINEK,(z+0.0001));
                      	R(eee,1).W_O(j,1).prog=z+0.0001;
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                       	R(eee,1).W_O(j,1).bb=bb_pow; % zapisanie parametr�w w celu p�niejszego wykorzystania
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
                        % obliczenie paramer�w stat dla obrazu rozwa�anego
                        bbt_0=im2bw(WYC, z); %obraz binarny rozwa�any
                        bbt = bwareaopen(bbt_0, 10); %usuni�cie obszar�w poni�ej 300 pikseli
                        bbtdyl=imdilate(bbt,dysk);
                        
                        bbtIL=bwlabel(bbtdyl); % mo�e zosta� teoretycznie wi�cej ni� 1 obszar, wi�c sprawdzenie
                        bbts=regionprops(bbtIL,'Area','Orientation','BoundingBox'); %po pierwsze orientacja do obrotu, ale te� powierzchnia, �eby orientacja by�a barna od najwi�kszego obszaru
                        % odnalezienie najwi�kszego obszaru
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
                bbt1 = bwareaopen(bbt, 10); % usuni�cie ma�ych obiekt�w
                bbtdyl=imdilate(bbt1,dysk);
                bbtIL_OB=bwlabel(bbtdyl); % numerowanie pozosta�ych obiekt�w
                bbtstat=regionprops(bbtIL_OB,'Area','BoundingBox'); % statystyka pozosta�ych obiekt�w
                % nie powinno by� wiecej ni� jeden obiekt, ale je�eli co� takiego si� stanie, statystyka b�dzie brana pod uwag� dla najwi�kszego obiektu
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
%% obci�cie bounding box

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


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
