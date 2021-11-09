close all 


% create data 
data = 1:100; 
data = reshape(data, [10,10]); 
data = data.^1.3; 


% create regular figure and axis 
fig_normal = figure;
axes_normal = axes(fig_normal); 
s_normal = pcolor(axes_normal, data);  
s_normal.FaceColor = 'interp'; 

% create uifigure and axis 
fig_ui = uifigure; 
axes_ui = uiaxes(fig_ui); 
s_ui = pcolor(axes_ui, data);
s_ui.FaceColor = 'interp'; 

% create app instance and plot same there 
fig_app = testapp_pcolor; 
s_app = pcolor(fig_app.UIAxes, data); 
s_app.FaceColor = 'interp' 



