function [x, idx, y, idy] = get_cursor_position(obj, cursor_info, index)
    % find the index and values of the x and y position value from 
    % clicking with the cursor. cursorinfo is a cursorinfo struct. 
    x = cursor_info(index).Position(1); 
    y = cursor_info(index).Position(2);   
    x_all = unique(obj.plotdata.xy_coordinates(:,:,1)); 
    y_all = unique(obj.plotdata.xy_coordinates(:,:,2)); 
    % flipping of the y data is necessary because of how the pcolor
    % function processes position data. 
    y_all = flip(y_all);
    idx = find(x_all == x);
    idy = find(y_all == y);
end
