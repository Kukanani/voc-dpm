function expr_average_swap(compile, model)

% AUTORIGHTS
% -------------------------------------------------------
% Copyright (C) 2011-2012 Ross Girshick
% Copyright (C) 2008, 2009, 2010 Pedro Felzenszwalb, Ross Girshick
% 
% This file is part of the voc-releaseX code
% (http://people.cs.uchicago.edu/~rbg/latent/)
% and is available under the terms of an MIT-like license
% provided in COPYING. Please retain this notice and
% COPYING if you use this file (or a portion of it) in
% your project.
% -------------------------------------------------------

startup;
close all;

if exist('compile', 'var')
  fprintf('compiling the code...');
  compile;
  fprintf('done.\n\n');
end

load('VOC2010/bicycle_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
im = imread('cyclist_pedestrian.jpg');

% get ground truth
figure;
image(im);
first_click = ginput(1);
second_click = ginput(1);
ground_truth = [first_click second_click];
boxes = round(test(im, model, 1, ground_truth));

numSwaps = 30;
maxShift = 10;
iou = zeros(maxShift/5,2);

%for j=1:maxShift
%    shift = j*5;
shift = 50;
    iou_for_this_shift = zeros(numSwaps,1);
    % do a swap
    for i=1:numSwaps
        this_im = im;
        box_x_size = round((boxes(3)-boxes(1))*0.44);
        box_y_size = round((boxes(4)-boxes(2))*0.44);
        box_x_pos = randi([boxes(1) boxes(3)-box_x_size]);
        box_y_pos = randi([boxes(2) boxes(4)-box_y_size]);

        new_box_x_pos = randi([box_x_pos-shift box_x_pos+shift]);
        new_box_y_pos = randi([box_y_pos-shift box_y_pos+shift]);
    %     new_box_x_pos = randi([boxes(1) boxes(3)-box_x_size]);
    %     new_box_y_pos = randi([boxes(2) boxes(4)-box_y_size]);
        swapfrom = this_im(box_y_pos:box_y_pos+box_y_size, box_x_pos:box_x_pos+box_x_size, :);
        swapto = this_im(new_box_y_pos:new_box_y_pos+box_y_size, new_box_x_pos:new_box_x_pos+box_x_size, :);
        this_im(box_y_pos:box_y_pos+box_y_size, box_x_pos:box_x_pos+box_x_size, :) = flipud(fliplr(swapto));
        this_im(new_box_y_pos:new_box_y_pos+box_y_size, new_box_x_pos:new_box_x_pos+box_x_size, :) = swapfrom;
        this_box = test(this_im, model, 1, ground_truth);
        iou_for_this_shift(i) = calculate_iou(this_box(1:4), ground_truth);
    end
%    iou(j, :) = [shift, mean(iou_for_this_shift)]
%end
% plot IoU
%figure;
%plot(iou);
%title('IoU vs. # of image swaps');
%assignin('base',['iou_' int2str(shift)],iou);

function box = test(im, model, num_dets, ground_truth)
cls = model.class;
fprintf('///// Running demo for %s /////\n\n', cls);

% load and display image
clf;
image(im);
axis equal; 
axis on;
title('input image');
disp('input image');
disp('press any key to continue'); pause;
disp('continuing...');

% load and display model
% model.vis();
% disp([cls ' model visualization']);
% disp('press any key to continue'); pause;
% disp('continuing...');

% detect objects
tic;
[ds, bs] = imgdetect(im, model, -1);
toc;
top = nms(ds, 0.5);
top = top(1:min(length(top), num_dets));
ds = ds(top, :);
bs = bs(top, :);
clf;
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
showboxes(im, reduceboxes(model, bs));
%reduceboxes(model, bs)
box = reduceboxes(model, bs);
title('detections');
disp('detections');
disp('press any key to continue'); pause;
disp('continuing...');

if model.type == model_types.MixStar
  % get bounding boxes
  bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
  bbox = clipboxes(im, bbox);
  top = nms(bbox, 0.5);
  
  %shownmsconfusion(bbox(top,:));
%   title('bounding box overlap score');
%   pause;
  
  clf;
  showboxes(im, [[ground_truth 1]; bbox(top,:)]);
  title('predicted bounding boxes');
  disp('bounding boxes');
  %disp('press any key to continue'); pause;
end

fprintf('\n');