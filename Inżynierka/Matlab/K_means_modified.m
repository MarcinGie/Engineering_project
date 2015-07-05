
clc;
clear all;

%% 1

sciezka_data = 'C:\Users\Marcin\Desktop\W11p\obrazy-uczenie\';
spis_tst = 'pliki.txt'; % spis plikow do testowania
fil_tst = fopen([sciezka_data spis_tst]);



 

for eee=1:13
    fprintf('Image %d started\n',eee);
    nazwa_tst =fgetl(fil_tst);
    he = imread([sciezka_data nazwa_tst]);
    figure;
    subplot(4,3,1);
    imshow(he), title(nazwa_tst);

    %% 2 RGB -> L*a*b*

    cform = makecform('srgb2lab');
    lab_he = applycform(he,cform);

    %% 3 

    ab = double(lab_he(:,:,2:3));
    nrows = size(ab,1);
    ncols = size(ab,2);
    ab = reshape(ab,nrows*ncols,2);

    nColors = 3;
    % repeat the clustering 3 times to avoid local minima
    [cluster_idx, cluster_center] = kmeans(ab,nColors,'start','uniform','emptyaction','singleton','Replicates',3,'distance','sqEuclidean');

    %% 4

    pixel_labels = reshape(cluster_idx,nrows,ncols);
    subplot(4,3,2);
    imshow(pixel_labels,[]), title('image labeled by cluster index');

    %% 5

    segmented_images = cell(1,3);
    rgb_label = repmat(pixel_labels,[1 1 3]);

    for k = 1:nColors
        color = he;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;

        subplot(4,3,k+2);
        t = sprintf('objects in cluster %d',k);
        imshow(segmented_images{k}), title(t);
    end


    %% 6

    mean_cluster_value = mean(cluster_center,2);
    [tmp, idx] = sort(mean_cluster_value);
    blue_cluster_num = idx(1);

    L = lab_he(:,:,1);
    blue_idx = find(pixel_labels == blue_cluster_num);
    L_blue = L(blue_idx);
    is_light_blue = im2bw(L_blue,graythresh(L_blue));

    nuclei_labels = repmat(uint8(0),[nrows ncols]);
    nuclei_labels(blue_idx(is_light_blue==false)) = 1;
    nuclei_labels = repmat(nuclei_labels,[1 1 3]);
    blue_nuclei = he;
    blue_nuclei(nuclei_labels ~= 1) = 0;

%     subplot(4,2,8);
%     imshow(blue_nuclei), title('blue nuclei');
%     fprintf('Image %d done\n',eee);
end