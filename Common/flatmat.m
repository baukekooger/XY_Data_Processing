function m = flatmat(A)
% FLATMAT flattens input matrix A

m = reshape(A, [numel(A), 1]);

end