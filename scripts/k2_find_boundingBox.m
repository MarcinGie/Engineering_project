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


for eee=1:il_zdjec %dla kazdego zdjecia
    
    if R(eee,1).t==1
        
        nColors=R(eee,1).nColors;
        znaleziono_znak=0;
        fprintf('\nZDJECIE %d',eee);
        R(eee,1).OB_curr=R(eee,1).Or;
        bb = regionprops(R(eee,1).Or,'BoundingBox');
        R(eee,1).bb_curr=bb.BoundingBox;
        R(eee,1).klaster_curr=1;  
        R(eee,1).il_kand=0;
        while (znaleziono_znak==0 && nColors<14)
            
            fprintf('\nIlosc klastrow %d',nColors);
            R(eee,1).ode_min(nColors)=1;
            
            for k=1:nColors %dla kazdego klastra
                DYL = imdilate(R(eee,1).K1_OST(:,:,k),dysk); %dylatacja tylko po to, zeby polaczyc obszary lezce blisko w jeden
                P_WDZ = imfill(DYL, 'holes'); %wypelnienie dziur
                IL=bwlabel(P_WDZ);
                STATS = regionprops(IL, 'BoundingBox'); 
                R(eee,1).STATS=STATS;
                [a,b]=size(STATS);
                
                for j=1:a %dla kazdego obiektu w klastrze
                   
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
            
                        if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at && stat_at(poloz_at,1).Area>5800

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
                            if ode_sp < 0.35
                                if ode_sp<R(eee,1).ode_min(nColors)             %jesli sprawdzany obiekt ma lepsze ode niz najlepszy dotychczasowy
                                    fprintf('\nklaster %d obiekt %d cos jak znak: %f',k,j,ode_sp);
                                    SPR_cropped=imcrop(SPR,sprt(sprpol,1).BoundingBox);
                                    R(eee,1).ode_min(nColors)=ode_sp;
                                    R(eee,1).bz=0;
                                    R(eee,1).OB_prev=R(eee,1).OB_curr;          %poprzedni najlepiej dopasowany obiekt
                                    R(eee,1).OB_curr=SPR_cropped;               %obecny najlepiej dopasowany obiekt
                                    R(eee,1).klaster_prev=R(eee,1).klaster_curr;%poprzedni klaster z najlepiej dopasowanym obiektem
                                    R(eee,1).klaster_curr=k;                    %obecny klaster z najlepiej dopasowanym obiektem
                                    R(eee,1).bb_prev=R(eee,1).bb_curr;
                                    R(eee,1).bb_curr=bb_pow;
                                    R(eee,1).klas_max=nColors;
                                    R(eee,1).il_kand=R(eee,1).il_kand+1;
                                    R(eee,1).bb_kand(:,R(eee,1).il_kand)=bb_pow;
                                    R(eee,1).spr_kand{R(eee,1).il_kand}=SPR_cropped;
                                    R(eee,1).kat(R(eee,1).il_kand)=kat;
                                end
                            end
                        else
                            R(eee,1).bz=1;
                        end
                         clearvars -except il_zdjec k i j a R eee dysk dysk_2 mimj_ideal fa_ideal bb_pow proba proba2 STATS znaleziono_znak IL nColors
                    end
                end
                
            end
            fprintf('\nWynik klasteryzacji: %f',R(eee,1).ode_min(nColors));
            
            if nColors>3 %jesli wykonali?my kolejne klasteryzacje
                if R(eee,1).ode_min(nColors-1)<R(eee,1).ode_min(nColors) %jesli obiekt w poprzedniej klasteryzacji jest lepiej dopasowany niz obecnie
                    fprintf('\nZnaleziono znak. Ilosc kandydatow %d',R(eee,1).il_kand);
                    znaleziono_znak=1;
                    R(eee,1).il_klastrow=nColors-1;
                    for i=1:R(eee,1).il_kand
                        R(eee,1).W_O(i,1).bb=R(eee,1).bb_kand(:,i);
                        R(eee,1).W_O(i,1).KandydaW_Onak=R(eee,1).spr_kand{i};
                        R(eee,1).W_O(i,1).kat=R(eee,1).kat(i);
                        R(eee,1).W_O(i,1).bz=0;
                        R(eee,1).W_O(i,1).O_cropped=imcrop(R(eee,1).O,R(eee,1).bb_kand(:,i));
                    end
                end
            end
            
            if znaleziono_znak==0 %jesli nie znaleziono znaku, wykonujemy klasteryzacje n+1 i sprawdzamy jeszcze raz
                nColors=nColors+1;
                fprintf('\nklasteryzacja - %d klastrow', nColors);
                %2 Convert image from RGB to L*a*b space
                cform = makecform('srgb2lab');
                lab_he = applycform(R(eee,1).Or,cform);

                %3 Classify the colors in *a*b space using k-means clustering
                ab = double(lab_he(:,:,2:3));
                nrows = size(ab,1);
                ncols = size(ab,2);
                ab = reshape(ab,nrows*ncols,2);

                % repeat the clustering 3 times to avoid local minima
                [cluster_idx, cluster_center] = kmeans(ab,nColors,'start','uniform','emptyaction','singleton','Replicates',3,'distance','sqEuclidean');

                %4 Label every pixel in the Image using the results from k-means
                pixel_labels = reshape(cluster_idx,nrows,ncols);

                %5 Create images that segment source image by color
                segmented_images = cell(1,3);
                rgb_label = repmat(pixel_labels,[1 1 3]);
                
                for k = 1:nColors
                    color = R(eee,1).Or;
                    color(rgb_label ~= k) = 0;
                    segmented_images{k} = color;

                    R(eee,1).K1pr_auto(:,:,k) = im2bw(segmented_images{k},0.001);
                    P_200 = bwareaopen(R(eee,1).K1pr_auto(:,:,k), 800); %usuniecie obiektów o mniejszej iloœci pikseli niz 800
                    P_WDZ = imfill(P_200, 'holes'); %wypelnienie dziur

                    %1)
                    STATS = regionprops(P_WDZ, 'Orientation'); %obliczenie orientacji wszystkich pojedynczych obiektów
                    IL=bwlabel(P_WDZ); %zlabelowanie wszystkich obiektów
                    ind = find([STATS.Orientation] >= 45 | [STATS.Orientation] <= -45); %wybór obiektów o odpowiednim nachyleniu
                    P_ODS = ismember(IL,ind); %odsiew
                    STATS = regionprops(P_ODS, 'MajorAxisLength','MinorAxisLength'); %obliczenie przekatnych obiektów
                    [a b]=size(STATS);
                    if a>0
                        for i=1:a %dodanie informacji o stosunku boków
                            STATS(i,1).mimj=STATS(i,1).MinorAxisLength/STATS(i,1).MajorAxisLength;
                        end
                        ind2 = find([STATS.mimj] > 0.05);
                        ILL = bwlabel(P_ODS);
                        P_ODS_2 = ismember(ILL,ind2); %odsiew chudzielców
                    end

                    %2)
                    P_DO = bwareaopen(P_WDZ, 6000); %wszystkie du¿e obiekty

                    % sumowanie obrazów 1) i 2)
                    if a>0
                        P_OST=P_DO+P_ODS_2;
                    else
                        P_OST=P_DO;
                    end

                    if nnz(P_OST)>0
                        R(eee,1).K1_OST(:,:,k)=P_OST; %wynik pierwszej czesci skryptu
                        R(eee,1).t=1;
                    else
                        R(eee,1).t=0;    
                    end

                end
            end
        end
        if znaleziono_znak==0
            fprintf('Nie znaleziono znaku');
        end
        fprintf('\niteracja %d z 14 gotowa\n', eee)
        clearvars -except il_zdjec R eee dysk dysk_2 mimj_ideal fa_ideal dod_g dod_d dod_l dod_p bb_pow proba proba2 STATS znaleziono_znak IL
       
    end
end

for eee=1:il_zdjec
%     figure;
%     subplot(1,3,1);
%     imshow(R(eee,1).K1_OST(:,:,R(eee,1).klaster_prev)),title('klaster');
%     t=sprintf('Zdj.%d il.kl.%d kl.%d ode:%f',eee,R(eee,1).il_klastrow,R(eee,1).klaster_prev,R(eee,1).ode_min(R(eee,1).il_klastrow));
%     subplot(1,3,2);
%     if R(eee,1).klas_max==3 % mamy co?, ale w kolejnej klastereyzacji ju? niczego nie znalazlo
%         imshow(R(eee,1).OB_curr),title(t);
%         im = imcrop(R(eee,1).Or,R(eee,1).bb_curr);
%     else
%         imshow(R(eee, 1).OB_prev),title(t);
%         im = imcrop(R(eee,1).Or,R(eee,1).bb_prev);
%     end
%     
%     subplot(1,3,3);
%     imshow(im),title('original cropped');
    figure;
    for i=1:R(eee,1).il_kand
        subplot(3,5,i);
        bb=R(eee,1).bb_kand(:,i);
        im = imcrop(R(eee,1).Or,bb);
        imshow(im);
    end
end
toc
clearvars -except R
