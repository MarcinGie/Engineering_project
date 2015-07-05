% autor El¿bieta Pastucha
% skrypt analizuj¹cy wykryte znaki po wzglêdem przynale¿noœci do kategorii
% p1 lub p2
clear

tic
sciezka_data = 'obr/';
sciezka_wzorce= 'wzorce/';
spis_tst = 'pliki.txt'; % spis plikow do testowania
fil_tst = fopen([sciezka_data spis_tst]); 
wzorzec_p1_nazwa='W11p_1_b.tif';
wzorzec_p2_nazwa='W11P_2_b.tif';
prz1=imread([sciezka_wzorce wzorzec_p1_nazwa]);
prz2=imread([sciezka_wzorce wzorzec_p2_nazwa]);
WZRp1=im2bw(prz1(:,:,1),0.5);
WZRp2=im2bw(prz2(:,:,1),0.5);
w1='W11_p_1_';
w2='W11_p_2_';
koncowka='.tif';
 
figure(1); subplot(1,2,1);imshow(WZRp1);
figure(1); subplot(1,2,2);imshow(WZRp2);

w=1;
for i=30:-3:-30
    kats = i;   % stopni
    kat = kats*pi/180;  % radiany
    rozmiar = size(WZRp1);  % y x
    dy = floor((rozmiar(2)-1)*sin(kat));
    dx = floor((rozmiar(2)-1)*(1-cos(kat)));
    u =[1 1; 1 rozmiar(1); rozmiar(2) 1; rozmiar(2) rozmiar(1)];
    x = [1+dx 1-dy; 1+dx rozmiar(1)-dy; rozmiar(2) 1; rozmiar(2) rozmiar(1)];
    T = maketform('projective',u,x);
    b = imtransform(WZRp1, T);
    c = imtransform(WZRp2, T);
    B((w),1).O=b;
    C((w),1).O=c;
    n=num2str(i);
    nazwaB=strcat(w1,n,koncowka);
    nazwaC=strcat(w2,n,koncowka);
    imwrite(B(w,1).O,nazwaB,'tif');
    imwrite(C(w,1).O,nazwaC,'tif');
    w=w+1;
    
end

toc   