classdef XYData < handle
%% XYEE Class
% This class processes any XYEE measurement. 
% It is devised to be context-sensitive, i.e. any measurement done with 
% the XYEE (pyXY) software can be processed automatically using the 
% appropriate methods. 
%
% An XYEE object (Essentially a struct containing the processed measurement
% results) is constructed as:
%
% XYEEObject = XYEE(filename, ...);
%
% This command will automatically plot the processed data in a data-picker
% view (2 separate figures). Using the MATLAB data-picker in the overview
% plot (the second generated figure) will display the data that underlies
% that point in the spectral plot (the first generated figure). Multiple
% points can be compared by SHIFT + Clicking another datapoint in the
% overview plot.
%
% Public Properties:
% fname: The underlying filename of the hdf5-file used to construct the
%        XYEE Object
%
% experiment: The type of experiment carried out. Possible options are:
%             'ExcitationEmission', 'Decay', 'Transmission'
%
% em_wl: Array of wavelengths recorded by the spectrometer used ('Emission
%        wavelength')
%
% ex_wl: Array of wavelengths used to excite the sample (not applicable in
%        case of transmission)
% 
% xycoords: 3D vector of xy-coordinates (in mm) that were measured.
%           Arranged as [X, Y, [value of X, value of Y]
%
% spectrum: The spectrum recorded by the spectrometer used. Arranged as
%   * 'ExcitationEmission': [X,Y, Excitation Wavelength index, 
%                         Emission wavelength index]
%   * 'Decay': [X,Y, Excitation Wavelength index, 
%                         Emission wavelength, Decay value]
%   * 'Transmission': [X,Y, wavelength index]
%
% dark: Values of dark measurements, if applicable. Arranged similarly to
%       spectrum.
%
% power: Values of incident power, if applicable. Arranged similarly to
%       spectrum.
%
% fitdata: Results from one of the internal fitting procedures, if carried
%          out. More details per-experiment in their sections.
%
% time: Only applicable for decay. [X,Y, Excitation Wavelength index, 
%                         Emission wavelength, Time after trigger]
%
% Certain measurements do however come with extra options, or futher 
% processing, as is detailed below.
%
% Single-Position Excitation/Emission (SPEE)
% Constructor:
% * 'plot', true | false : Plot if true
%
% XYEmission
% Constructor:
% * 'plot', true | false : Plot if true
%
% Data-Processing:
% * XYEEObject.fit(guess, x0, y0, passes, ...)
%   fit(XYEEObj, ...) fits an XYEmission scan to a series of gaussians with
%   initial positions and widths as specified in guess.
%   
%   Most standard way to fit is:
% 
%   XYEEObject = XYEEObject.fit(guess, x0, y0, passes, 'emission', true);
%
%   - guess: First guess for the properties of the gaussians, specified as
%            [Position_1, Width_1, Position_2, Width_2, ...] all in the
%            same unit as the processed spectrum will be (typically eV).
%   - x0: Initial x starting point of the guess.
%   - y0: Initial y starting point of the guess.
%   - passes: Amount of times the fitting algorithm will run over all
%             xy-coordinates
%   
%   Additional Options for 'fit':
%   Preprocessing:
%       > 'emission', true | false: Convert input data to energy (eV) 
%                                     scale
%       > 'emission_norm', true | false: Convert input data to energy
%                                          (eV) scale and normalizes the
%                                          heighest datapoint per
%                                          coordinate to 1.
%   Further bounds or options for fitting:
%       > 'position_bounds' | 'positionbounds' | 'pb', ...
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these central positions (in nm) +/-
%               their initial guessed position
%       > 'position_bounds_eV' | 'positionboundsev' | 'pbev',
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these central positions (in eV) +/-
%               their initial guessed position
%       > 'x_percent_center_bounds' | 'xpercentcenterbounds' | 'xpcb',
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these central positions (in %) of
%               their initial guessed position
%       > 'width_bounds' | 'widthbounds' | 'wb',
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these widths (in nm) +/-
%               their initial guessed width
%       > 'width_bounds_eV' | 'widthboundsev' | 'wbev',
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these widths (in eV) +/-
%               their initial guessed width
%       > 'x_percent_width_bounds' | 'xpercentwidthbounds' | 'xpwb':
%          global_bound |[peak1_bound, peak2_bound, ...]:
%               Peaks cannot exceed these widths (in %) of
%               their initial guessed width
%       > 'height_bounds' | 'heightbounds' | 'hb',
%          [peak1_bound_min, peak1_bound_max; ...]:
%               Peaks cannot exceed these heights
%       > 'height_bounds_with_max_height' | 'heightboundsmaxheight' | 'hbmh',
%          [peak1_bound_min, peak1_bound_max; ...]:
%               Peaks cannot exceed these heights
%       > 'x_percent_height_bounds' | 'xpercentheightbounds' | 'xphb',
%          [peak1_bound_min, peak1_bound_max; ...]:
%               Peaks cannot exceed these heights in % of their initial
%               guess
%       > 'maximal_area' | 'maximalarea' | 'maxA',
%          global_bound | [peak1_bound_min, peak2_bound_min, ...]:
%               Peaks cannot exceed these areas
%       > 'window' | 'w', [xmin, xmax]: Only fit within this window
%       > 'weight' | 'wt', [weigths]: List of how much a point has to
%                                     weigh when fitting
%       > 'robust' | 'r', 'off' (default) | 'LAR' | 'Bisquare':
%                   * 'off' no robust fitting
%                   * 'LAR' specifies the least absolute residual method.
%                   * 'Bisquare' specifies the bisquare weights method.
%
%   XYEEObject.fit(...) RETURNS:
%       The original XYEEObject with added XYEEObject.fitdata containting
%       all PeakFit objects used for the fitting.
%
% Additional methods:
% * XYEEObject.fit_ee_overview() : Plots an overview of the fitting results
% * XYEEObject.normalize('energy' | 'wavelength'): Normalizes the
%       XYEEObject according to the given option.
%
% XYDecay
% Constructor:
% * 'plot', true | false : Plot if true
% * 'decay_time', '2 ns' | '2ns' | '64 ns' | '64ns' : 
%           Set the decay-time timebase to 2 ns or 64 ns.
%
% Data-Processing:
% * XYEEObject.fit(exclude_after, ...) :
%    Highly experimental fitting procedure. Use with caution; only use when
%    you fully understand the source.
%
% XYTransmission
% Constructor:
% * 'plot', true | false : Plot if true
% * 'autocorrect' | 'ac' | 't': Processes the measurement using the first
%       y-measurement per row of x-measurements as 'lamp' spectrum; and
%       minimal (summed) measured value as 'dark'.
% * 'remove_dark' | 'rd' | 'h': Subtracts minimal (summed) measured value 
%       as 'dark'. Useful when doing HAZE measurements.
%
% Data-Processing:
% XYEEObject = XYEEObject.fit(Data, x0, y0, nsub, ns_wl, d0, passes, ...)
% or
% XYEEObject = XYEEObject.fit(Data, x0, y0, nsub, ns_wl, d0, passes, wlmin, wlmax ...)
%
% fit(XYEEObj, ...) fits an XYTransmission scan using the
% Extended-Sellmeier method, as detailed in 
% https://doi.org/10.1016/j.jlumin.2018.12.011
%   
% * Data: Usually an OPTIFIT table with the initial fitting data, but can be
%          anything formatted as:
%           - Data.Wavelengthnm (Wavelengths decribed in nm)
%           - Data.Refractive_index (Refractive index vector)
%           - Data.Extintion_coefficient (Extinction coefficient vector,
%                       Pay mind that there is no "c" in "Extinction", this is a 
%                       remnant of using OPTIFIT)
% * x0: x-index where the initial fitting started
% * y0: y-index where the initial fitting started
% * nsub: 'a' value of index of refraction of the substrate
% * ns_wl: 'b' value of the index of refraction of the substrate
% * d0: Initial guess of the thickness
% * passes: Desired amount of repeats to the fitting
% OPTIONAL
% * wlmin: minimum wavelength (in nm) to start fitting; else set to 310 nm
% * wlmax: maximum wavelength (in nm) to end fitting; else set to 850 nm
% OPTIONAL ARGUMENTS
% * 'continue' | 'c': with as next argument a boolean to indicate if the
%       XYEEobj already has fitted data and which should be used as input
% * 'custom_fitoptions' | 'cfopt' | 'fitopts': with as next arguments a struct
%           with custom fitoptions formatted as a MATLAB fitoptions struct
% * 'topval': with as next argument the percentage of highest adj.-R^2 data 
%               that should be used as seeds for the next fitting pass
%
% RETURNS
%   The input XYEEObject, with added:
%   XYEEobj.fitdata.fitresult
%       A cell filled with MATLAB fitobjs with the results of the fitting.
%       Sized {x number, y number}
%   XYEEobj.fitdata.gof 
%       A cell filled with MATLAB goodness of fit indicators for each
%       fitting in XYEEobj.fitdata.fitresult
%
% Additional Methods:
% * XYEEObject.thickness() : Returns a NxM Matrix with the fitted
%                            thicknesses.
% -------------------------------------------------------------------------
% XYEE was written by: Evert P.J. Merkx
% Contact: e.p.j.merkx at tudelft.nl
% 
% If you use the results coming from this software for any public or
% private use, please cite:
%  E. P. J. Merkx and E. van der Kolk, 
%  "Method for the Detailed Characterization of Cosputtered Inorganic 
%  Luminescent Material Libraries," ACS Comb. Sci., vol. 20, no. 11, 
%  pp. 595?601, Nov. 2018.
% 
%  and
%
%  E. P. J. Merkx, S. van Overbeek, and E. van der Kolk, 
%  "Functionalizing window coatings with luminescence centers by 
%   combinatorial sputtering of scatter-free amorphous SiAlON:Eu2+ thin 
%   film composition libraries," J. Lumin., vol. 208, pp. 51?56, Apr. 2019.
%
% CC-AT-BY 2016
    
    properties
        fname
        experiment
        comment
        sample
        substrate
        filters = struct('neutral_density', [], 'longpass', [], ...
            'bandpass', [])
        beamsplitter = struct('model', [], 'correction_pm_to_sample',...
            [], 'wavelengths', [], 'calibration_date', [], ... 
             'power_pm', [], 'power_sample', [], 'times_pm', ...
             [], 'times_sample', [])  
        laser = struct('wlnum', [], 'excitation_wavelengths', [], ...
            'energy_level', [])
        spectrometer = struct('model', [], 'integration_time', [], ...
            'averageing', [], 'fiber', [], 'wavelengths', [], ...
            'spectra', [], 'darkspectrum', [], 'lampspectrum', [], ...
            'efficiency', [])  
        digitizer = struct('model', [], 'sample_rate', [], ...
            'samples', [], 'active_channels', [], ...
            'post_trigger_size', [], 'spectra', [] , ...
            'time', [], 'pulses', [], 'dc_offset', [], ...
            'jitter_channel', [], 'jitter_correction', [], ...
            'measurement_mode', [], 'single_photon_counting_treshold', ...
            [], 'data_channel', [])
        powermeter = struct('power', [], 'time', [], 'sensor', [], ...
            'integration_time', [], 'sensor_calibration_date', [],...
            'sensor_serial_number', []) 
        pmt = struct('type', [], 'voltage', [])
        xystage = struct('type', [], 'coordinates', [], ...
            'xnum', [], 'ynum', [])
        fitdata = struct('fitobjects', [], 'goodnesses', [], ...
            'outputs', [], 'fitoptions', [], 'fittype', [], ...
            'optifit_fname', [])  
        plotdata = struct('spectra_transmission', [], ...
            'wavelengths_transmission', [], ...
            'darkspectrum_transmission', [], ...
            'lampspectrum_transmission', [], ...
            'spectra_emission', [], 'wavelengths_emission', [], ...
            'spectra_excitation', [], 'wavelengths_excitation', [], ...
            'power_excitation', [], 'darkspectrum_emission', [], ...
            'spectra_decay', [], 'time_decay', [], 'rgb', [], ...
            'xy_coordinates', [], 'xyl', []); 
        datapicker 
        datacursor = struct('xy', [], 'plotwindow', [])
        plotwindow =  struct('figure', [], 'ax_spectrum', [], 'ax_rgb', [])
    end
    
    methods
        % Constructor
        function obj=XYData(varargin)
            varargin = cellflat(varargin);
            N = nargin;
            if ~N
                return
            end
            
            % Copy the XYData object if given in the first argument
            k=1;
            if isa(varargin{k}, class(obj)) && k==1
                obj = varargin{k};
                k=k+1;
            end
            if isa(varargin{k}, 'char') && k==1
                obj.fname = varargin{k};
                k=k+1;
            end
            
            varargin = varargin(k:end);
            
            plotme = true;
            for k=1:2:numel(varargin)
                switch varargin{k}
                    case 'plot'
                        plotme = varargin{k+1};
                end
            end
            
            read_attributes(obj);  

            switch obj.experiment
                case 'excitation_emission'
                    read_excitation_emission(obj);
                case 'decay'
                    read_decay(obj);
                case 'transmission'
                    read_transmission(obj);
            end
            
            if plotme
                plot(obj);
            end
        end
    end
    
    % Only one public method, plot. All other methods are in the private
    % folder to prevent calling methods from outside of ui and to prevent 
    % a long list of private methods. 
    
    methods (Access=public)
        function plot(obj)
           switch obj.experiment
               case 'transmission'
                   if isempty(obj.plotdata.spectra_transmission)
                       set_spectra_transmission(obj);
                   end
                   plot_transmission(obj); 
               case 'excitation_emission'
                   if isempty(obj.plotdata.spectra_emission)
                       set_spectra_excitation_emission(obj);
                   end
                   plot_excitation_emission(obj);  
               case 'decay'
                   if isempty(obj.plotdata.spectra_decay)
                       set_spectra_decay(obj); 
                   end
                   plot_decay(obj); 
           end
        end
        function savexy(obj)
        % Save the XYData object. Datapickers and figures are temporarily 
        % removed from the object as they cannot be saved, and there is 
        % also little point in saving them. Plotdata and fitdata are 
        % stored. 
            picker = obj.datapicker; 
            window = obj.plotwindow; 
            
            obj.datapicker = []; 
            obj.plotwindow = []; 
        
            directory = uigetdir(pwd); 
            
            filename = erase(obj.fname, '.hdf5'); 
            filename = [directory, '\', filename]; 
            save(filename, 'obj'); 
        
            obj.datapicker = picker; 
            obj.plotwindow = window; 
        end

    end
    
end

