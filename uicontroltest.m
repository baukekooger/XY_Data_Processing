function uicontroltest
close all
a = linspace(0, 2*pi, 100); 
b = transpose(linspace(1,10,10)); 

data = b*sin(a); 

index = 1; 

fig = figure;
ax = axes(fig);
ax.Position = [0 0.2 1 0.8]; 
plot(data(index,:)); 

bg = uibuttongroup(fig, 'Visible','off',...
                  'Position',[0 0 1 0.2],...
                  'SelectionChangedFcn',@bselection);
              
btn = uicontrol(fig,'Style','pushbutton');
btn.String = 'next line in matrix'; 
btn.Callback = @increaseIndexPlot;
btn.Units = 'pixels'
btn.Position = [0 0 100 75];               
              
% Create three radio buttons in the button group.
r1 = uicontrol(bg,'Style',...
                  'radiobutton',...
                  'String','Option 1',...
                  'Position',[0 40 100 20],...
                  'HandleVisibility','off');
              
r2 = uicontrol(bg,'Style','radiobutton',...
                  'String','Option 2',...
                  'Position',[0 20 100 20],...
                  'HandleVisibility','off');

r3 = uicontrol(bg,'Style','radiobutton',...
                  'String','Option 3',...
                  'Position',[0 0 100 20],...
                  'HandleVisibility','off');
              
       
              
% Make the uibuttongroup visible after creating child objects. 
bg.Visible = 'on';



    function bselection(source,event)
       disp(['Previous: ' event.OldValue.String]);
       disp(['Current: ' event.NewValue.String]);
       disp('------------------');
    end

    function increaseIndexPlot(src, event)
        if index < length(b)
            index = index + 1;
            plot(ax, data(index,:))
        else
            index = 1;
            plot(ax, data(index,:))
        end
    end

end