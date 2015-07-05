
% autor El�bieta Pastucha 
% sie� net_scalone_13 
% wczytanie obrazu testowego, zmiana rozdzielczo�ci do 0.25, przetworzenie
% przez sie�, zapis wynik�w do struktury R, nast�pnie wst�pne
% przetwarzanie, wykrycie pierwszego automatycznego progu, i pierwsza
% binaryzacja obraz�w


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

    % Przetwarzanie obrazu o zmniejszonej rozdzielczo�ci
    O=imread([sciezka_data nazwa_tst]);
    [a b c]=size(O);
    przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyci�cia obrazu!!!!!
    O_3=imcrop(O,przyciecie);
    Or=imresize(O_3,0.25); %% zmiana rozdzielczo�ci przetwarzania
    Or_hsv=rgb2hsv(Or);
    [a b c]=size(Or);
    D=cat(1,(reshape(Or_hsv(:,:,1),1,(a*b))),(reshape(Or_hsv(:,:,2),1,(a*b))),(reshape(Or_hsv(:,:,3),1,(a*b))));
    k1k2=sim(net2,D); % �adowanie macierzy do sieci
    K1=reshape(k1k2(1,:),a,b);
    R(eee,1).K1=K1;
    R(eee,1).Or_hsv=Or_hsv;
    R(eee,1).Or=Or;
    R(eee,1).O=O_3;
    R(eee,1).nazwa=nazwa_tst;
    fprintf('Zdj�cie %s iteracja %d z 119 gotowa\n', nazwa_tst, eee)
    
end
clearvars -except R
%%
for eee=1:119
    %utworzenie histogramu z podzia�em na 1000 celek
    R(eee,1).H=(hist(R(eee,1).K1(:),1000))';
    R(eee,1).H(:,2)=[1:1000]/1000; %dodanie osi poziomej histogramu, aby umo�liwi� odczytanie progu
     
    % zliczenie kom�rek histogramu od ty�u w celu zebrania 10000
    % najja�niejszych, i odczytania progu odgraniczaj�cego je od reszty
    zlicz=0;
    for i=1000:-1:1
        zlicz=zlicz+R(eee,1).H(i,1);
        if zlicz>10000 
            break
        else
            continue
        end
    end
    R(eee,1).prog=R(eee,1).H(i,2); %pr�g automatyczny
    
    if  R(eee,1).prog<0.7 % blokada progu na wypadek obrazu bez znaku (na podstawie maski_wyciete.m)
        R(eee,1).prog=0.7;
    end
    
    % utworzenie obrazu z obszarami zainteresowania, ze wzgl. na mo�liwo��
    % przyklejania si� pikseli nie prawidlowych do znaku dwie mo�liwo�ci
    % 1)obszary o odpowiedniej wielko�ci w miar� pionowe, i nie super chude 2) obszary b.du�e 
    
    
    R(eee,1).K1pr_auto= im2bw(R(eee,1).K1, R(eee,1).prog); %obraz progowania progiem automatycznym 
    P_300 = bwareaopen(R(eee,1).K1pr_auto, 50); %usuni�cie obiekt�w o mniejszej ilo�ci pikseli ni� 50
    P_WDZ = imfill(P_300, 'holes'); %wype�nienie dziur
    
    %1)
    STATS = regionprops(P_WDZ, 'Orientation'); %obliczenie orientacji wszystkich pojedynczych obiekt�w
    IL=bwlabel(P_WDZ); %zlabelowanie wszystkich obiekt�w
    ind = find([STATS.Orientation] >= 45 | [STATS.Orientation] <= -45); %wyb�r obiekt�w o odpowiednim nachyleniu
    P_ODS = ismember(IL,ind); %odsiew
    STATS = regionprops(P_ODS, 'MajorAxisLength','MinorAxisLength'); %obliczenie przek�tnych obiekt�w
    [a b]=size(STATS);
    if a>0
        for i=1:a %dodanie informacji o stosunku bok�w
            STATS(i,1).mimj=STATS(i,1).MinorAxisLength/STATS(i,1).MajorAxisLength; 
        end
        ind2 = find([STATS.mimj] > 0.05);
        ILL=bwlabel(P_ODS);
        P_ODS_2 = ismember(ILL,ind2); %odsiew chudzielc�w
    end
    
    %2)
    P_DO = bwareaopen(P_WDZ, 2000); %wszystkie du�e obiekty
    
    
    % sumowanie obraz�w 1) i 2)
    if a>0
        P_OST=P_DO+P_ODS_2;
    else
        P_OST=P_DO;
    end
    
    if nnz(P_OST)>0
        R(eee,1).K1_OST=P_OST; %wynik pierwszej cz�ci skryptu
        R(eee,1).t=1;
    else
        R(eee,1).t=0;    
    end
    fprintf('Zdj�cie %s iteracja %d z 119 gotowa. %d \n', R(eee,1).nazwa, eee, R(eee,1).t)
    %figure(eee);imshow(P_OST);
    clearvars -except R eee % czyszczenie, bo nie jestem w stanie kontrolowa�, kiedy zmienna mo�e co� nabru�dzi� przechodz�c do nast�pnej p�tli
    
end
clearvars -except R
toc