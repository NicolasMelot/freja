

%
% =========================================================================
%
%	Function where
%
%	Filters the input matrix to keep only the rows fulfilling some equality
%	requirement. When selecting rows, the function allows the expression of
%	conjunctions (a column col1 must fulfill condition cond1 AND a column
%	col2 different to col1 must fulfil condition cond2) as well as
%	disjunctions (a column col1 must take the value v1 OR the value v2).
%	
%	
%	Parameters:
%	matrix:	The matrix to be filtered (matrix)
%	cols:	Indexes of columns to be checked (vector).
%	refs:	The possible value each column can take. The cell containts
%		exactly as much vectors as there as elements in cols. Each
%		element is a vector containing every value the corresponding
%		column can take (cell of vectors).
%	out:	The input matrix without any row which at least one inspected
%		column does not fulfil its requirements (matrix).
%
%	Example:
%	a = [1 1 3 4; 1 2 7 8; 1 1 5 6; 2 3 3 9; 2 3 5 5 ; 1 2 7 7]
%	a = [
%		1 1 3 4 ;
%		1 2 7 8 ;
%		1 1 5 6 ;
%		2 3 3 9 ;
%		2 3 5 5 ;
%		1 2 7 7 ;
%	]
%	b = where(a, [2 4], {[1 2] [4 8 7]})
%	b = [
%		1 1 3 4 ;
%		1 2 7 8 ;
%		1 2 7 7 ;
%	]

function out = where(matrix, cols, refs)
out = matrix;
maxi=size(cols);
max=maxi(2);

for i = 1:max
	col = cols(1, i);
	ref = refs{1, i};

	cond = out(:, col) == ref(1, 1);
    
    maxj = size(ref);
    maxj = maxj(2);
	for j = 2:maxj
		out(:, col) = 1 .* out(:, col);
		cond = cond | out(:, col) == ref(1, j);
	end

	out = out(find(cond), :);
end
end
