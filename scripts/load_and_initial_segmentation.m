
% wczytanie obrazu testowego, zapis do struktury R, nast?pnie wst?pne
% przetwarzanie, zastosowanie pierwszego okre?lonego arbitralnie progu, i pierwsza
% binaryzacja obrazów


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\obrazy-uczenie\';
sciezka_sieci = 'C:\Users\Marcin\Desktop\Engineering_project\2015-01-skrypty\';
spis_tst = 'pliki.txt'; % spis plikow do testowania

fil_tst = fopen([sciezka_data spis_tst]);

for eee=1:14
    nazwa_tst =fgetl(fil_tst);

    Obraz=imread([sciezka_data nazwa_tst]);
    [a b c]=size(Obraz);
    przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyciêcia obrazu!!!!!
    O_3=imcrop(Obraz,przyciecie);
    Or_hsv=rgb2hsv(O_3);
    [a b c]=size(O_3);
    D=cat(1,(reshape(Or_hsv(:,:,1),1,(a*b))),(reshape(Or_hsv(:,:,2),1,(a*b))),(reshape(Or_hsv(:,:,3),1,(a*b))));
    K1=D;
    R(eee,1).K1=K1;
    R(eee,1).Or_hsv=Or_hsv;
    R(eee,1).O=O_3;
    R(eee,1).nazwa=nazwa_tst;
    fprintf('Zdjêcie %s iteracja %d z 14 gotowa\n', nazwa_tst, eee)
    
end
clearvars -except R
%%
for eee=1:14
    
    % Convert RGB image to HSV
    hsvImage = R(eee,1).Or_hsv;
    % Extract out the H, S, and V images individually
    hImage = hsvImage(:,:,1);
    sImage = hsvImage(:,:,2);
    vImage = hsvImage(:,:,3);
    
    % Assign the low and high thresholds for each color band.
    % Take a guess at the values that might work for the user's image.
    hueThresholdLow = double(0/255);
    hueThresholdHigh = double(19/255);
    saturationThresholdLow = double(30/255);
    saturationThresholdHigh = double(255/255);
    valueThresholdLow = double(50/255);
    valueThresholdHigh = double(255/255);
    
    % Now apply each color band's particular thresholds to the color band
    hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
    saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
    valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

    % Combine the masks to find where all 3 are "true."
    orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);
    
    
    R(eee,1).K1pr_auto = orangeObjectsMask; %obraz progowania progiem automatycznym 
    P_300 = bwareaopen(R(eee,1).K1pr_auto, 200); %usuniêcie obiektów o mniejszej iloœci pikseli ni¿ 50
    P_WDZ = imfill(P_300, 'holes'); %wype³nienie dziur
 %%   
    %1)
    STATS = regionprops(P_WDZ, 'Orientation'); %obliczenie orientacji wszystkich pojedynczych obiektów
    IL=bwlabel(P_WDZ); %zlabelowanie wszystkich obiektów
    ind = find([STATS.Orientation] >= 45 | [STATS.Orientation] <= -45); %wybór obiektów o odpowiednim nachyleniu
    P_ODS = ismember(IL,ind); %odsiew
    STATS = regionprops(P_ODS, 'MajorAxisLength','MinorAxisLength'); %obliczenie przek¹tnych obiektów
    [a b]=size(STATS);
    if a>0
        for i=1:a %dodanie informacji o stosunku boków
            STATS(i,1).mimj=STATS(i,1).MinorAxisLength/STATS(i,1).MajorAxisLength;
        end
        ind2 = find([STATS.mimj] > 0.05);
        ILL=bwlabel(P_ODS);
        P_ODS_2 = ismember(ILL,ind2); %odsiew chudzielców
    end
    
    %2)
    P_DO = bwareaopen(P_WDZ, 8000); %wszystkie du¿e obiekty
    
    % sumowanie obrazów 1) i 2)
    if a>0
        P_OST=P_DO+P_ODS_2;
    else
        P_OST=P_DO;
    end
    
    if nnz(P_OST)>0
        R(eee,1).K1_OST=P_OST; %wynik pierwszej czêœci skryptu
        R(eee,1).t=1;
    else
        R(eee,1).t=0;    
    end
    fprintf('Zdjêcie %s iteracja %d z 14 gotowa. %d \n', R(eee,1).nazwa, eee, R(eee,1).t)
    figure(eee);imshow(P_OST);
    clearvars -except R eee % czyszczenie, bo nie jestem w stanie kontrolowaæ, kiedy zmienna mo¿e coœ nabruŸdziæ przechodz¹c do nastêpnej pêtli
    
end
clearvars -except R
toc