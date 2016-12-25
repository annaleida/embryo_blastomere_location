function maskOut = RotateMask(maskIn, angle)
ss = size(maskIn);
sizeX = ss(1); sizeY = ss(2);
propsIn = regionprops(maskIn, 'Centroid','BoundingBox');
c1 = propsIn.Centroid;
b1 = propsIn.BoundingBox;
mask = imrotate(maskIn, angle);
props = regionprops(mask, 'Centroid','BoundingBox');
c2 = props.Centroid;
b2 = floor(props.BoundingBox);
delta = c1-c2;
maskOut = zeros(size(maskIn));
% try
b3 = floor([max(b2(1)+delta(1),1) max(b2(2)+delta(2),1) min(b2(3),sizeX) min(b2(4),sizeY)]);
% mask2 = mask(floor(b2(2)):floor(b2(2)+b2(4)),floor(b2(1)):floor(b2(1)+b2(3)));
maskOut(b3(2):b3(2)+b3(4),b3(1):b3(1)+b3(3)) = mask(b2(2):b2(2)+b2(4),b2(1):b2(1)+b2(3));
maskOut = maskOut(1:sizeX,1:sizeY);
% catch
%     disp 'test'
% end;
% figure(2), imshow(mask), title('mask'), axis on;
% figure(4), imshow(mask2), title('mask'), axis on;