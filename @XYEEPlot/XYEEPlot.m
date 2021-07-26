classdef XYEEPlot
    %XYEEPLOT Summary of this class goes here
    %   Detailed explanation goes here

    properties
        XYEEobj
        rgb
        xyl
    end
    
    methods
        % Constructor
        function obj=XYEEPlot(XYEEobj, varargin)
            
            obj.XYEEobj = XYEEobj;
            
            switch obj.XYEEobj.experiment
                case 'ExcitationEmission'
                    if length(obj.XYEEobj.ex_wl)>1
                        obj = rgb_ex_process(obj);
                    else
                        obj = rgb_em_process(obj);
                    end
                case 'Decay'
                    obj = rgb_decay_process(obj);
                case "transmission"
                    obj = rgb_transmission_process(obj);
            end
                        
            obj = plot(obj, varargin);
            
        end
        
        function obj = plot(obj, varargin)
            
            varargin = cellflat(varargin);
            plotenergy = false;
            plotme = true;
            for k=1:2:length(varargin)
                switch varargin{k}
                    case 'energy'
                        plotenergy = varargin{k+1};
                    case 'plot'
                        plotme = varargin{k+1};
                end
            end            
            
            if plotme
                switch obj.XYEEobj.experiment
                    case 'ExcitationEmission'
                        if numel(obj.XYEEobj.xycoords)/2 == 1
                            obj = sspe_plot(obj);
                        elseif length(obj.XYEEobj.ex_wl)>1
                            obj = rgb_ex_plot(obj);
                        elseif plotenergy
                            obj = rgb_em_plot_energy(obj);
                        else
                            obj = rgb_em_plot(obj);
                        end
                    case 'Decay'
                        if numel(obj.XYEEobj.xycoords/2) == 1
                            obj = sspd_plot(obj);
                        else
                            obj = rgb_decay_plot(obj);
                        end
                    case "transmission"
                        obj = rgb_transmission_plot(obj, varargin);
                end
            end
        end
        
    end
    
    methods %(Access = protected)
        % Plot methods
        handle = sspe_plot(obj);
        handle = rgb_ex_plot(obj);
        handle = rgb_em_plot(obj);
        handle = rgb_em_plot_energy(obj);
        handle = sspd_plot(obj);
        handle = rgb_decay_plot(obj);
        handle = rgb_transmission_plot(obj, varargin);
        % Processing methods
        obj = rgb_ex_process(obj);
        obj = rgb_em_process(obj);
        obj = sspd_process(obj);
        obj = rgb_decay_process(obj);
        obj = rgb_transmission_process(obj);
    end
    
end

