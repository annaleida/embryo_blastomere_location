function [selectedCircles, selectedCirclesScore] = EvalMatchLowHigh(map_, circles, nbrCells, plottingOn, ellipses)
%Score according to matching low/high

mask_width = 10;
ss = size(map_);
sizeX = ss(1); sizeY = ss(2);
sss = size(circles);
rangeA = linspace(0.8,1.2,5);
rangeB = linspace(0.8,1.2,5);
rangeRot = linspace(0,90,5);
sizePred = sss(2)*length(rangeA)*length(rangeB);
if (plottingOn), figure(41), end;
if (plottingOn), subplot(2,2,1), imshow(map_), title('a) low + high'), end;
selectedCircles = zeros(6,nbrCells);
selectedCirclesScore = zeros(1,nbrCells);
circles_new = zeros(6,sizePred);
nbrCellsRemain = nbrCells;
counter = 2;
map__ = map_;
if (plottingOn), subplot(2,2,4), imshow(map__), title('all'), hold on, end;
while nbrCellsRemain > 0
    
    mask = zeros(size(map__));
ii = 2;
int_ = zeros(sizePred,2);
iou = zeros(sizePred,2);

    for c=circles
        
        c_new = ones(6,1);
        c_new(1:3) = c;
        c_new(6) = 0;
        % For ellipses
        if ellipses == 1
        for a=rangeA
            for b=rangeB
%                 for r=rangeRot
                c_new(4) = a;
                c_new(5) = b;
%                 c_new(6) = r;
                mask = ComputeMask(c_new, sizeX, sizeY, mask_width);
%                 mask = RotateMask(mask,r);
                int_(ii-1,2) = sum(sum(mask.*map__));
                int_(ii-1,1) = ii-1;
                iou(ii-1,2) = int_(ii-1,2)/(sum(sum(mask))+sum(sum(map__))-int_(ii-1,2));
                iou(ii-1,1) =ii-1;
                circles_new(1:6,ii-1) = c_new(:)';
                ii = ii + 1;
                if (plottingOn), subplot(2,2,2), imshow(mask), title('mask'), hold on, contour(mask), hold off, end;
%                 if (plottingOn), subplot(2,2,2), contour(mask,'Color', 'b', 'lineWidth', 1), hold on, end;
                end;
%             end;
        end;
        else
            % For circles
        mask = ComputeMask(c_new, sizeX, sizeY, mask_width);
        int_(ii-1,2) = sum(sum(mask.*map__));
                int_(ii-1,1) = ii-1;
                iou(ii-1,2) = int_(ii-1,2)/(sum(sum(mask))+sum(sum(map__))-int_(ii-1,2));
                iou(ii-1,1) =ii-1;
                circles_new(1:5,ii-1) = c_new(:)';
                ii = ii + 1;
%                 if (plottingOn), subplot(2,2,2), imshow(mask), title('mask'), hold on, end;
%                 if (plottingOn), subplot(2,2,2), contour(mask,'Color', 'b', 'lineWidth', 1), hold on, end;
        end;
        
    end;
    
iou = sortrows(iou,2);
int_ = sortrows(int_,2);
std_2 = mean(iou,1)-std(iou,1);

 
for i = sizePred:-1:sizePred
    if (iou(i,2)>std_2(2))
        ind = iou(i,1);
        c = circles_new(:,ind);
        selectedCircles(:,counter-1) = c;
        selectedCirclesScore(1,counter-1) = iou(i,2);
        [X,Y] = ndgrid((1:sizeY) - c(2),(1:sizeX) - c(1) );
%         emb_mask = ((X/(c(3)*c(4))).^2 + (Y/(c(3)*c(5))).^2)>1;
        emb_mask = ComputeMask(c, sizeX, sizeY, 0);
%         emb_mask1 = (((X/((c(3)*c(4))-mask_width))).^2 + ((Y/((c(3)*c(5))-mask_width))).^2)>1;
%         emb_mask2 = (((X/((c(3)*c(4))+mask_width))).^2 + ((Y/((c(3)*c(5))+mask_width))).^2)<1;
%         mask = emb_mask1.*emb_mask2;
        mask = ComputeMask(c, sizeX, sizeY, mask_width*2);
        map__ = map__.*(~mask);
        if (plottingOn), 
             subplot(2,2,min(counter,3)), imshow(mask), hold on, contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
            subplot(2,2,4), contour(emb_mask,'Color', 'b', 'lineWidth', 1), hold on;
        end;
    else
        break;
    end;
end;
    counter = counter +1;
    nbrCellsRemain = nbrCellsRemain -1;
end; %while
