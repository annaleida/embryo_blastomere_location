function imageOut = ProcessHumTL_1(imageIn, plottingOn)
% DOUBLE THRESHOLD + CONV HULL + HOUGH
    % Process image and return processed logical bw image
    
    % Preprocess to extract ZP ROI
    zp_ = ProcessZP(imageIn, plottingOn,0.7);
    % zp_ = bwmorph(zp_,'remove');
    
    A = imageIn;
    ss = size(A);
    sizeX = ss(1); sizeY = ss(2);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(31), end;
    
    
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A_0 = A;
    A_1 = A;
    A_0(~zp_) = 0;
    A_1(~zp_) = max(max(A));
     
    A_low = zeros(size(A));
    A_low(find(A_1<0.3*max(max(A_1)))) = 1;
    
    A_high = zeros(size(A));
    A_high(find(A_0>0.8*max(max(A_0)))) = 1;
    
    A = A_low + A_high;
    
    A = imclose(A,se3);
    B = zeros(size(A));
    B(find(A>0.1*max(max(A)))) = 1;
    
    A = imclose(B,se3);
    A2 = bwareaopen(A,200);
    if (plottingOn), subplot(2,2,1), imshow(A2), title('a) Low+high'), end;
    
    
    % ''''''''''''''''
    A = imageIn;
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A = del2(double(A));
    A = imhmax(A,0.1*max(max(A)));
    
    A = imclose(A,se3);
    B = zeros(size(A));
    B(find(A>0.1*max(max(A)))) = 1;
    
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
    
    F = zeros(size(A));
    S = regionprops(A,'all');
    size(S.ConvexImage);
    x0 = floor(S.BoundingBox(1));
    x1 = floor(S.BoundingBox(3)+S.BoundingBox(1));
    y0 = floor(S.BoundingBox(2));
    y1 = floor(S.BoundingBox(4)+S.BoundingBox(2));
    F(y0:y1-1,x0:x1-1) = S.ConvexImage;
    if (plottingOn), subplot(2,2,2), imshow(F), title('a) C.hull'), end;
    % ''''''''''''''''''''''''''
    
    A2(~F) = 0;
    A2 = bwareaopen(A2,200);
    if (plottingOn), subplot(2,2,3), imshow(A2), title('a) masked w c.hull'), end;
    
    % '''''''''''''''''''
    
    body_radii_min =30;
    body_radii_max = 100;
    body_radii = body_radii_min:5:body_radii_max; %min radi:step size:max radi
    no_bodies = 60; %In this script - can only detect 1 body
    body_h = circle_hough(A2, body_radii, 'same', 'normalise');
    body_peaks1 = circle_houghpeaks(body_h, body_radii, 'nhoodxy', 15, 'nhoodr', 21, 'npeaks', no_bodies);
    idx = 1;
    if (plottingOn), subplot(2,2,4), imshow(imageIn), hold on, end;
    circles = [];
    outSideImageShift = 15;
    outSideHullShift = 15;
    for c=body_peaks1
        if ((c(1)-c(3) > -outSideImageShift) && (c(2)-c(3) > -outSideImageShift))
            if ((c(1)+c(3) < sizeX+outSideImageShift) && (c(2)+c(3) < sizeY+outSideImageShift))
                comp_cen_x = c(1);
                comp_cen_y = c(2);
                radius = c(3);
                [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
                center = [comp_cen_x comp_cen_y];
                [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
                emb_mask = (X.^2 + Y.^2)>radius^2;
                sum_mask = max(max(emb_mask));
                temp = (~emb_mask)-F; % compute if too far outside conv.hull
                temp(find(temp<0)) = 0;
                tempsum = sum(sum(temp));
                if (tempsum<outSideHullShift)
                   if (plottingOn), subplot(2,2,4), ...
                        contour(emb_mask,'Color', 'c', 'lineWidth', 1), hold on;
                    end;
                    circles(:,idx) = c;
                    idx = idx+1;
                end;
                
            end;
        end;
    end;

    if length(circles) > 1
        filteredCircles = filter_circles(circles);
    else
        filteredCircles = circles;
    end;

    if (plottingOn), subplot(2,2,4), imshow(imageIn), hold on, end;
    for c=filteredCircles
        comp_cen_x = c(1);
        comp_cen_y = c(2);
        radius = c(3);
        [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
        center = [comp_cen_x comp_cen_y];
        [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
        emb_mask = (X.^2 + Y.^2)>radius^2;
        if (plottingOn), subplot(2,2,4), ...
            contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
        end;
    end;
    
    imageOut = filteredCircles;
    