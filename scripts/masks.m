
% wczytanie obrazu testowego, zapis do struktury R, nast?pnie wst?pne
% przetwarzanie, zastosowanie pierwszego okre?lonego arbitralnie progu, i pierwsza
% binaryzacja obrazów


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\maski\';
spis_tst = 'pliki.txt'; % spis plikow do testowania

mimj_ideal=0.267;
fa_ideal=0.85;
fil_tst = fopen([sciezka_data spis_tst]);

%ladowanie, przyciecie i zmniejszenie zdjec
for eee=1:14
    nazwa_tst =fgetl(fil_tst);

    Obraz=imread([sciezka_data nazwa_tst]);
    IL=bwlabel(Obraz);
    STATS = regionprops(IL,'BoundingBox', 'MajorAxisLength','MinorAxisLength','Orientation','FilledImage','Area');
    [a,b]=size(STATS);
    
    for j=1:b
        mimj=STATS(j,1).MinorAxisLength/STATS(j,1).MajorAxisLength;
        bb_pow= STATS(j,1).BoundingBox;
        WYCINEK=imcrop(Obraz, bb_pow);
        IL_OB=bwlabel(WYCINEK,8);
        stat_at=regionprops(IL_OB,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
        poloz_at=find([stat_at.Area] == max([stat_at.Area])); %znalezienie najwiekszego obiektu
        [fa1_at,fa2_at]=size(stat_at(poloz_at,1).FilledImage); %pobranie rozmiarów bounding box obiektu
        FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at); %czesc obszaru zajeta przez znak
        mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength; %stusunek dlugosci boków
        
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
        
        fprintf('\nzdjecie %d mimj_at %f orientation %f FA_at %f Area %d ode %f',eee,mimj_at,stat_at(poloz_at,1).Orientation,FA_at,stat_at(poloz_at,1).Area,ode_sp);
    end
    
%     fprintf('Zdjecie %s iteracja %d z 14 gotowa\n', nazwa_tst, eee)
    
end

toc