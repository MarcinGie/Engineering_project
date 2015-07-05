% Access a Matrox(R) frame grabber attached to a Pulnix TMC-9700 camera, and
% acquire data using an NTSC format.
% vidobj = videoinput('matrox',1,'M_NTSC_RGB');

% Open a live preview window.  Point camera onto a piece of colorful fabric.
% preview(vidobj);

% Capture one frame of data.
% fabric = getsnapshot(vidobj);
% imwrite(fabric,'fabric.png','png');

% Delete and clear associated variables. delete(vidobj) clear vidobj;

%% 1 Aquire image

fabric = imread('121108_095633839_camera_2_w11p_1.jpg');
figure;
imshow(fabric);
title('fabric');

%% 2  Calculate Sample Colors in L*a*b* Color Space for Each Region
% 
% load regioncoordinates;
% 
% nColors = 6;
% sample_regions = false([size(fabric,1) size(fabric,2) nColors]);
% 
% for count = 1:nColors
%   sample_regions(:,:,count) = roipoly(fabric,region_coordinates(:,1,count),...
%                                       region_coordinates(:,2,count));
% end
% figure;
% subplot(2,3,1);
% imshow(sample_regions(:,:,2),[]),title('sample region for 1');

%RGB ->CIE L*a*b*
colorTransform = makecform('srgb2lab');
lab_fabric = applycform(fabric, colorTransform);

a = lab_fabric(:,:,2);
b = lab_fabric(:,:,3);
color_marker = [174.0,194.0];

% for count = 1:nColors
%   color_markers(count,1) = mean2(a(sample_regions(:,:,count)));
%   color_markers(count,2) = mean2(b(sample_regions(:,:,count)));
% end


fprintf('[%0.3f,%0.3f] \n',color_marker(1),color_marker(2));

%% 3  Calculate Sample Colors in L*a*b* Color Space for Each Region

color_labels = 0:1;

a = double(a);
b = double(b);
distance = zeros([size(a), 1]);

% for count = 1:nColors
  distance(:,:,1) = ( (a - color_marker(1)).^2 + ...
                      (b - color_marker(2)).^2 ).^0.5;
% end

[~, label] = min(distance,[],3);
label = color_labels(label);
clear distance;

%% 4

rgb_label = repmat(label,[1 1 3]);
segmented_images = zeros([size(fabric), 1],'uint8');

% for count = 1:nColors
  color = fabric;
  color(rgb_label ~= color_labels(2)) = 0;
  segmented_images(:,:,:,1) = color;
% end
figure;
subplot(1,2,1);
imshow(segmented_images(:,:,:,1)), title('orange objects');
% subplot(2,3,2);
% imshow(segmented_images(:,:,:,3)), title('green objects');
% subplot(2,3,3);
% imshow(segmented_images(:,:,:,4)), title('purple objects');
% subplot(2,3,4);
% imshow(segmented_images(:,:,:,5)), title('magenta objects');
% subplot(2,3,5);
% imshow(segmented_images(:,:,:,6)), title('yellow objects');

%% 5

purple = [119/255 73/255 152/255];
plot_labels = {'k', 'r', 'g', purple, 'm', 'y'};

subplot(1,2,2);
% for count = 1:nColors
  plot(a(label==0),b(label==0),'.','MarkerEdgeColor', ...
       plot_labels{1}, 'MarkerFaceColor', plot_labels{1});
  hold on;
% end

title('Scatterplot of the segmented pixels in a*-b* space');
xlabel('a* values');
ylabel('b* values');
axis equal
axis([-80 80 -80 80])