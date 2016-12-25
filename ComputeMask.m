function mask = ComputeMask(circle, sizeX, sizeY, mask_width)
% Computes solid or ringshaped masks for circles and ellipses
% if mask_width = 0: compute and return solid mask
a = circle(3)*circle(4);
b = circle(3)*circle(5);
[X,Y] = ndgrid((1:sizeY) - circle(2),(1:sizeX) - circle(1) );
mask1 = ((X/(a-floor(mask_width/2))).^2 + (Y/(b-floor(mask_width/2))).^2)>1;

mask2 = ((X/(a+floor(mask_width/2))).^2 + (Y/(b+floor(mask_width/2))).^2)<1;
if mask_width ~= 0
mask = mask1.*mask2;
else
    mask = mask2;
end;