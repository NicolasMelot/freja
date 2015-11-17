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

			%% See if we have a reference list for this column. If not, make one up from alias with not space, exponent, index or curly braces and set the corresponding values to a linear integer index
			if prod(size(ref_out{index})) == 0
				%% Compute a reference
				size_alias = size(aliases{i});
				size_alias = size_alias(2);
				ref_out{index} = {};
				for j = 1:size_alias
					ref_out{index} = {ref_out{index}{:} strrep(strrep(strrep(strrep(strrep(aliases{i}{j}, '^', ''), '{', ''), '}', ''), '_', ''), ' ', '_')};
				end

				%% Transform the data to linear integers indices indexing aliases and references
				%% Get all values as they are so far
				colx = cols{i};
				allx_values = data(table, {colx}, 0);
				all_x = data(table, {colx}, 0);
				all_x = unique(sort(all_x));

				%% Get how many values we have, and the max value so we can make sure no value gets transformed twice
				size_allx = size(all_x);
				maxx = ceil(max(all_x));

				%% Build the correct alias and ref vector
				%% Compute a 'grouped' x vector in case it's needed
				for i = 1:size_allx
					%% Replace all values by i + maxx, so the new value is guaranteed to be different than any other
					allx_values(allx_values == all_x(i)) = maxx + i;
				end
				%% Substract maxx so we get integers again
				allx_values -= maxx + 1;
				table = apply(table, {colx}, {@setC}, allx_values);
			end
		else
			error(['Cannot find column ''' cols{i} '''.']);
		end
	end

	out{1} = table{1};
	out{3} = alias_out;
	out{4} = ref_out;
end

function out = setC(table, coln, aux)
	out = aux;
end
