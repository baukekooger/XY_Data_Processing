# XY_Data_Processing
# Requirement: Matlab Version 2021a or newer. 

Matlab analysis tool for processing measurement data from the XY scanning spectroscopy setup. 

Clone this repository to your matlab path and save the path. 
View and analyze any .hdf5 file from the XY measurement setup by calling XYData(<'filename.hdf5'>). 
This creates a XYData object and openes a gui to inspect and analyse the data. 
If you just want to read the raw measurement data into matlab without opening the gui, call  XYData(<'filename.hdf5'>, 'plot', false). 

