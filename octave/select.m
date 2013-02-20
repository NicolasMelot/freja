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
%	Function select
%
%	Filters the input matrix to keep only the columns given as parameter.
%	
%	
%	Parameters:
%	table:	The matrix to be filtered (table)
%	cols:	Column string to be kept. Behavior is undefined if a column is
%		selected twice (list of strings).
%	def:	Default value to insert if a column was not found in table (scalar)
%	out:	The input matrix without any column not listed in cols (table)
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
%	b = select(a, ['col2' 'col4'])
%	b = {
%	      [1,1] =
%		1 4
%		2 8
%		1 6
%		3 9
%		3 5
%		2 7
%
%	      [1,2] =
%		col2
%		col4
%	}

function out = select(table, cols, def)
	stuff=size(cols);
	stuff=stuff(2);

	for i = 1:stuff
		index = cellfindstr(table{2}, cols{i});
		if index > 0
			data(:, i) = table{1}(:, index);
		else
			warning(['Could not find column ''' cols{i} ''' in table. Filling with value ' int2str(def) '.']);
			colsize = size(table{1});
			colsize = colsize(1);
			data(:, i) = ones(colsize, 1) .* def;
		end
			col(i)= cols(i);
	end
out{1} = data;
out{2} = col;
end






