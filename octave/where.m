%    Copyright 2011 Nicolas Melot
%
%    Nicolas Melot (nicolas.melot@liu.se)
%
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>.
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
%	table:	The matrix to be filtered (table)
%	cols:	Indexes of columns to be checked (cell of strings).
%	refs:	The possible value each column can take. The cell containts
%		exactly as much vectors as there as elements in cols. Each
%		element is a vector containing every value the corresponding
%		column can take (cell of vectors).
%	out:	The input matrix without any row which at least one inspected
%		column does not fulfil its requirements (matrix).
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 4
%		1 2 7 8
%		1 1 5 6
%		2 3 3 9
%		2 3 5 5
%		1 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%	}	
%	b = where(a, {'col2' 'col4'}, {[1 2] [4 8 7]})
%	b = {
%	      [1,1] =
%		1 1 3 4
%		1 2 7 8
%		1 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%	}

function out = where(table, cols, refs)
data=table{1};
maxi=size(cols);
max=maxi(2);

for i = 1:max
	col = cellfindstr(table{2}, cols{i});
	ref = refs{1, i};

	cond = data(:, col) == ref(1, 1);
    
	maxj = size(ref);
	maxj = maxj(2);
	for j = 2:maxj
		data(:, col) = 1 .* data(:, col);
		cond = cond | data(:, col) == ref(1, j);
	end

	out{1} = data(find(cond), :);
	out{2} = table{2};
end
end
