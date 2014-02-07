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
%	cols:	Column string to be kept. an empty string denotes all columns.
%		A column selected twice or more creates a new column whose name
%		is appended a random (but distinct) number (list of strings).
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
%
%             [1,3] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
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
%
%             [1,3] = {{}(0x0) {}(0x0)}
%	}

function out = select(table, cols, def)
	cols_size = size(cols);
	cols_size = cols_size(2);

	check(table);

	selected = {};
	data = [];
	alias={};
	all = 0;

	for i = 1:cols_size
		% Include the whole original table
		if strcmp(cols{i}, '')
			tsize = size(table{2});
			tsize = tsize(2);
			data = [data table{1}];
			alias = {alias{:} table{3}{:}};
			
			for j = 1:tsize
				col = table{2}{j};
				already = cellfindstr(selected, col);

				if already > 0
					new_name = request_name(selected, col);
					warning(['Column ''' col ''' already inserted; renaming to ''' new_name '''.']);
					selected = {selected{:} new_name};
				else
					selected = {selected{:} col};
				end
			end
		else % Include only one column
			col = cols{i};
			index = cellfindstr(table{2}, col);

			% Insert data
			if index > 0 % The column exists
				data = [data table{1}(:, index)];
				alias = {alias{:} table{3}{index}};
			else % The column doesn't exist. Filling with default value and create column name as requested
				if prod(size(strfind(col, 'no_warning'))) == 0
					warning(['Could not find column ''' col ''' in table. Filling with value ' int2str(def) '.']);
				end
				colsize = size(table{1});
				colsize = colsize(1);
				data = [data ones(colsize, 1) .* def];
				alias = { alias{:} {} };
			end

			% Add column name
			already = cellfindstr(selected, col);
			if already > 0 % This column was already inserted
				new_name = request_name(selected, col);
				warning(['Column ''' col ''' already inserted; renaming to ''' new_name '''.']);
				col = new_name; % Append a unique number, which argument we are processing
			end
			selected = {selected{:} col};
		end
	end

	out{1} = data;
	out{2} = selected;
	out{3} = alias;
end

