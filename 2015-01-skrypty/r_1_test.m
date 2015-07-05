
% autor El¿bieta Pastucha 
% sieæ net_scalone_13 
% wczytanie obrazu testowego, zmiana rozdzielczoœci do 0.25, przetworzenie
% przez sieæ, zapis wyników do struktury R, nastêpnie wstêpne
% przetwarzanie, wykrycie pierwszego automatycznego progu, i pierwsza
% binaryzacja obrazów


clear all, close all;
tic
sciezka_data = 'C:\Users\Marcin\Desktop\W11p\obrazy-test2\';
sciezka_sieci = 'C:\Users\Marcin\Desktop\2015-01-skrypty\';
spis_tst = 'pliki.txt'; % spis plikow do testowania
nazwa_sieci='net_scalone_13'; %tu wybieramy siec

load([sciezka_sieci nazwa_sieci]); %ladowanie sieci
fil_tst = fopen([sciezka_data spis_tst]); 

for eee=1:119
    nazwa_tst =fgetl(fil_tst);

    % Przetwarzanie obrazu o zmniejszonej rozdzielczoœci
    O=imread([sciezka_data nazwa_tst]);
    [a b c]=size(O);
    przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyciêcia obrazu!!!!!
    O_3=imcrop(O,przyciecie);
    Or=imresize(O_3,0.25); %% zmiana rozdzielczoœci przetwarzania
    Or_hsv=rgb2hsv(Or);
    [a b c]=size(Or);
    D=cat(1,(reshape(Or_hsv(:,:,1),1,(a*b))),(reshape(Or_hsv(:,:,2),1,(a*b))),(reshape(Or_hsv(:,:,3),1,(a*b))));
    k1k2=sim(net2,D); % ³adowanie macierzy do sieci
    K1=reshape(k1k2(1,:),a,b);
    R(eee,1).K1=K1;
    R(eee,1).Or_hsv=Or_hsv;
    R(eee,1).Or=Or;
    R(eee,1).O=O_3;
    R(eee,1).nazwa=nazwa_tst;
    fprintf('Zdjêcie %s iteracja %d z 119 gotowa\n', nazwa_tst, eee)
    
end
clearvars -except R
%%
for eee=1:119
    %utworzenie histogramu z podzia³em na 1000 celek
    R(eee,1).H=(hist(R(eee,1).K1(:),1000))';
    R(eee,1).H(:,2)=[1:1000]/1000; %dodanie osi poziomej histogramu, aby umo¿liwiæ odczytanie progu
     
    % zliczenie komórek histogramu od ty³u w celu zebrania 10000
    % najjaœniejszych, i odczytania progu odgraniczaj¹cego je od reszty
    zlicz=0;
    for i=1000:-1:1
        zlicz=zlicz+R(eee,1).H(i,1);
        if zlicz>10000 
            break
        else
            continue
        end
    end
    R(eee,1).prog=R(eee,1).H(i,2); %próg automatyczny
    
    if  R(eee,1).prog<0.7 % blokada progu na wypadek obrazu bez znaku (na podstawie maski_wyciete.m)
        R(eee,1).prog=0.7;
    end
    
    % utworzenie obrazu z obszarami zainteresowania, ze wzgl. na mo¿liwoœæ
    % przyklejania siê pikseli nie prawidlowych do znaku dwie mo¿liwoœci
    % 1)obszary o odpowiedniej wielkoœci w miarê pionowe, i nie super chude 2) obszary b.du¿e 
    
    
    R(eee,1).K1pr_auto= im2bw(R(eee,1).K1, R(eee,1).prog); %obraz progowania progiem automatycznym 
    P_300 = bwareaopen(R(eee,1).K1pr_auto, 50); %usuniêcie obiektów o mniejszej iloœci pikseli ni¿ 50
    P_WDZ = imfill(P_300, 'holes'); %wype³nienie dziur
    
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
    P_DO = bwareaopen(P_WDZ, 2000); %wszystkie du¿e obiekty
    
    
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
    fprintf('Zdjêcie %s iteracja %d z 119 gotowa. %d \n', R(eee,1).nazwa, eee, R(eee,1).t)
    %figure(eee);imshow(P_OST);
    clearvars -except R eee % czyszczenie, bo nie jestem w stanie kontrolowaæ, kiedy zmienna mo¿e coœ nabruŸdziæ przechodz¹c do nastêpnej pêtli
    
end
clearvars -except R
toc