% Short script for testing any kind of thing
clear all; close all;

sizeX = 500;
sizeY = 500;
mask1 = ComputeMask([150, 150, 100 0.6 1 45] , sizeX, sizeY, 10);
figure(1), imshow(mask1), title('mask'), axis on;
mask = RotateMask(mask1, 45);
figure(3), imshow(mask), title('mask'), hold on, contour(mask1), axis on;
