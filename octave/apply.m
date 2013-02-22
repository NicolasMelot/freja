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
%	Function apply
%
%	Applies a function to a matrix row by row, and writes its scalar
%	output in the approriate column of this matrix in the same row.
%	
%	
%	Parameters:
%	table:	The table containing data to apply the function to (table).
%	coln:	Cell of column names where function outputs are written.
%		Note processing order is undefined (string).
%	func:	Functions to apply to the tables' rows (pointer to function).
%		Usually a user-defined function denoted by @<function_name>.
%		The function must take the followin signature:
%		function y = <function_name>(table, coln), where:
%		* Table is the same table as apply function table argument
%		  (table).
%		* coln is the column name where result is written (string).
%		* output is the result vector, exactly as long as table has
%		  lines (vector).
%	aux	Auxiliary data the user may need to pass to functions
%		(undefined type).
%	out:	The table after computation.

function out = apply(table, col, func, aux)
	size_matrix = size(table{1});
	size_y = size_matrix(1);

	col_size = size(col);
	col_size = col_size(2);

	matrix = table{1};

	for j = 1:col_size
		index = cellfindstr(table{2}, col{j});
		if index > 0
			matrix(:, index) = func{j}(table, col{j}, aux);
		else
			error(['Couldn''t find column ''' col{j} '''.']);
		end
	end

	out{1} = matrix;
	out{2} = table{2};
end

