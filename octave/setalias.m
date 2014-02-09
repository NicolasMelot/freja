%    Copyright 2013 Nicolas Melot
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
%	Function setalias
%
%	Replace aliases of given columns with new aliases provided
%	
%	
%	Parameters:
%	table:	The table to which (table).
%	coln:	Columns that will receive the new aliases (cell of string).
%	aliases:New alias collections ordered as column names in coln
%		(cell of cells of string)
%	out:	The table from merged data (table)
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
%	cols = {'colA' 'colB' 'colC' 'colD'}
%	b = setc(a, coln)
%	b = {
%	      [1,1] =
%		7 7 8 2
%		4 5 3 2
%
%	      [1,2] =
%		colA
%		colB
%		colC
%		colD
%	}

function out = setalias(table, cols, aliases)
	check(table);

	size_cols = size(cols);
	size_cols = size_cols(2);

	out = table;
	alias_out = table{3};

	for i = 1:size_cols
		index = cellfindstr(coln(table), cols{i});
		if index > 0
			alias_out{index} = aliases{i};
		else
			error(['Cannot find column ''' cols{i} '''.']);
		end
	end

	out{3} = alias_out;
end
