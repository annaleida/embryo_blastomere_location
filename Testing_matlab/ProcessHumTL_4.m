function imageOut = ProcessHumTL_4(imageIn, plottingOn)
% CANNY + HOUGH
    % Process image and return processed logical bw image
    A = imageIn;
    ss = size(A);
    sizeX = ss(1); sizeY = ss(2);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(34), end;
    filter = fspecial('gaussian', 5, 0.5); 
    A = imfilter(A, filter,'replicate');
    %A = A + imtophat(A, se3); - imbothat(A, se3);
    
    A = edge(A, 'canny'); % log?
    
    if (plottingOn), subplot(2,2,1), imshow(A), title('a) Canny'), end;
    max_centroid_radius = 1; %What is the min distance for several structures to count as the same?
    body_radii_min =70;
    body_radii_max = 90;
    body_radii = body_radii_min:2:body_radii_max; %min radi:step size:max radi
    no_bodies = 10; %In this script - can only detect 1 body
    body_h = circle_hough(A, body_radii, 'same', 'normalise');
    body_peaks1 = circle_houghpeaks(body_h, body_radii, 'nhoodxy', 15, 'nhoodr', 21, 'npeaks', no_bodies);
    idx = 1;
    if (plottingOn), subplot(2,2,2), imshow(imageIn), hold on, end;
    circles = [];
    outSideImageShift = 15;
    for c=body_peaks1
        if ((c(1)-c(3) > -outSideImageShift) && (c(2)-c(3) > -outSideImageShift))
            if ((c(1)+c(3) < sizeX+outSideImageShift) && (c(2)+c(3) < sizeY+outSideImageShift))
                circles(:,idx) = c;
                idx = idx+1;
                comp_cen_x = c(1);
                comp_cen_y = c(2);
                radius = c(3);
                [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
                center = [comp_cen_x comp_cen_y];
                [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
                emb_mask = (X.^2 + Y.^2)>radius^2;
                if (plottingOn), subplot(2,2,2), ...
                        contour(emb_mask,'Color', 'c', 'lineWidth', 1), hold on;
                end;
            end;
        end;
    end;

    if length(circles) > 1
        filteredCircles = filter_circles(circles);
    else
        filteredCircles = circles;
    end;

    if (plottingOn), subplot(2,2,3), imshow(imageIn), hold on, end;
    for c=filteredCircles
        comp_cen_x = c(1);
        comp_cen_y = c(2);
        radius = c(3);
        [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
        center = [comp_cen_x comp_cen_y];
        [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
        emb_mask = (X.^2 + Y.^2)>radius^2;
        if (plottingOn), subplot(2,2,3), ...
            contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
        end;
    end;

    % Make sure we only return 1.
%     if (length(filteredCircles) > 3)
%         filteredCircles = filteredCircles(:,1);
%     end;

%     mask = zeros(size(A));
%     if (length(filteredCircles) > 0)
%         [X,Y] = ndgrid((1:sizeY) - filteredCircles(2),(1:sizeX) - filteredCircles(1) );
%         emb_mask = (X.^2 + Y.^2)>(filteredCircles(3)*0.7)^2;
%         mask(~emb_mask) = 1;
%     end;
%     if (plottingOn), subplot(2,2,4), imshow(mask), hold on, end;
%     A = im2bw(mask,0.5);
    imageOut = filteredCircles;
    