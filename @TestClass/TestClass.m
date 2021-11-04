classdef TestClass
    %UNTITLED4 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        prop1
        prop2
    end
    
    methods
        % constructor
        function obj = TestClass(inputarg)
            %UNTITLED4 Construct an instance of this class
            %   Detailed explanation goes here
            obj.prop1 = inputarg;
        end
    end
    
    methods
        function obj = method(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            obj.prop2 = 5;
        end
    end
end

