function [m, index] = fullmin(A)
% FULLMIN returns the minimum of a matrix of arbitrary shape
    m = nanmin(reshape(A, numel(A), 1));
    index = find(A==m);
end