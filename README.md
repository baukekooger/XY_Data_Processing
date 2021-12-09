# XY_Data_Processing
# Requirements: Matlab Version 2021a or newer. 
# - Curve fitting toolbox
# - Symbolic math toolbox 

Matlab analysis tool for processing measurement data from the XY scanning spectroscopy setup. 

Clone this repository to your matlab path and save the path. 
View and analyze any .hdf5 file from the XY measurement setup by calling XYData('filename.hdf5'). 
This creates a XYData object and opens a gui to inspect and analyse the data. 
If you just want to read the raw measurement data into matlab without opening the gui, call  XYData('filename.hdf5', 'plot', false). 

The object can be saved by calling the savexy method on the object, which stores it as a .mat file. 
This can be opened either by loading the file or again calling XYData('filename.mat');

