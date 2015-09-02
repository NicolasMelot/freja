% Copyright 2015 Nicolas Melot
%
% This file is part of Freja.
% 
% Freja is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% Freja is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Freja. If not, see <http://www.gnu.org/licenses/>.
%




%
% =========================================================================
%
%	Function orderby
%
%	Sorts the table content along columns in order of priority given
%	by the ordered sequence of column names given as parameter.
%	
%	
%	Parameters:
%	table:	The matrix to be sorted (table)
%	cols:	Columns the table should be sorted along. Columns in
%		first position in this list are more prioritary than
%		following columns. Other columns in table are ignored
%		(cell of strings).
%	out:	The input table sorted along the columns given.
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
%
%             [1,3] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%	}
%	b = tablesort(a, {'col1' 'col2'])
%	b = {
%	      [1,1] =
%		1 1 3 4
%		1 1 5 6
%		1 2 7 8
%		1 2 7 7
%		2 3 3 9
%		2 3 5 5
%
%	      [1,2] =
%		col2
%		col4
%		col3
%		col4
%
%             [1,3] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%	}

function out = orderby(table, cols)
	check(table);
	matrix = data(table, {''}, 0);

	size_cols = size(cols);
	size_cols = size_cols(2);

	for i = 1:size_cols;
		ii = size_cols - i + 1;
		index = cellfindstr(coln(table), cols{ii});

		if index > 0
			matrix = sortrows(matrix, index);
		else
			error(['Cannot find column ''' cols{i} '''.']);
		end
	end

	out{1} = matrix;
	out{2} = coln(table);
	out{3} = alias(table, {''});
	out{4} = ref(table, {''});
end
