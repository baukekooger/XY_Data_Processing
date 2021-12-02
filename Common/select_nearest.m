function [value, index] = select_nearest(vector, input)
% Select the value in a vector of unique elements closest to the input 
% value. 
    arguments
        vector (:,1) double {mustBeUnique(vector)}
        input  (1,1) double
    end
    [~, index] = min(abs(vector-input));
    value = vector(index); 
end

function mustBeUnique(vector)
% Test if vector has only unique values
    uniquevector = unique(vector); 
    if ~isequal(size(vector),size(uniquevector))
        eid = 'Data:notUnique';
        msg = 'Input vector has duplicate values, must be unique vector.';
        throwAsCaller(MException(eid,msg))
    end
end
