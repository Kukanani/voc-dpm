% Adam Allevato
% CS 381V Experiment
% Spring 2016
% UT Austin

% Show the overlap scores for the set of bounding boxes passed in.

function shownmsconfusion(boxes)

boxes = flipud(sortrows(boxes, 5));
x1 = boxes(:,1);
y1 = boxes(:,2);
x2 = boxes(:,3);
y2 = boxes(:,4);
num_boxes = size(boxes,1);
score = zeros(num_boxes);
for i=1:num_boxes
    for j=1:num_boxes
        % taken from nms()
        
        % calculate the the union
        xx1 = max(x1(i), x1(j));
        yy1 = max(y1(i), y1(j));
        xx2 = min(x2(i), x2(j));
        yy2 = min(y2(i), y2(j));
        w = xx2-xx1+1;
        h = yy2-yy1+1;
        % w*h = |Bi \cap Bj|
        
        if w > 0 && h > 0
            % compute overlap
            a = (x2(j)-x1(j))*(y2(j)-y1(j)); % |Bj|
            score(i,j) = w * h / a;
        end
    end
end
% assignin('base','score',score);
figure;
colormap(gray)
pcolor(score);
colorbar;

end