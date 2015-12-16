function K_means_modified_2()
    %-----------------------------------------------------------------------------------%
    close all
    clear variables
    clc
    %-----------------------------------------------------------------------------------%
    %% 1 Read image

    sciezka_data ='..\W11p\obrazy-uczenie\';
    spis_tst = 'pliki.txt'; % spis plikow do testowania
    fil_tst = fopen([sciezka_data spis_tst]);

    for eee=1:1
        fprintf('Image %d started\n',eee);
        nazwa_tst =fgetl(fil_tst);
        he = imread([sciezka_data nazwa_tst]);
        figure;
        subplot(4,3,1);
        imshow(he), title(nazwa_tst);
        %% 2 Convert image from RGB to L*a*b space

        cform = makecform('srgb2lab');
        lab_he = applycform(he,cform);

        %% 3 Classify the colors in *a*b space using k-means clustering

        ab = double(lab_he(:,:,2:3));
        nrows = size(ab,1);
        ncols = size(ab,2);
        ab = reshape(ab,nrows*ncols,2);

        nColors = 10;
        % repeat the clustering 3 times to avoid local minima
        [cluster_idx, cluster_center] = kmeans(ab,nColors,'start','uniform','emptyaction','singleton','Replicates',3,'distance','sqEuclidean');

        %% 4 Label every pixel in the Image using the results from k-means

        pixel_labels = reshape(cluster_idx,nrows,ncols);
        subplot(4,3,2);
        imshow(pixel_labels,[]), title('image labeled by cluster index');

        %% 5 Create images that segment source image by color

        segmented_images = cell(1,3);
        rgb_label = repmat(pixel_labels,[1 1 3]);

        for k = 1:nColors
            color = he;
            color(rgb_label ~= k) = 0;
            segmented_images{k} = color;

            subplot(4,3,k+2);
            t = sprintf('objects in cluster %d',k);
            imshow(segmented_images{k}), title(t);
            DecideIfItsASign(im2bw(segmented_images{k},0.01),k);
        end


        %% 6 (optional) segment selected image containing clusters

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
return;

function DecideIfItsASign(mask,n)
	mask = imdilate(mask,strel('disk',6));
    mask = bwareaopen(mask,100);
    lab = bwlabel(mask);
    stats = regionprops(lab, 'BoundingBox');
    [a,b]=size(stats);
    fprintf('Number of regions: %d',a);
    
    for j=1:a %dla kazdego obiektu
        boundingbox = stats(j,1).BoundingBox;
        wycinek = imcrop(mask,boundingbox);
        stat_at=regionprops(wycinek,'Area','BoundingBox','MajorAxisLength','MinorAxisLength','Orientation','FilledImage');
        poloz_at=find([stat_at.Area] == max([stat_at.Area]));
        [fa1_at,fa2_at]=size(stat_at(poloz_at,1).FilledImage);
        FA_at=stat_at(poloz_at,1).Area/(fa1_at*fa2_at);
        mimj_at=stat_at(poloz_at,1).MinorAxisLength/stat_at(poloz_at,1).MajorAxisLength;
        if stat_at(poloz_at,1).Orientation<-85 || stat_at(poloz_at,1).Orientation>85
            pr_fa_at=0.50;
        else
            pr_fa_at=0.30;
        end
        
        if mimj_at<0.35 && mimj_at>0.1 && (stat_at(poloz_at,1).Orientation<-60 || stat_at(poloz_at,1).Orientation>60) && FA_at>pr_fa_at
            fprintf('\nsucceeded for object %d in cluster %d',j);
            mimj_ideal=0.25;
            fa_ideal=0.85;
            spt=regionprops(wycinek,'Area','Orientation','BoundingBox');
            sppol=find([spt.Area] == max([spt.Area]));
            if spt(sppol,1).Orientation<0 %wyznaczenie kata dla imrotate
                kat=-90-spt(sppol,1).Orientation;
            else
                kat=90-spt(sppol,1).Orientation;
            end
            SPR_0 = imrotate(wycinek,kat);
            SPR = bwareaopen(SPR_0, 50);
            sprt=regionprops(SPR,'Area','MajorAxisLength','MinorAxisLength','FilledImage','BoundingBox');
            sprpol=find([sprt.Area] == max([sprt.Area])); % najwiekszy obiekt
            sp_mimj=sprt(sprpol,1).MinorAxisLength/sprt(sprpol,1).MajorAxisLength; % stosunek bokow
            [spa,spb]=size(sprt(sprpol,1).FilledImage);
            sp_fa=sprt(sprpol,1).Area/(spa*spb); %czesc obszaru zajeta przez znak
            ode_sp=sqrt(((sp_mimj-mimj_ideal)^2)+((sp_fa-fa_ideal)^2));
        end
    end
    
    return;