function selectedCircles = EvalTouchCH(map_, circles, nbrCells, plottingOn)

ss = size(map_);
sizeX = ss(1); sizeY = ss(2);
sss = size(circles);
sizePred = sss(2);
if (plottingOn), figure(42), end;
if (plottingOn), subplot(2,2,1), imshow(map_), title('a) low + high'), end;
selectedCircles = zeros(3,nbrCells);
%Score according to touching conv hull 
F = zeros(size(map_));
S = regionprops(map_,'all');
    size(S.ConvexImage);
    x0 = ceil(S.BoundingBox(1));
    x1 = floor(S.BoundingBox(3)+S.BoundingBox(1));
    y0 = ceil(S.BoundingBox(2));
    y1 = floor(S.BoundingBox(4)+S.BoundingBox(2));
    F(y0:y1,x0:x1) = S.ConvexImage;
    kh = floor(S.ConvexHull);
    

    C = zeros(size(map_));
    for i = 1:length(kh)
        C(kh(i,2),kh(i,1)) = 1;
    end;

    contribution = zeros(sizePred,2);
     n = 1;
    if (plottingOn), subplot(2,2,3), imshow(F), title('a) touching c.hull'), hold on, end;
     for c=circles
[X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
        emb_mask0 = (X.^2 + Y.^2)>(c(3))^2;
        emb_mask1 = (X.^2 + Y.^2)>(c(3)+10)^2;
        emb_mask2 = (X.^2 + Y.^2)<(c(3)-10)^2;
        emb_mask = im2bw(emb_mask1 + emb_mask2);
        % Decomment this to show support bodies
%         figure()
%         imshow(~emb_mask1); hold on;
%         plot(kh(:,1),kh(:,2),'rx'); hold on;
        if (plottingOn), subplot(2,2,3), contour(~emb_mask0,'Color', 'c', 'lineWidth',1), hold on, end;
        test = sum(sum(~emb_mask.*C));
        contribution(n,2) = test;
        contribution(n,1) = n;
        if test > 0
            if (plottingOn), subplot(2,2,3), contour(~emb_mask0,'Color', 'b', 'lineWidth', 1), hold on, end;
%                 title('support');
        end;
        n = n+1;
    end;
    
    % return score for nbrCells (best candidates)
    contribution = sortrows(contribution,2)
    
    counter = 1;
    if (plottingOn), subplot(2,2,4), imshow(F), title('a) touching c.hull'), hold on, end;
    for i = sizePred:-1:sizePred-nbrCells+1
       if (contribution(i,2)>0)
            ind = contribution(i,1);
            c = circles(:,ind);
            selectedCircles(:,counter) = c
            counter = counter + 1;
            [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
            emb_mask = (X.^2 + Y.^2)>c(3)^2;
        if (plottingOn), subplot(2,2,4), ...
            contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
        end;
    else
        break;
    end;
    end;
