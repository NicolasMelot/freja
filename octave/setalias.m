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
%	table = {
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
%             [1,3] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%	}
%	cols = {'colA' 'colB' 'colC' 'colD'}
%	b = setc(table, {'col2'}, {{'one' 'two' 'three'}})
%	b = {
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
%             [1,3] = {{}(0x0) {'one' 'two' 'three'} {}(0x0) {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%	}

function out = setalias(table, cols, aliases)
	check(table);

	size_cols = size(cols);
	size_cols = size_cols(2);

	out = table;
	alias_out = table{3};
	ref_out = table{4};

	for i = 1:size_cols
		index = cellfindstr(coln(table), cols{i});
		if index > 0
			alias_out{index} = aliases{i};

			if prod(size(ref_out{index})) == 0
				size_alias = size(aliases{i});
				size_alias = size_alias(2);
				ref_out{index} = {};
				for j = 1:size_alias
					ref_out{index}{j} = strrep(strrep(strrep(strrep(strrep(aliases{i}{j}, '^', ''), '{', ''), '}', ''), '_', ''), ' ', '_');
				end
			end
		else
			error(['Cannot find column ''' cols{i} '''.']);
		end
	end

	out{3} = alias_out;
	out{4} = ref_out;
end
