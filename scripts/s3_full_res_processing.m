
% przetwarzanie w zakresie BoundingBox znalezionego w etapie r_2
% na pe?nej rozdzielczo?ci. Doprecyzowanie wysoko?ci progu i ostateczna
% decyzja czy mamy do czynienia ze znakiem

tic
sciezka_sieci = 'C:\Users\Marcin\Desktop\2015-01-skrypty\';
spis_tst = 'pliki.txt'; % spis plikow do testowania
ile_klas = 2;  
nazwa_sieci='net_scalone_13'; %tu wybieramy siec

load([sciezka_sieci nazwa_sieci]); %ladowanie sieci
mimj_ideal=0.25;
fa_ideal=0.85;

for eee=1:14
	[a b]=size(R(eee,1).W_O);
    z=1;
    for j=1:a 
        if R(eee,1).W_O(j,1).bz==0 
        	% przeliczenie BoundingBox z uk?adu mniejszej rozdzielczo?ci na wi?ksz?
            R(eee,1).TZ(z,1).BB=4*R(eee,1).W_O(j,1).bb_pr;
            R(eee,1).TZ(z,1).Ow=imcrop(R(eee,1).O,R(eee,1).TZ(z,1).BB);
            Ow_hsv=rgb2hsv(R(eee,1).TZ(z,1).Ow);
            [aa bb cc]=size(R(eee,1).TZ(z,1).Ow);
            D=cat(1,(reshape(Ow_hsv(:,:,1),1,(aa*bb))),(reshape(Ow_hsv(:,:,2),1,(aa*bb))),(reshape(Ow_hsv(:,:,3),1,(aa*bb)))); % wektor wej?ciowy do sieci
            k1k2=sim(net2,D); %?adowanie macierzy do sieci
            K1=reshape(k1k2(1,:),aa,bb); %obraz odpowiedzi w?z?a K1 sieci 
            %przepisanie danych testowanych do innej cz??ci struktury, ?eby nie musie? sprawdza? za ka?dym razem czy wcze?niej nie zosta?o co? wykluczone z oblicze?
            R(eee,1).TZ(z,1).K1=K1; 
            R(eee,1).TZ(z,1).prog=R(eee,1).W_O(j,1).prog;
            z=z+1;
            clear D Ow_hsv aa bb cc k1k2 K1 %czyszczenie danych, bo ju? mi brakuje pomys?ów w nazewnictwie zmiennych
        end
    end
end
%%
for eee=1:14
    [a b]=size(R(eee,1).TZ);
    for j=1:a
    	K=im2bw(R(eee,1).TZ(j,1).K1,R(eee,1).TZ(j,1).prog);
    	KK = bwareaopen(K, 100);
        if nnz(KK)>0
            pr=R(eee,1).TZ(j,1).prog;
            B=im2double(KK);
            stat=regionprops(B,'Orientation');
            if stat.Orientation<0 %wyznaczenie k?ta dla imrotate
                kat=-90-stat.Orientation;
            else
                kat=90-stat.Orientation;
            end
            BR=imrotate(B,kat);
            BR_stat=regionprops(BR,'Area','MajorAxisLength','MinorAxisLength','BoundingBox');
            BR_mimj=BR_stat.MinorAxisLength/BR_stat.MajorAxisLength;
            BR_FA=BR_stat.Area/(BR_stat.BoundingBox(1,3)*BR_stat.BoundingBox(1,4));
            BR_ode=sqrt(((BR_mimj-mimj_ideal)^2)+((BR_FA-fa_ideal)^2));
            proba=0;
            R(eee,1).TZ(j,1).bz=1;
            if pr>0.7
            for i=(pr-0.0001):-0.0001:0.7 % w poprzednim etapie dobierano w ten sposób próg, ale robiono to w mniejszej rozdzielczo?ci, i z dylatacj? wi?c wyniki mog? si? znacznie ró?ni?. St?d powtórne przetwarzanie.
                if proba==1, break, end 
                Z=im2bw(R(eee,1).TZ(j,1).K1,i);
                ZZ=bwareaopen(Z, 100);
                W=im2double(ZZ);
                W_stat=regionprops(W,'Orientation');
                if W_stat.Orientation<0 %wyznaczenie k?ta dla imrotate
                    kat=-90-W_stat.Orientation;
                else
                    kat=90-W_stat.Orientation;
                end
                WR=imrotate(W,kat);
                WR_stat=regionprops(WR,'Area','MajorAxisLength','MinorAxisLength','BoundingBox');
                WR_mimj=WR_stat.MinorAxisLength/WR_stat.MajorAxisLength;
                WR_FA=WR_stat.Area/(WR_stat.BoundingBox(1,3)*WR_stat.BoundingBox(1,4));
                WR_ode=sqrt(((WR_mimj-mimj_ideal)^2)+((WR_FA-fa_ideal)^2));
                
                
                
                
                if WR_ode>BR_ode && BR_ode<0.3
                    proba=1;
                    nowy_prog=i+0.0001;
                    R(eee,1).TZ(j,1).prog_ost=nowy_prog;
                    KZ=im2bw(R(eee,1).TZ(j,1).K1,nowy_prog);
                    KZZ=bwareaopen(KZ, 100);
                    KW=im2double(KZZ);
                    KW_stat=regionprops(KW,'Orientation');
                    if KW_stat.Orientation<0 %wyznaczenie k?ta dla imrotate
                        kat=-90-KW_stat.Orientation;
                    else
                        kat=90-KW_stat.Orientation;
                    end
                    KWR=imrotate(KW,kat);
                    R(eee,1).TZ(j,1).KandydatZnak=KWR;
                    R(eee,1).TZ(j,1).odl_ide=BR_ode;
                    R(eee,1).TZ(j,1).bz=0;
                    fprintf('tu');
                elseif i==0.7 && WR_ode<0.3
                    nowy_prog=i;
                    R(eee,1).TZ(j,1).prog_ost=nowy_prog;
                    KZ=im2bw(R(eee,1).TZ(j,1).K1,nowy_prog);
                    KZZ=bwareaopen(KZ, 100);
                    KW=im2double(KZZ);
                    KW_stat=regionprops(KW,'Orientation');
                    if KW_stat.Orientation<0 %wyznaczenie k?ta dla imrotate
                        kat=-90-KW_stat.Orientation;
                    else
                        kat=90-KW_stat.Orientation;
                    end
                    KWR=imrotate(KW,kat);
                    R(eee,1).TZ(j,1).KandydatZnak=KWR;
                    R(eee,1).TZ(j,1).odl_ide=WR_ode;
                    R(eee,1).TZ(j,1).bz=0;
                elseif i>0.7 
                    BR_ode=WR_ode;
                else
                    R(eee,1).TZ(j,1).bz=1;
                end
            end
            else 
                R(eee,1).TZ(j,1).prog_ost=0.7;
                KZ=im2bw(R(eee,1).TZ(j,1).K1,0.7);
                KZZ=bwareaopen(KZ, 100);
                KW=im2double(KZZ);
                KW_stat=regionprops(KW,'Orientation');
                if KW_stat.Orientation<0 %wyznaczenie k?ta dla imrotate
                    kat=-90-KW_stat.Orientation;
                else
                    kat=90-KW_stat.Orientation;
                end
                KWR=imrotate(KW,kat);
                KWR_stat=regionprops(KWR,'Area','MajorAxisLength','MinorAxisLength','BoundingBox');
                KWR_mimj=KWR_stat.MinorAxisLength/KWR_stat.MajorAxisLength;
                KWR_FA=KWR_stat.Area/(KWR_stat.BoundingBox(1,3)*KWR_stat.BoundingBox(1,4));
                KWR_ode=sqrt(((KWR_mimj-mimj_ideal)^2)+((KWR_FA-fa_ideal)^2));
                R(eee,1).TZ(j,1).KandydatZnak=KWR;
                R(eee,1).TZ(j,1).odl_ide=KWR_ode;
                R(eee,1).TZ(j,1).bz=0;
            end
            %if R(eee,1).TZ(j,1).bz==0
                %figure(eee);subplot(1,a,j);imshow(KWR);
            %end
            clearvars -except sciezka_data sciezka_sieci spis_tst nazwa_sieci net2 mimj_ideal fa_ideal R eee a j
        else
            R(eee,1).TZ(j,1).bz=1;
        end
    end
    fprintf(' iteracja %d z 119 gotowa\n', eee)
    clearvars -except sciezka_data sciezka_sieci spis_tst nazwa_sieci net2 mimj_ideal fa_ideal R eee a j
end
toc