
% przetwarzanie w zakresie BoundingBox znalezionego w etapie r_2, klasteryzacja i ostateczna
% decyzja czy mamy do czynienia ze znakiem

tic
sciezka_sieci = 'C:\Users\Marcin\Desktop\2015-01-skrypty\';

dysk = strel('disk',4);
mimj_ideal=0.25;
fa_ideal=0.85;
close all;


for eee=1:14
    [a b]=size(R(eee,1).W_O);
    i=1;
    for j=1:a
        figure;
        subplot(1,4,1);
        t=sprintf('zdjecie %d',eee);
        imshow(R(eee,1).W_O(j,1).O_cropped),title(t);
        nColors=2;
        fprintf('\nklasteryzacja - %d klastrow', nColors);
        %2 Convert image from RGB to L*a*b space
        cform = makecform('srgb2lab');
        lab_he = applycform(R(eee,1).W_O(j,1).O_cropped,cform);

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
            color = R(eee,1).W_O(j,1).O_cropped;
            color(rgb_label ~= k) = 0;
            segmented_images{k} = color;
            
            R(eee,1).W_O(j,1).K1pr_auto(:,:,k) = im2bw(segmented_images{k},0.001);
            P_200 = bwareaopen(R(eee,1).W_O(j,1).K1pr_auto(:,:,k), 800); %usuniecie obiektów o mniejszej iloœci pikseli niz 800
            DYL = imdilate(P_200,dysk); %dylatacja tylko po to, zeby polaczyc obszary lezce blisko w jeden
            P_WDZ = imfill(DYL, 'holes'); %wypelnienie dziur
            subplot(1,4,k+1);
            imshow(P_WDZ);
% - sprawdzenie czy faktycznie mamy znak
            

            B1 = bwareaopen(P_WDZ, 200); % usuniecie malych obiektów
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

                if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at && FA_at<1 && stat_at(poloz_at,1).Area>6500

                    SP_0=B1;
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
                    fprintf('\nrozmiar %d obiekt %d cos jak znak: %f',stat_at(poloz_at,1).Area,j,ode_sp);
                    if ode_sp < 0.20
                                     %jesli sprawdzany obiekt ma lepsze ode niz najlepszy dotychczasowy
                            t=sprintf('\nrozmiar jak znak: %f',stat_at(poloz_at,1).Area);
                            SPR_cropped=imcrop(SPR,sprt(sprpol,1).BoundingBox);
                            subplot(1,4,4);
                            im=imcrop(imrotate(DYL,kat),sprt(sprpol,1).BoundingBox);
                            imshow(im),title(t);
%                             i=i+1;
                            R(eee,1).TZ(i,1).KandydatZnak=im;
                            R(eee,1).TZ(i,1).bz=0;
                    end
                else
                    R(eee,1).bz=1;
                end
            end
        end
    end
    fprintf(' iteracja %d z 14 gotowa\n', eee)
    clearvars -except dysk sciezka_data sciezka_sieci spis_tst nazwa_sieci net2 mimj_ideal fa_ideal R eee a j
end
toc