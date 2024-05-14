function [A] = flatten(B)
%FLATTEN flatten matrix to pass into CXX converters

    A = B(:)';

end

