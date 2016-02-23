function iou = calculate_iou(first, second)
    xx1 = max(first(1), second(1));
    yy1 = max(first(2), second(2));
    xx2 = min(first(3), second(3));
    yy2 = min(first(4), second(4));
    if(xx1 > xx2 || yy1 > yy2)
        iou = 0;
        return;
    end
    w = xx2-xx1+1;
    h = yy2-yy1+1;
    i = w*h;
    
    u = (first(3)-first(1))*(first(4)-first(2)) + ...
        (second(3)-second(1))*(second(4)-second(2)) - i;
    
    iou = i/u;
end