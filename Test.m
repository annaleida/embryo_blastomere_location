clear all; close all;   
% For tesing
tic
    path = 'C:\\Temp\\Testimages\\6 cell_10\\';
%     path = 'C:\\Temp\\Focal scan testimages\\';
    N=6; 
    Nres = 6;
    nbrIm = 1;
    result_ = zeros(nbrIm,8);
    for i = 1:10
        i
    file_test = strcat(strcat(path,num2str(i)),'.jpg');
    I_tl = imread(file_test);
    I_tl_result = zeros(500,500,N);
    for n = 1:Nres
     file_test_res = strcat(strcat(strcat(path,num2str(i)),strcat('_r',num2str(n))),'.bmp');
     im_res = imread(file_test_res);
    I_tl_result(:,:,n) = ExtractOutline(im_res,1);
    end;
    I_tl_ = I_tl(:,:,1);
    %I_tl_ = double(I_tl_); %For processing
    
    % Morphological processing
%     I_tl_bw1 = ProcessHumTL_1(I_tl_,1)
%     I_tl_bw2 = ProcessHumTL_2(I_tl_,1)
%     I_tl_bw3 = ProcessHumTL_3(I_tl_,1)
%     I_tl_bw4 = ProcessHumTL_4(I_tl_,1);
%     I_tl_bw5 = ProcessHumTL_5(I_tl_,1);
%     I_tl_bw6 = ProcessHumTL_6(I_tl_,1);
% edgeMap = DoubleThresholdConvexHull(I_tl_,1);
     result_(i,1) = i;
     result_(i,2:8) = ProcessHumTL_46(I_tl_,I_tl_result,N, Nres, 1, 1);
% I_tl_bw41 = ProcessHumTL_41(I_tl_,1);

    end;
    toc
    result_