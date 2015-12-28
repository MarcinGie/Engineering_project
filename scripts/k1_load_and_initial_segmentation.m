% wczytanie obrazow, zapis do struktury R, nastepnie wstepna
% klasteryzacja i przetwarzanie


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\obrazy-uczenie\';
sciezka_sieci = 'C:\Users\Marcin\Desktop\Engineering_project\2015-01-skrypty\';
spis_tst = 'pliki.txt'; % spis plikow do testowania
nColors = 3;

fil_tst = fopen([sciezka_data spis_tst]);

for eee=1:14
    nazwa_tst =fgetl(fil_tst);

    Obraz=imread([sciezka_data nazwa_tst]);
    [a,b,c]=size(Obraz);
    przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyciêcia obrazu!!!!!
    O_3=imcrop(Obraz,przyciecie);
%     Or=imresize(O_3,0.25); %% zmiana rozdzielczoœci przetwarzania
%     Or_hsv=rgb2hsv(Or);
    [a,b,c]=size(O_3);
    D=cat(1,(reshape(O_3(:,:,1),1,(a*b))),(reshape(O_3(:,:,2),1,(a*b))),(reshape(O_3(:,:,3),1,(a*b))));
    K1=D;
    R(eee,1).K1=K1;
    R(eee,1).Or=O_3;
    R(eee,1).O=O_3;
    R(eee,1).nazwa=nazwa_tst;
    fprintf('Zdjecie %s wczytane. Iteracja %d z 14 gotowa\n', nazwa_tst, eee)
    
end
clearvars -except R nColors

for eee=1:14
    figure;    
    subplot(2,4,1);
    imshow(R(eee,1).Or),title('Original');
    
    % 2 Convert image from RGB to L*a*b space
    cform = makecform('srgb2lab');
    lab_he = applycform(R(eee,1).Or,cform);
    
    % 3 Classify the colors in *a*b space using k-means clustering
    ab = double(lab_he(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);

    
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'start','uniform','emptyaction','singleton','Replicates',3,'distance','sqEuclidean');

    % 4 Label every pixel in the Image using the results from k-means
    pixel_labels = reshape(cluster_idx,nrows,ncols);
    
    % 5 Create images that segment source image by color
    segmented_images = cell(1,3);
    rgb_label = repmat(pixel_labels,[1 1 3]);

    for k = 1:nColors
        color = R(eee,1).Or;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;

        subplot(2,4,k+1);
        t = sprintf('Cluster %d',k);
        imshow(im2bw(segmented_images{k},0.001)), title(t);
        
        R(eee,1).K1pr_auto(:,:,k) = im2bw(segmented_images{k},0.001);
        P_200 = bwareaopen(R(eee,1).K1pr_auto(:,:,k), 800); %usuniecie obiektów o mniejszej iloœci pikseli niz l00
        P_WDZ = imfill(P_200, 'holes'); %wypelnienie dziur
        
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

        P_DO = bwareaopen(P_WDZ, 8000); %wszystkie duze obiekty

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
   
    R(eee,1).nColors=nColors;
    fprintf('Zdjecie %s wstepnie przetworzone. Iteracja %d z 14 gotowa. %d \n', R(eee,1).nazwa, eee, R(eee,1).t)
    for k = 1:nColors
        if R(eee,1).t == 1
            subplot(2,4,k+4);
            t = sprintf('Result %d',k);
            imshow(R(eee,1).K1_OST(:,:,k)),title(t);
        end
    end
    clearvars -except R nColors % czyszczenie, bo nie jestem w stanie kontrolowac, kiedy zmienna moze cos nabruzdzic przechodzac dalej
    
end
clearvars -except R
toc