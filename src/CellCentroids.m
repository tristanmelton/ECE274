classdef CellCentroids
    %CELLCENTROIDS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Cells
    end
    
    methods
        function obj = CellCentroids(cents)
            obj.Cells = cents;
        end
        
        function outputArg = method1(obj,inputArg)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            outputArg = obj.Cells + inputArg;
        end
    end
end

