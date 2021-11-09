function  enable_gui(obj, state)
% enable or disable the gui (data picker and spectrum plotwindow) for
% lengthy operations. 

obj.datapicker.DataSelectionPanel.Enable = state; 
obj.datapicker.FitSettingsPanel.Enable = state; 
obj.datapicker.PlotSettingsPanel.Enable = state; 

end

