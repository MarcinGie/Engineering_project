% klasyfikacja wykrytych znaków
tic
close all;
sciezka_wzorce= 'C:\Users\Marcin\Desktop\Engineering_project\Inzynierka\W11p\wzorce\';

w1='W11_p_1_';
w2='W11_p_2_';
koncowka='.tif';
wynik=fopen('WYNIK.txt','w');

for eee=1:14
    
    if R(eee,1).t==1
        [a,b]=size(R(eee,1).TZ);
        f=1;
        x=0;
        fprintf('\nzdjecie %d il kand %d',eee,a);
        for i=1:a
            if R(eee,1).TZ(i,1).bz==0
                ZNAK=R(eee,1).TZ(i,1).KandydatZnak;
                [c,d]=size(ZNAK);
                k=1;
                for j=30:-3:-30
                    n=num2str(j);
                    nazwa1=strcat(w1,n,koncowka);
                    nazwa2=strcat(w2,n,koncowka);
                    W1=imread([sciezka_wzorce nazwa1]);
                    W2=imread([sciezka_wzorce nazwa2]);
                    w_p1=imresize(W1,[c d]);
                    w_p2=imresize(W2,[c d]);
                    O_p1=ZNAK-w_p1;
                    O_p2=ZNAK-w_p2;
                    P_1(k,1)=j;
                    P_1(k,2)=length(find(O_p1>0));
                    P_1(k,3)=length(find(O_p1<0));
                    P_1(k,4)=sqrt(((P_1(k,2))^2)+((P_1(k,3))^2));
                    P_2(k,1)=j;
                    P_2(k,2)=length(find(O_p2>0));
                    P_2(k,3)=length(find(O_p2<0));
                    P_2(k,4)=sqrt(((P_2(k,2))^2)+((P_2(k,3))^2));
                    k=k+1;
                end
                min_p1=min(P_1(:,4));
                min_p2=min(P_2(:,4));
                p1=find([P_1(:,4)]==min_p1);
                p2=find([P_2(:,4)]==min_p2);

                if min_p1<min_p2
                    R(eee,1).TZ(i,1).kat=P_1(p1,1);
                    R(eee,1).TZ(i,1).n=w1;
                    fprintf('Iteracja %d zdjecie %s znaleziono znak P1\n', eee, R(eee,1).nazwa)
                    fprintf(wynik,'Zdjecie %s znaleziono wskaznik W11 p1\n',R(eee,1).nazwa);
                    %fprintf(wynik,'Po?o?enie na obrazie: lewy górny naro?nik(%d,%d),szeroko?? %d, wysoko?? %d\n',Z(eee,1).Z(i,1).bb(1,1),Z(eee,1).Z(i,1).bb(1,2),Z(eee,1).Z(i,1).bb(1,3),Z(eee,1).Z(i,1).bb(1,4));
                    fprintf(wynik,'\n');
                else
                    R(eee,1).TZ(i,1).kat=P_2(p2,1);
                    R(eee,1).TZ(i,1).n=w2;
                    fprintf('Iteracja %d zdj?cie %s znaleziono znak P2\n', eee, R(eee,1).nazwa)
                    fprintf(wynik,'\nZdjêcie %s znaleziono wska?nik W11 p2\n',R(eee,1).nazwa);
                    %fprintf(wynik,'Po?o?enie na obrazie: lewy górny naro?nik(%d,%d),szeroko?? %d, wysoko?? %d\n',Z(eee,1).Z(i,1).bb(1,1),Z(eee,1).Z(i,1).bb(1,2),Z(eee,1).Z(i,1).bb(1,3),Z(eee,1).Z(i,1).bb(1,4));
                    fprintf(wynik,'\n');
                end
                
                ORYG=R(eee,1).O;
                figure(eee);subplot(a,4,1+x);imshow(ORYG);
                title('fragment obrazu oryginalnego');
%                 K1=imcrop(R(eee,1).K1, R(eee,1).TZ(i,1).bb);
%                 figure(eee);subplot(a,4,2+x);imshow(K1);
%                 title('fragment progowania pocz?tkowego');
                figure(eee);subplot(a,4,3+x);imshow(ZNAK);
                title('ostateczny obraz progowania po prostowaniu');
                n=num2str(R(eee,1).TZ(i,1).kat);
                nazwa=strcat(R(eee,1).TZ(i,1).n,n,koncowka);
                S=imread([sciezka_wzorce nazwa]);
                figure(eee);subplot(a,4,4+x);imshow(S);
                title('najlepszy odpowiadajacy wzorzec');
                x=x+4;
                %}
            end
        end
        
    end
     
end
clearvars -except R
toc  