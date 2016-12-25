clear all; close all;   
% For tesing
tic
%     path = 'C:\\Temp\\Testimages\\4 cell_18\\';
    path = 'C:\\Temp\\Focal scan testimages\\';
    N=4; 
    Nres = 4;
    nbrIm = 1;
    result_ = zeros(nbrIm,8);
    for i = 6:6
        i
    file_test = strcat(strcat(path,num2str(i)),'.jpg');
    I_tl = imread(file_test);
    I_tl_result = zeros(500,500,N);
    for n = 1:1
     file_test_res = strcat(strcat(strcat(path,num2str(i)),strcat('_r',num2str(n))),'.bmp');
     im_res = imread(file_test_res);
     end;
    I = I_tl(:,:,1);

    [gx gy] = gradient(double(I));
    [gxx gxy] = gradient(gx);
    [gyx gyy] = gradient(gy);
    
    E1 = zeros(size(I));
     E2 = zeros(size(I));
     D = zeros(size(I));
     DiffE = zeros(size(I));
    for i = 1:500
        for j = 1:500
            M = [gxx(i,j) gxy(i,j); gyx(i,j) gyy(i,j)];
            E = eig(M);
            E1(i,j) = E(1);
            E2(i,j) = E(2);
            D(i,j) = det(M);
            if ((E2(i,j) ~= 0))
                DiffE(i,j) = abs(E1(i,j))./abs(E2(i,j));
            end;
        end;
    end;
    
    figure(1)
    imshow(E1);
    figure(2)
    imshow(E2);
    figure(3)
    imshow(D);
    figure(4)
    imshow(DiffE);
    
    C = edge(DiffE, 'canny');
    figure(5)
    imshow(C)
    
    Del = del2(DiffE);
figure(6)
imshow(Del);
%     
%     sizeX = 500;
%     sizeY = 500;
%     body_radii_min =60;
%     body_radii_max = 100;
%     
%     body_radii = body_radii_min:5:body_radii_max; %min radi:step size:max radi
%     no_bodies = 10; %In this script - can only detect 1 body
%     body_h = circle_hough(DiffE, body_radii, 'same', 'normalise');
%     body_peaks1 = circle_houghpeaks(body_h, body_radii, 'nhoodxy', 15, 'nhoodr', 21, 'npeaks', no_bodies);
%     idx = 1;
%     figure(4), imshow(DiffE), hold on;
%     circles = [];
%     outSideImageShift = 15;
%     for c=body_peaks1
%         if ((c(1)-c(3) > -outSideImageShift) && (c(2)-c(3) > -outSideImageShift))
%             if ((c(1)+c(3) < sizeX+outSideImageShift) && (c(2)+c(3) < sizeY+outSideImageShift))
%                 circles(:,idx) = c;
%                 idx = idx+1;
%                 comp_cen_x = c(1);
%                 comp_cen_y = c(2);
%                 radius = c(3);
%                 [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
%                 center = [comp_cen_x comp_cen_y];
%                 [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
%                 emb_mask = (X.^2 + Y.^2)>radius^2;
%                 figure(4), ...
%                         contour(emb_mask,'Color', 'c', 'lineWidth', 1), hold on;
%             end;
%         end;
%     end;
% 
%     if length(circles) > 1
%         filteredCircles = filter_circles(circles);
%     else
%         filteredCircles = circles;
%     end;
% 
%     for c=filteredCircles
%         comp_cen_x = c(1);
%         comp_cen_y = c(2);
%         radius = c(3);
%         [x, y] = circlepoints(c(3)); %Compute vector of points with radius peak(3)
%         center = [comp_cen_x comp_cen_y];
%         [X,Y] = ndgrid((1:sizeY) - center(2),(1:sizeX) - center(1) );
%         emb_mask = (X.^2 + Y.^2)>radius^2;
%         figure(4), ...
%             contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
%         
%     end;
    
    
    end;
    toc
    result_