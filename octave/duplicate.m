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
%	Function duplicate
%
%	Duplicate or create once or more, one or several columns of a given table
%	
%	
%	Parameters:
%	table:	The table to which columns are to be duplicated added (table)
%	src:	Column names to duplicate. If you don't need any column to copy
%		from, give a name denoting a column that does not exist. In that
%		case, the given name is *not* used as name for the new column
%		(cell of strings).
%	names:	Name to give to new columns inserted. The actual position of new
%		columns are undefined (cell of strings).
%	def:	Value to fill a column not copied from an existing column (scalar).
%	out:	The table with duplicated columns (table).
%
%	Example:
%	a = {
%	      [1,1] =
%		1 2 3 4
%		5 6 7 8
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%	}
%	b = duplicate(a, {'col3' 'col4' 'col4' 'col_none'}, {'col3b', 'col4b', 'col4c', 'new_col'}, 0)
%	b = {
%	      [1,1] =
%		1 2 3 4 3 4 4 0
%		5 6 7 8 7 8 8 0
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col3b
%		col4
%		col4b
%		col4c
%		new_col
%	} 

function out = duplicate(table, src, names, def)
	src_size = size(src);
	src_size = src_size(2);

	data = table{1};
	tbl_size = size(data);
	tbl_size = tbl_size(2);
	col = table{2};

	for i = 1:src_size
		index = cellfindstr(table{2}, src{i});
		tbl_size += 1;
		if index > 0
			data(:, tbl_size) = data(:, index);
		else
			data_size = size(data(:, 1));
			data_size = data_size(1);
			data(:, tbl_size) = ones(data_size, 1) .* def;
		end
		col{tbl_size} = names{i};
	end

	out{1} = data;
	out{2} = col;
end


















