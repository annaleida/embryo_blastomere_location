function imageOut = ProcessHumTL_2(imageIn, plottingOn)
% LAPLACIAN + DISTANCE FUNCTION
    % Process image and return processed logical bw image
    A = imageIn;
    ss = size(A);
    sizeX = ss(1); sizeY = ss(2);
    se3 = strel('disk',3);
    se5=strel('disk',5);
    se7=strel('disk',7);
    se11=strel('disk',29);
    se61 = strel('disk',61);
    if (plottingOn), figure(32), end;
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
    if (plottingOn), subplot(2,2,1), imshow(A), title('a) Laplace etc'), end;
    end;
    
    D = bwdist(~A);
    % Erode
    D0 = imerode(D,se5);
    % Threshold
    D1 = zeros(size(D));
    D1(find(D>0.8*max(max(D)))) = 1;
    % Hmaxima
    D2 = imhmax(D,0.3*max(max(D)));
    D2(find(D2>0.8*max(max(D2)))) = 1;
    if (plottingOn), subplot(2,2,2), imshow(D2,[]), title('a) Distance'), end;
    B = bwlabel(D2,4);
    S = regionprops(B,'all');
    Area = zeros(size(S));
    if (plottingOn), subplot(2,2,3), imshow(imageIn), title('a) Peaks'), hold on, end;
    circles = [];
    idx = 1;
    for i = 1:length(S)
        if (S(i).Area > 1000) %remove very small regions
        S(i).Area;
        x = round(S(i).Centroid(1));
        y = round(S(i).Centroid(2));
        max_ = D0(y,x);
        if (plottingOn), subplot(2,2,3), plot(x,y,'rx'), hold on, end;
        circles(:,idx) = [x,y,max_];
        idx = idx+1;
        end;
    end;
    C = zeros(size(imageIn));
    
    imageOut = circles;
    