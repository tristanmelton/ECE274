classdef Cell
    %CELL Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Centroid
        Label
        Color
        Area
    end
    
    methods
        function obj = Cell(Centroid, Label, Color, Area)
            %CELL Construct an instance of this class
            %   Detailed explanation goes here
            obj.Centroid = Centroid;
            obj.Label = Label;
            obj.Color = Color;
            obj.Area = Area;
        end
    end
end

