function expr_partial(compile, model)

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

num_to_kill = 7;
iou = zeros(num_to_kill+1,1);

load('VOC2007/bicycle_final');
model.vis = @() visualizemodel(model, ...
                  1:2:length(model.rules{model.start}));
im = imread('cyclist_pedestrian.jpg');
figure;
image(im);
first_click = ginput(1);
second_click = ginput(1);
ground_truth = [first_click second_click];
boxes = round(test(im, model, 1, ground_truth));
iou(1) = calculate_iou(boxes(1:4), ground_truth);

for i=1:num_to_kill
    im(boxes(2+i*4):boxes(4+i*4), boxes(1+i*4):boxes(3+i*4), :) = 0;
    try 
        this_box = test(im, model, 1, ground_truth);
        iou(i+1) = calculate_iou(this_box(1:4), ground_truth);
    catch e
        getReport(e)
    end
end
plot(iou)
title('IoU as filters are blocked')
xlabel('Number of blacked-out filters')
ylabel('IoU')

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
%disp('press any key to continue'); pause;
disp('continuing...');

% load and display model
model.vis();
disp([cls ' model visualization']);
%disp('press any key to continue'); pause;
disp('continuing...');

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
  %title('bounding box overlap score');
  %pause;
  clf;
  showboxes(im, [[ground_truth 1]; bbox(top,:)]);
  title('predicted bounding boxes');
  disp('bounding boxes');
  %disp('press any key to continue'); pause;
end

fprintf('\n');