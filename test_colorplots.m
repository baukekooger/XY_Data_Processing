close all

data = 1:12;
data = data.^2;
data = reshape(data, [4 3])'; 

x = 10:10:40;
y = 20:10:40;

figure
imagesc(x, y, flipud(data)); 
set(gca, 'YDir', 'normal')

figure
x = repmat(x, [3,1]); 
y = repmat(y, [4,1])';
hold on
rectangle('Position', [0 0 51 51], FaceColor=[0.8431, 0.9451, 0.9804])
S = pcolor(x,y,flipud(data));
S.FaceColor = 'interp';
plot(x,y, 'o', 'MarkerFaceColor', 'w', 'MarkerEdgeColor','k')
set(gca, 'XTick', [0; unique(x); 51])
set(gca, 'YTick', [0; unique(y); 51])
set(gca, 'XLim', [0 10])
set(gca, 'YLim', [0 4])
axis image
