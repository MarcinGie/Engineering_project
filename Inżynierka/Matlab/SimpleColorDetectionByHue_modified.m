
% Requires the Image Processing Toolbox.

function SimpleColorDetectionByHue_modified()
clc;	% Clear command window.
clear;	% Delete all variables.
close all;	% Close all figure windows except those created by imtool.
imtool close all;	% Close all figure windows created by imtool.
workspace;	% Make sure the workspace panel is showing.

ver % Display user's toolboxes in their command window.

% Introduce the demo, and ask user if they want to continue or exit.
% message = sprintf('This demo will illustrate orange color detection\nin HSV color space.\nIt requires the Image Processing Toolbox.\nDo you wish to continue?');
% reply = questdlg(message, 'Run Demo?', 'OK','Cancel', 'OK');
% if strcmpi(reply, 'Cancel')
% 	% User canceled so exit.
% 	return;
% end

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
% 	figure;
% 	% Maximize the figure. 
% 	set(gcf, 'Position', get(0, 'ScreenSize')); 

	% Change the current folder to the folder of this m-file.
	% (The line of code below is from Brett Shoelson of The Mathworks.)
% 	if(~isdeployed)
% 		cd(fileparts(which(mfilename)));
% 	end

	% Open an images.
    % Change default directory to the one containing the standard demo images for the MATLAB Image Processing Toolbox. 
    sciezka_data = '..\W11p\obrazy-test2\';
    spis_tst = 'pliki.txt'; % spis plikow do testowania
    fil_tst = fopen([sciezka_data spis_tst]);
    
     
    
    selectedImage = 'My own image'; % Need for the if threshold selection statement later.

    for eee=1:119
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

%         Display the original image.
        subplot(2, 1, 1);
        imshow(rgbImage);
     	drawnow; % Make it display immediately. 
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

        % Display them.
%         subplot(4, 5, 2);
%         imshow(hImage);
%         title('Hue', 'FontSize', fontSize);
%         subplot(4, 5, 3);
%         imshow(sImage);
%         title('Saturation', 'FontSize', fontSize);
%         subplot(4, 5, 4);
%         imshow(vImage);
%         title('Value', 'FontSize', fontSize);
    % 	message = sprintf('These are the individual HSV color bands.\nNow we will compute the image histograms.');
    % 	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
    % 	if strcmpi(reply, 'Cancel')
    % 		% User canceled so exit.
    % 		return;
    % 	end

        % Compute and plot the histogram of the "hue" band.
%         hHuePlot = subplot(4, 5, 6); 
        [hueCounts, hueBinValues] = imhist(hImage); 
        maxHueBinValue = find(hueCounts > 0, 1, 'last'); 
        maxCountHue = max(hueCounts); 
        bar(hueBinValues, hueCounts, 'r'); 
%         grid on; 
%         xlabel('Hue'); 
%         ylabel('Pixel Count'); 
%         title('Histogram of Hue', 'FontSize', fontSize);

        % Compute and plot the histogram of the "saturation" band.
%         hSaturationPlot = subplot(4, 5, 7); 
        [saturationCounts, saturationBinValues] = imhist(sImage); 
        maxSaturationBinValue = find(saturationCounts > 0, 1, 'last'); 
        maxCountSaturation = max(saturationCounts); 
        bar(saturationBinValues, saturationCounts, 'g', 'BarWidth', 0.95); 
%         grid on; 
%         xlabel('Saturation'); 
%         ylabel('Pixel Count'); 
%         title('Histogram of Saturation', 'FontSize', fontSize);

        % Compute and plot the histogram of the "value" band.
%         hValuePlot = subplot(4, 5, 8); 
        [valueCounts, valueBinValues] = imhist(vImage); 
        maxValueBinValue = find(valueCounts > 0, 1, 'last'); 
        maxCountValue = max(valueCounts); 
        bar(valueBinValues, valueCounts, 'b'); 
%         grid on; 
%         xlabel('Value'); 
%         ylabel('Pixel Count'); 
%         title('Histogram of Value', 'FontSize', fontSize);

        % Set all axes to be the same width and height.
        % This makes it easier to compare them.
        maxCount = max([maxCountHue,  maxCountSaturation, maxCountValue]); 
%         axis([hHuePlot hSaturationPlot hValuePlot], [0 1 0 maxCount]); 

        % Plot all 3 histograms in one plot.
%         subplot(4, 5, 5); 
%         plot(hueBinValues, hueCounts, 'r', 'LineWidth', 2); 
%         grid on; 
%         xlabel('Values'); 
%         ylabel('Pixel Count'); 
%         hold on; 
%         plot(saturationBinValues, saturationCounts, 'g', 'LineWidth', 2); 
%         plot(valueBinValues, valueCounts, 'b', 'LineWidth', 2); 
%         title('Histogram of All Bands', 'FontSize', fontSize); 
        maxGrayLevel = max([maxHueBinValue, maxSaturationBinValue, maxValueBinValue]); 
        % Make x-axis to just the max gray level on the bright end. 
%         xlim([0 1]); 

    % 	% Now select thresholds for the 3 color bands.
    % 	message = sprintf('Now we will select some color threshold ranges\nand display them over the histograms.');
    % 	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
    % 	if strcmpi(reply, 'Cancel')
    % 		% User canceled so exit.
    % 		return;
    % 	end

        % Assign the low and high thresholds for each color band.
        % Take a guess at the values that might work for the user's image.
        hueThresholdLow = double(5/255);
        hueThresholdHigh = double(15/255);
        saturationThresholdLow = double(50/255);
        saturationThresholdHigh = 1.0;
        valueThresholdLow = double(50/255);
        valueThresholdHigh = 1.0;

        % Show the thresholds as vertical red bars on the histograms.
%         PlaceThresholdBars(6, hueThresholdLow, hueThresholdHigh);
%         PlaceThresholdBars(7, saturationThresholdLow, saturationThresholdHigh);
%         PlaceThresholdBars(8, valueThresholdLow, valueThresholdHigh);

    % 	message = sprintf('Next we will apply each color band threshold range to its respective color band.');
    % 	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
    % 	if strcmpi(reply, 'Cancel')
    % 		% User canceled so exit.
    % 		return;
    % 	end

        % Now apply each color band's particular thresholds to the color band
        hueMask = (hImage >= hueThresholdLow) & (hImage <= hueThresholdHigh);
        saturationMask = (sImage >= saturationThresholdLow) & (sImage <= saturationThresholdHigh);
        valueMask = (vImage >= valueThresholdLow) & (vImage <= valueThresholdHigh);

        % Display the thresholded binary images.
%         fontSize = 16;
%         subplot(4, 5, 10);
%         imshow(hueMask, []);
%         title('= Hue Mask', 'FontSize', fontSize);
%         subplot(4, 5, 11);
%         imshow(saturationMask, []);
%         title('& Saturation Mask', 'FontSize', fontSize);
%         subplot(4, 5, 12);
%         imshow(valueMask, []);
%         title('&   Value Mask', 'FontSize', fontSize);
        % Combine the masks to find where all 3 are "true."
        % Then we will have the mask of only the red parts of the image.
        yellowObjectsMask = uint8(hueMask & saturationMask & valueMask);
%         subplot(4, 5, 9);
%         imshow(yellowObjectsMask, []);
%         caption = sprintf('Mask of Only\nThe Orange Objects');
%         title(caption, 'FontSize', fontSize);

        % Tell user that we're going to filter out small objects.
        smallestAcceptableArea = 200; % Keep areas only if they're bigger than this.
    % 	message = sprintf('Note the small regions in the image in the lower left.\nNext we will eliminate regions smaller than %d pixels.', smallestAcceptableArea);
    % 	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
    % 	if strcmpi(reply, 'Cancel')
    % 		% User canceled so exit.
    % 		return;
    % 	end

        % Open up a new figure, since the existing one is full.
%         figure;  
        % Maximize the figure. 
%         set(gcf, 'Position', get(0, 'ScreenSize'));

        % Get rid of small objects.  Note: bwareaopen returns a logical.
        yellowObjectsMask = uint8(bwareaopen(yellowObjectsMask, smallestAcceptableArea));
        % Dilate to connect objects
        yellowObjectsMask = imdilate(yellowObjectsMask,strel('disk',6));
%         subplot(4, 5, 13);
%         imshow(yellowObjectsMask, []);
%         fontSize = 13;
%         caption = sprintf('bwareaopen() removed objects\nsmaller than %d pixels', smallestAcceptableArea);
%         title(caption, 'FontSize', fontSize);

        % Smooth the border using a morphological closing operation, imclose().
        structuringElement = strel('disk', 4);
        yellowObjectsMask = imclose(yellowObjectsMask, structuringElement);
%         subplot(4, 5, 14);
%         imshow(yellowObjectsMask, []);
%         fontSize = 16;
%         title('Border smoothed with imclose()', 'FontSize', fontSize);

        % Fill in any holes in the regions, since they are most likely red also.
        yellowObjectsMask = uint8(imfill(yellowObjectsMask, 'holes'));
%         subplot(4, 5, 15);
%         imshow(yellowObjectsMask, []);
%         title('Regions Filled', 'FontSize', fontSize);

    % 	message = sprintf('This is the filled, size-filtered mask.\nNext we will apply this mask to the original RGB image.');
    % 	reply = questdlg(message, 'Continue with Demo?', 'OK','Cancel', 'OK');
    % 	if strcmpi(reply, 'Cancel')
    % 		% User canceled so exit.
    % 		return;
    % 	end

        % You can only multiply integers if they are of the same type.
        % (yellowObjectsMask is a logical array.)
        % We need to convert the type of yellowObjectsMask to the same data type as hImage.
        yellowObjectsMask = cast(yellowObjectsMask, class(rgbImage)); 

        % Use the yellow object mask to mask out the yellow-only portions of the rgb image.
        maskedImageR = yellowObjectsMask .* rgbImage(:,:,1);
        maskedImageG = yellowObjectsMask .* rgbImage(:,:,2);
        maskedImageB = yellowObjectsMask .* rgbImage(:,:,3);
        % Show the masked off red image.
%         subplot(4, 5, 16);
%         imshow(maskedImageR);
%         title('Masked Red Image', 'FontSize', fontSize);
%         % Show the masked off saturation image.
%         subplot(4, 5, 17);
%         imshow(maskedImageG);
%         title('Masked Green Image', 'FontSize', fontSize);
%         % Show the masked off value image.
%         subplot(4, 5, 18);
%         imshow(maskedImageB);
%         title('Masked Blue Image', 'FontSize', fontSize);
%         % Concatenate the masked color bands to form the rgb image.
        maskedRGBImage = cat(3, maskedImageR, maskedImageG, maskedImageB);
%         % Show the masked off, original image.
        subplot(2, 1, 2);
        imshow(maskedRGBImage);
        fontSize = 13;
        caption = sprintf('Masked Original Image\nShowing Only the Orange Objects');
        title(caption, 'FontSize', fontSize);
        % Show the original image next to it.
%         subplot(3, 3, 7);
%         imshow(rgbImage);
%         title('The Original Image (Again)', 'FontSize', fontSize);

        % Measure the mean HSV and area of all the detected blobs.
        [meanHSV, areas, numberOfBlobs] = MeasureBlobs(yellowObjectsMask, hImage, sImage, vImage);
        if numberOfBlobs > 0
            fprintf(1, '\n %s\n', nazwa_tst);
            fprintf(1, '\n----------------------------------------------\n');
            fprintf(1, 'Blob #%d, Area in Pixels, Mean H, Mean S, Mean V\n',eee);
            fprintf(1, '----------------------------------------------\n');
            for blobNumber = 1 : numberOfBlobs
                fprintf(1, '#%5d, %14d, %6.2f, %6.2f, %6.2f\n', blobNumber, areas(blobNumber), ...
                    meanHSV(blobNumber, 1), meanHSV(blobNumber, 2), meanHSV(blobNumber, 3));
            end
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
		% Didn't detect any yellow blobs in this image.
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
% Function to show the low and high threshold bars on the histogram plots.
function PlaceThresholdBars(plotNumber, lowThresh, highThresh)
	% Show the thresholds as vertical red bars on the histograms.
	%subplot(3, 4, plotNumber); 
	hold on;
	maxYValue = ylim;
	maxXValue = xlim;
	hStemLines = stem([lowThresh highThresh], [maxYValue(2) maxYValue(2)], 'r');
	children = get(hStemLines, 'children');
	set(children(2),'visible', 'off');
	% Place a text label on the bar chart showing the threshold.
	fontSizeThresh = 14;
	annotationTextL = sprintf('%d', lowThresh);
	annotationTextH = sprintf('%d', highThresh);
	% For text(), the x and y need to be of the data class "double" so let's cast both to double.
	text(double(lowThresh + 5), double(0.85 * maxYValue(2)), annotationTextL, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	text(double(highThresh + 5), double(0.85 * maxYValue(2)), annotationTextH, 'FontSize', fontSizeThresh, 'Color', [0 .5 0], 'FontWeight', 'Bold');
	
	% Show the range as arrows.
	% Can't get it to work, with either gca or gcf.
% 	annotation(gca, 'arrow', [lowThresh/maxXValue(2) highThresh/maxXValue(2)],[0.7 0.7]);

	return; % from PlaceThresholdBars()