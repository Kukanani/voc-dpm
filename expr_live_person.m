function expr(no_compile, model)

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
close;
clear all;

while(1)
    cam = webcam(2)
    fig = figure;
    preview(cam);
    
    x = input('i = INRIA person, p = VOC2010 person, g = VOC2010 person, c = VOC2010 chair: ', 's');
    if(x == 'i')
        load('INRIA/inriaperson_final');
        fprintf('loaded INRIA person');
    elseif(x == 'p')
        load('VOC2010/person_final');
        fprintf('loaded VOC2010 person');
    elseif(x == 'g')
        load('VOC2010/person_grammar_final');
        fprintf('loaded VOC2010 grammar person');
    elseif(x == 'c')
        load('VOC2010/chair_final');
        fprintf('loaded VOC2010 chair');
    end
    image = snapshot(cam);
    closePreview(cam);
    clear cam;
    
    model.vis = @() visualizemodel(model, ...
                      1:2:length(model.rules{model.start}));
    test(image, model, 1);
    
end

function test(im, model, num_dets)
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
model.vis();
disp([cls ' model visualization']);
disp('press any key to continue'); pause;
disp('continuing...');

% detect objects
tic;
[ds, bs] = imgdetect(im, model, -1);
toc;
top = nms(ds, 0.1);
top = top(1:min(length(top), num_dets));
ds = ds(top, :);
bs = bs(top, :);
clf;
if model.type == model_types.Grammar
  bs = [ds(:,1:4) bs];
end
showboxes(im, reduceboxes(model, bs));
title('detections');
disp('detections');
disp('press any key to continue'); pause;
disp('continuing...');

if model.type == model_types.MixStar
  % get bounding boxes
  bbox = bboxpred_get(model.bboxpred, ds, reduceboxes(model, bs));
  bbox = clipboxes(im, bbox);
  top = nms(bbox, 0.5);
  clf;
  showboxes(im, bbox(top,:));
  title('predicted bounding boxes');
  disp('bounding boxes');
  disp('press any key to continue'); pause;
end

fprintf('\n');
