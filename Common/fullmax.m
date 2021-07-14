function [m, index] = fullmax(A)
% FULLMAX returns the maximum of a matrix of arbitrary shape
    [m, index] = nanmax(reshape(A, numel(A), 1));
end