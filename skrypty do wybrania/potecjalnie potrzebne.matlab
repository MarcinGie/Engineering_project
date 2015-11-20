%% R1

przyciecie=[0,a/3,b,(a/3)*2]; %% zmiana przyciêcia obrazu!!!!!
O_3=imcrop(O,przyciecie);
Or=imresize(O_3,0.25); %% zmiana rozdzielczoœci przetwarzania
Or_hsv=rgb2hsv(Or);


P_300 = bwareaopen(R(eee,1).K1pr_auto, 50); %usuniêcie obiektów o mniejszej iloœci pikseli ni¿ 50
P_WDZ = imfill(P_300, 'holes'); %wype³nienie dziur

STATS = regionprops(P_WDZ, 'Orientation'); %obliczenie orientacji wszystkich pojedynczych obiektów
IL=bwlabel(P_WDZ); %zlabelowanie wszystkich obiektów
ind = find([STATS.Orientation] >= 45 | [STATS.Orientation] <= -45); %wybór obiektów o odpowiednim nachyleniu
P_ODS = ismember(IL,ind); %odsiew
STATS = regionprops(P_ODS, 'MajorAxisLength','MinorAxisLength'); %obliczenie przekątnych obiektów
[a b]=size(STATS);
if a>0
        for i=1:a %dodanie informacji o stosunku boków
            STATS(i,1).mimj=STATS(i,1).MinorAxisLength/STATS(i,1).MajorAxisLength; 
        end
        ind2 = find([STATS.mimj] > 0.05);
        ILL=bwlabel(P_ODS);
        P_ODS_2 = ismember(ILL,ind2); %odsiew chudzielców
end

 % sumowanie obrazów 1) i 2)
if a>0
    P_OST=P_DO+P_ODS_2;
else
    P_OST=P_DO;
end

%% R2

dysk_2=strel('disk',6);
DYL = imdilate(R(eee,1).K1_OST,dysk_2); %dylatacja tylko po to, żeby połączyć obszary leżące blisko w jeden


IL=bwlabel(DYL); - Label connected components
STATS = regionprops(IL, 'BoundingBox'); - Returns the smallest rectangle containing the region

B1 = bwareaopen(B, 10); % usuniêcie ma³ych obiektówv