function fig = simpleApp
% this is a test where I make a simple app that has some buttons for user
% interaction. It will serve as the basis for the datapicker window later.
% 

fig = uifigure;
fig.Name = 'test application'; 

grid = uigridlayout(fig, [3 3]);
grid.RowHeight = {'1x',30,30}; 
grid.ColumnWidth = {'1x','1x','1x'}; 

ax = uiaxes(grid); 

dd_experiment = uidropdown(grid); 
dd_emission = uidropdown(grid);
ef_excitation_min = uieditfield(grid, 'numeric'); 
ef_excitation_max = uieditfield(grid, 'numeric'); 

% set row and column positions for buttons 
ax.Layout.Row = 1; 
ax.Layout.Column = [1 3]; 


dd_experiment.Layout.Row = [2 3];
dd_experiment.Layout.Column = 1; 
dd_emission.Layout.Column = [2 3]; 
dd_emission.Layout.Row = 3;
ef_excitation_min.Layout.Row = 2;
ef_excitation_min.Layout.Column = 2; 
ef_excitation_max.Layout.Row = 2; 
ef_excitation_max.Layout.Column = 3; 

dd_experiment.Items = {'excitation', 'emission'};  
dd_experiment.Value = 'excitation' ;

dd_emission.Items = {'surf', 'mesh', 'waterfall'}; 
dd_emission.Value = 'surf'; 

dd_emission.ValueChangedFcn = {@changePlotType,ax}; 

end

function changePlotType(src,event,ax)
type = event.Value;
switch type
    case 'surf'
        surf(ax,peaks);
    case 'mesh'
        mesh(ax,peaks);
    case 'waterfall'
        waterfall(ax,peaks);
end
end



