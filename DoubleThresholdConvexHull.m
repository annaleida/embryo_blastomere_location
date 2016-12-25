function imageOut = DoubleThresholdConvexHull(imageIn, plottingOn)
% DOUBLE THRESHOLD + CONV HULL
    % Process image and return processed logical bw image
    
    % Preprocess to extract ZP ROI
    zp_ = ProcessZP(imageIn, plottingOn,1.2);
    % zp_ = bwmorph(zp_,'remove');
    
    A = imageIn;
    ss = size(A);
    sizeX = ss(1); sizeY = ss(2);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(36), end;
    
    
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A_0 = A;
    A_1 = A;
    A_0(~zp_) = 0;
    A_1(~zp_) = max(max(A));
     
    level = graythresh(A_0);
    m = mean(mean(A_0));
    
    tmp = reshape(A_0,sizeX*sizeY,1);
    tmp = sort(tmp);
    tmp = tmp(find(tmp>=1):length(tmp));
    med1 = median(tmp);
    tmp = reshape(A_1,sizeX*sizeY,1);
    tmp = sort(tmp);
    tmp = tmp(1:find(tmp>=max(max(A_1))-1));
    med2 = median(tmp);
    med = median(median(A_0));
    
    
    A_low = zeros(size(A));
%     A_low(find(A_1<20*level/m*max(max(A)))) = 1;
A_low(find(A_1<0.55*med2)) = 1;
sum(sum(A_low));
    if (plottingOn), subplot(2,2,1), imshow(A_low), title('a) low'), end;
    
    A_high = zeros(size(A));
%     A_high(find(A_0>100*level/m*max(max(A)))) = 1;
A_high(find(A_0>1.22*med2)) = 1;
sum(sum(A_high));
    if (plottingOn), subplot(2,2,2), imshow(A_high), title('a) high'), end;
    
    
    A = A_low + A_high;
    if (plottingOn), subplot(2,2,1), imshow(A), title('a) Low+high'), end;
    
    A = imclose(A,se3);
    B = zeros(size(A));
    B(find(A>0.1*max(max(A)))) = 1;
    
    A = imclose(B,se3);
    A2 = bwareaopen(A,200);
   
    
    
    % ''''''''''''''''
    A = imageIn;
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A = del2(double(A));
    if (plottingOn), subplot(2,2,2), imshow(A), title('a) Laplace'), end;
    A = imhmax(A,0.1*max(max(A)));
     if (plottingOn), subplot(2,2,3), imshow(A), title('a) H maxima 1'), end;
    A = imclose(A,se3);
    B = zeros(size(A));
    B(find(A>0.1*max(max(A)))) = 1;
     if (plottingOn), subplot(2,2,4), imshow(B), title('a) H maxima'), end;
     
    A = imclose(B,se3);
    B = bwlabel(A,4);
    S = regionprops(B,'Area');
    Area = zeros(size(S));
    for i = 1:length(S)
    Area(i) = S(i).Area;
    end;
    label = argmax(Area);
    A = zeros(size(imageIn));
    if (Area(label) > 1000)
    A(B==label) = 1;
    A = imfill(A,'holes');
    end;
    
    %Filter out anything outside convex hull
    F = zeros(size(A));
    S = regionprops(A,'all');
%    size(S.ConvexImage);
    x0 = ceil(S.BoundingBox(1));
    x1 = floor(S.BoundingBox(3)+S.BoundingBox(1));
    y0 = ceil(S.BoundingBox(2));
    y1 = floor(S.BoundingBox(4)+S.BoundingBox(2));
    F(y0:y1,x0:x1) = S.ConvexImage;
    if (plottingOn), subplot(2,2,4), imshow(F), title('a) C.hull'), end;
    % ''''''''''''''''''''''''''
    
    A2(~F) = 0;
    A2 = bwareaopen(A2,200); %Remove small objects
    
    % ''''''''''''''''''ии
    %Take away small objects
    B = bwlabel(A2,4);
    S = regionprops(B,'all');
    A = zeros(size(imageIn));
    for i = 1:length(S)
        if (S(i).Area > 100)
            A(B==i) = 1;
        end;
    end;    
%     A = imfill(A,'holes');
%     if (plottingOn), subplot(2,2,4), imshow(A), title('a) masked w c.hull'), end;
    
    imageOut = A;
    