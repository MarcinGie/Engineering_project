
% wczytanie obrazu testowego, zapis do struktury R, nast?pnie wst?pne
% przetwarzanie, zastosowanie pierwszego okre?lonego arbitralnie progu, i pierwsza
% binaryzacja obrazów


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\obrazy-uczenie\';
spis_tst = 'pliki.txt'; % spis plikow do testowania

fil_tst = fopen([sciezka_data spis_tst]);

%ladowanie, przyciecie i zmniejszenie zdjec
for eee=1:14
    nazwa_tst =fgetl(fil_tst);

    Obraz=imread([sciezka_data nazwa_tst]);
    [a,b]=size(Obraz);
    przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyciecia obrazu!!!!!
    O_3=imcrop(Obraz,przyciecie);
    Or=imresize(O_3,0.25); %% zmiana rozdzielczosci przetwarzania
    Or_hsv=rgb2hsv(Or);
    
    R(eee,1).Or_hsv=Or_hsv;
    R(eee,1).O=O_3;
    R(eee,1).nazwa=nazwa_tst;
    fprintf('Zdjecie %s zaladowane. Iteracja %d z 14 gotowa.\n', nazwa_tst, eee)
    
end
clearvars -except R

for eee=1:14
    % Convert RGB image to HSV
    hsvImage = R(eee,1).Or_hsv;
    % Extract out the H, S, and V images individually
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
%     figure(eee);
%     subplot(1,3,1);
%     imshow(hImage),title('Hue');
%     subplot(1,3,2);
%     imshow(sImage),title('Saturation');
%     subplot(1,3,3);
%     imshow(vImage),title('Value');
    
    % Assign the low and high thresholds for each color band.
    % Take a guess at the values that might work for the user's image.
    R(eee,1).hueThresholdLow = 0;
    R(eee,1).hueThresholdHigh = 50;
    R(eee,1).saturationThresholdLow = 100;
    R(eee,1).saturationThresholdHigh = 255;
    R(eee,1).valueThresholdLow = 22;
    R(eee,1).valueThresholdHigh = 255;
    
    % Now apply each color band's particular thresholds to the color band
    hueMask = (hImage >= double(R(eee,1).hueThresholdLow/255)) & (hImage <= double(R(eee,1).hueThresholdHigh/255));
    saturationMask = (sImage >= double(R(eee,1).saturationThresholdLow/255)) & (sImage <= double(R(eee,1).saturationThresholdHigh/255));
    valueMask = (vImage >= double(R(eee,1).valueThresholdLow/255)) & (vImage <= double(R(eee,1).valueThresholdHigh/255));

    % Combine the masks to find where all 3 are "true."
    orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);
    
    
    R(eee,1).K1pr_auto = orangeObjectsMask; %obraz progowania progiem automatycznym 
    P_300 = bwareaopen(R(eee,1).K1pr_auto, 50); %usuniecie obiektów o mniejszej iloœci pikseli niz 50
    P_WDZ = imfill(P_300, 'holes'); %wypelnienie dziur
   
    %1)
    STATS = regionprops(P_WDZ, 'Orientation'); %obliczenie orientacji wszystkich pojedynczych obiektów
    IL=bwlabel(P_WDZ); %zlabelowanie wszystkich obiektów
    ind = find([STATS.Orientation] >= 45 | [STATS.Orientation] <= -45); %wybór obiektów o odpowiednim nachyleniu
    P_ODS = ismember(IL,ind); %odsiew
    STATS = regionprops(P_ODS, 'MajorAxisLength','MinorAxisLength'); %obliczenie przekatnych obiektów
    [a,b]=size(STATS);
    if a>0
        for i=1:a %dodanie informacji o stosunku boków
            STATS(i,1).mimj=STATS(i,1).MinorAxisLength/STATS(i,1).MajorAxisLength;
        end 
        ind2 = find([STATS.mimj] > 0.05);
        ILL=bwlabel(P_ODS);
        P_ODS_2 = ismember(ILL,ind2); %odsiew chudzielców
    end
    
    %2)
    P_DO = bwareaopen(P_WDZ, 1000); %wszystkie duze obiekty
    
    % sumowanie obrazów 1) i 2)
    if a>0
        P_OST=P_DO+P_ODS_2;
    else
        P_OST=P_DO;
    end
    
    if nnz(P_OST)>0
        R(eee,1).K1_OST=P_OST; %wynik pierwszej czesci skryptu
        R(eee,1).t=1;
    else
        R(eee,1).t=0;    
    end
    fprintf('Zdjecie %s wstepnie przetworzone. Iteracja %d z 14 gotowa. t%d \n', R(eee,1).nazwa, eee, R(eee,1).t);
    figure;
    imshow(P_OST);
    clearvars -except R eee % czyszczenie, bo nie jestem w stanie kontrolowac, kiedy zmienna moze cos nabruzdzic przechodzac do nastepnej petli
end
clearvars -except R
toc