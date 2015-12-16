
% Requires the Image Processing Toolbox.

function SimpleColorDetectionByHue_modified3()
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
imtool close all;	% Close all figure windows created by imtool.
workspace;	% Make sure the workspace panel is showing.

ver % Display user's toolboxes in their command window.

try
	% Check that user has the Image Processing Toolbox installed.
	versionInfo = ver; % Capture their toolboxes in the variable.
	hasIPT = false;
	for k = 1:length(versionInfo)
		if strcmpi(versionInfo(k).Name, 'Image Processing Toolbox') > 0
			hasIPT = true;
		end
	end
	if ~hasIPT
		% User does not have the toolbox installed.
		message = sprintf('Sorry, but you do not seem to have the Image Processing Toolbox.\nDo you want to try to continue anyway?');
		reply = questdlg(message, 'Toolbox missing', 'Yes', 'No', 'Yes');
		if strcmpi(reply, 'No')
			% User said No, so exit.
			return;
		end
	end

	% Continue.  Do some initialization stuff.
	close all;
	fontSize = 16;
    

	% Open an images.
    % Change default directory to the one containing the standard demo images for the MATLAB Image Processing Toolbox. 
    sciezka_data = '..\W11p\obrazy-uczenie\';
    spis_tst = 'pliki.txt'; % spis plikow do testowania
    fil_tst = fopen([sciezka_data spis_tst]);
    
     
    
    selectedImage = 'My own image'; % Need for the if threshold selection statement later.

    for eee=1:13
        figure;
        % Read in image into an array.
        nazwa_tst =fgetl(fil_tst);
        [rgbImage, storedColorMap] = imread([sciezka_data nazwa_tst]); 
        [~, ~, numberOfColorBands] = size(rgbImage); 
        % If it's monochrome (indexed), convert it to color. 
        % Check to see if it's an 8-bit image needed later for scaling).
        if strcmpi(class(rgbImage), 'uint8')
            % Flag for 256 gray levels.
            eightBit = true;
        else
            eightBit = false;
        end
        if numberOfColorBands == 1
            if isempty(storedColorMap)
                % Just a simple gray level image, not indexed with a stored color map.
                % Create a 3D true color image where we copy the monochrome image into all 3 (R, G, & B) color planes.
                rgbImage = cat(3, rgbImage, rgbImage, rgbImage);
            else
                % It's an indexed image.
                rgbImage = ind2rgb(rgbImage, storedColorMap);
                % ind2rgb() will convert it to double and normalize it to the range 0-1.
                % Convert back to uint8 in the range 0-255, if needed.
                if eightBit
                    rgbImage = uint8(255 * rgbImage);
                end
            end
        end 

%       Display the original image.
        subplot(1, 3, 1);
        imshow(rgbImage); 
        if numberOfColorBands > 1 
            title('Original', 'FontSize', fontSize); 
        else 
            caption = sprintf('Original Indexed Image\n(converted to true color with its stored colormap)');
            title(caption, 'FontSize', fontSize);
        end

        % Convert RGB image to HSV
        hsvImage = rgb2hsv(rgbImage);
        % Extract out the H, S, and V images individually
        hImage = hsvImage(:,:,1);
        sImage = hsvImage(:,:,2);
        vImage = hsvImage(:,:,3);

        % Assign the low and high thresholds for each color band.
        % Take a guess at the values that might work for the user's image.
        hueThresholdLow = double(5/255);
        hueThresholdHigh = double(15/255);
        saturationThresholdLow = double(50/255);
        saturationThresholdHigh = 1.0;
        valueThresholdLow = double(50/255);
        valueThresholdHigh = 1.0;

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
        saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
        valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

        % Combine the masks to find where all 3 are "true."
        orangeObjectsMask = uint8(hueMask & saturationMask & valueMask);


        smallestAcceptableArea = 200; % Keep areas only if they're bigger than this.

        % Open up a new figure, since the existing one is full.
%         figure;  
        % Maximize the figure. 
        %set(gcf, 'Position', get(0, 'ScreenSize'));

        % Get rid of small objects.  Note: bwareaopen returns a logical.
        orangeObjectsMask = uint8(bwareaopen(orangeObjectsMask, smallestAcceptableArea));
        % Dilate to connect objects
        orangeObjectsMask = imdilate(orangeObjectsMask,strel('disk',6));
        subplot(1, 3, 2);
        imshow(orangeObjectsMask, []);
        fontSize = 13;
        caption = sprintf('bwareaopen() removed objects\nsmaller than %d pixels', smallestAcceptableArea);
        title(caption, 'FontSize', fontSize);

        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        orangeObjectsMask = imclose(orangeObjectsMask, structuringElement);

        % Fill in any holes in the regions, since they are most likely red also.
        orangeObjectsMask = uint8(imfill(orangeObjectsMask, 'holes'));

        % You can only multiply integers if they are of the same type.
        % (orangeObjectsMask is a logical array.)
        % We need to convert the type of orangeObjectsMask to the same data type as hImage.
        orangeObjectsMask = cast(orangeObjectsMask, class(rgbImage)); 
        DecideIfItsASign(orangeObjectsMask);

        % Use the orange object mask to mask out the orange-only portions of the rgb image.
        maskedImageR = orangeObjectsMask .* rgbImage(:,:,1);
        maskedImageG = orangeObjectsMask .* rgbImage(:,:,2);
        maskedImageB = orangeObjectsMask .* rgbImage(:,:,3);

        % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);

        % Measure the mean HSV and area of all the detected blobs.
        [meanHSV, areas, numberOfBlobs] = MeasureBlobs(orangeObjectsMask, hImage, sImage, vImage);
        if numberOfBlobs > 0
%             fprintf(1, '\n %s\n', nazwa_tst);
%             fprintf(1, '\n----------------------------------------------\n');
%             fprintf(1, 'Blob #%d, Area in Pixels, Mean H, Mean S, Mean V\n',eee);
%             fprintf(1, '----------------------------------------------\n');
%             for blobNumber = 1 : numberOfBlobs
%                 fprintf(1, '#%5d, %14d, %6.2f, %6.2f, %6.2f\n', blobNumber, areas(blobNumber), ...
%                     meanHSV(blobNumber, 1), meanHSV(blobNumber, 2), meanHSV(blobNumber, 3));
%             end
        else
            % Alert user that no orange blobs were found.
            fprintf(1,'No orange blobs were found in the image:\n%s', nazwa_tst);
%             fprintf(1, '\n%s\n', message);
        end
    end

catch ME
    errorMessage = sprintf('Error running this m-file:\n%s\n\nThe error message is:\n%s', ...
        mfilename('fullpath'), ME.message);
    errordlg(errorMessage);
end

return; % from SimpleColorDetection()
% ---------- End of main function ---------------------------------


%----------------------------------------------------------------------------
function [meanHSV, areas, numberOfBlobs] = MeasureBlobs(maskImage, hImage, sImage, vImage)
	[labeledImage, numberOfBlobs] = bwlabel(maskImage, 8);     % Label each blob so we can make measurements of it
	if numberOfBlobs == 0
		% Didn't detect any orange blobs in this image.
		meanHSV = [0 0 0];
		areas = 0;
		return;
	end
	% Get all the blob properties.  Can only pass in originalImage in version R2008a and later.
	blobMeasurementsHue = regionprops(labeledImage, hImage, 'area', 'MeanIntensity');   
	blobMeasurementsSat = regionprops(labeledImage, sImage, 'area', 'MeanIntensity');   
	blobMeasurementsValue = regionprops(labeledImage, vImage, 'area', 'MeanIntensity');   
	
	meanHSV = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	meanHSV(:,1) = [blobMeasurementsHue.MeanIntensity]';
	meanHSV(:,2) = [blobMeasurementsSat.MeanIntensity]';
	meanHSV(:,3) = [blobMeasurementsValue.MeanIntensity]';
	
	% Now assign the areas.
	areas = zeros(numberOfBlobs, 3);  % One row for each blob.  One column for each color.
	areas(:,1) = [blobMeasurementsHue.Area]';
	areas(:,2) = [blobMeasurementsSat.Area]';
	areas(:,3) = [blobMeasurementsValue.Area]';

	return; % from MeasureBlobs()
	
%----------------------------------------------------------------------------
function DecideIfItsASign(mask)
    mask = bwareaopen(mask,100);
    lab = bwlabel(mask);
    stats = regionprops(lab, 'BoundingBox');
    [a,b]=size(stats);
    subplot(1, 3, 3);
    imshow(mask,[]);
    fprintf('\nNumber of regions: %d',a);
    
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
            fprintf('\n   succeeded for object %d',j);
            mimj_ideal=0.25;
            fa_ideal=0.85;
            figure;
            subplot(1,1,1);
            imshow(wycinek,[]);
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