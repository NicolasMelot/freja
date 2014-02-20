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
%	Function shuffle
%
%	Rearranges data so values of aliases are sorted in order given as
%	argument. This function can only rearrange values having aliases.
%	Note that this function sorts the data to accelerate processing;
%	You may have to use orderby() if you need it sorted in a specific
%	order. Note further that this affect the value of aliases, in
%	particular when used in "where" clauses.
%	
%	
%	Parameters:
%	table:	The matrix to be filtered (table)
%	cols:	Columns to rearrange (cell of strings).
%	alias:	New order of aliases corresponding to the column in cols
%		(cell of cells of strings).
%	out:	Input table whose values with alias are rearranged
%
%	Example:
%	a = {
%	      [1,1] =
%		1 0 3 4
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
%             [1,3] = {{'label zero' 'label un' 'label dos'} {'label zero' 'label one' 'label two' 'label three' 'label four'} {}(0x0) {}(0x0)}
%             [1,4] = {{'zero' 'un' 'dos'} {'zero' 'one' 'two' 'three' 'four'} {}(0x0) {}(0x0)}
%	}
%	b = select(a, {'col1' 'col2'}, {'dos' 'un' 'zero'} {'four' 'three' 'two' 'one' 'zero'})
%	b = {
%	      [1,1] =
%		1 4 3 4
%		1 2 7 8
%		1 3 5 6
%		0 1 3 9
%		0 1 5 5
%		1 2 7 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{'label dos' 'label un' 'label zero'} {'label four' 'label three' 'label two' 'label one' 'label zero'} {}(0x0) {}(0x0)}
%             [1,4] = {{'dos' 'un' 'zero'} {'four' 'three' 'two' 'one' 'zero'} {}(0x0) {}(0x0)}
%	}
function out = shuffle(table, cols, refs)
	check(table);
	size_cols = size(cols);
	size_cols = size_cols(2);

	matrix = data(table, {''}, 0);
	matrix_size = size(matrix);
	matrix_size = matrix_size(2);

	ref_out = ref(table, {''});
	alias_out = alias(table, {''});

	aliases=alias(table, {''});

	for i = 1:size_cols
		table = orderby(table, {cols{i}});
		values = data(groupby(table, {cols{i}}, {}, {}), {cols{i}}, 0);
		col_index = cellfindstr(coln(table), cols{i});

		%% Initialize a new empty vector for this column
		new_vector = [];
		new_alias_row = {};

		%% Number of different values we need to update
		size_values = size(values);
		size_values = size_values(1);

		%% Number of aliases provided
		size_new = size(refs{i});
		size_new = size_new(2);

		%% Number of aliases already existing
		size_old = ref(table, {cols{i}});
		size_old = size_old{:};
		size_old = size(size_old);
		size_old = size_old(2);

		if size_new != size_old
			error(['New reference set for column ''' cols{i} ''' has a different amount of references than in table.'])
		end

		for j = 1:size_values
			value = values(j) + 1;

			%% Find the old alias for this value
			old_ref = ref(table, {cols{i}});
			old_ref = old_ref{:};
			old_ref = old_ref{value};

			%% Find the old alias for this value
			old_alias = alias(table, {cols{i}});
			old_alias = old_alias{:};
			old_alias = old_alias{value};

			old_index = cellfindstr(ref(table, {cols{i}}){1}, refs{i}{j});

			%% Find the new index for this alias
			new_index = cellfindstr(refs{i}, old_ref);
			if new_index < 1
				error(['Could not find alias ''' old_ref ''' in new aliases for column ''' cols{i} '''.']);
			end

			delta_index = value - new_index;

			%% Get the complete vector of this value
			value_vector = data(where(table, [ cols{i} ' == ' int2str(values(j)) ]), {cols{i}}, 0);
			%% Apply the transformation
			value_vector = value_vector - delta_index;
			%% Add this vector to the new vector
			new_vector = [new_vector; value_vector];

			new_alias = alias(where(table, [ cols{i} ' == ' int2str(values(j)) ]), {cols{i}});
			new_alias = new_alias{:};
			new_alias = new_alias{old_index};
			new_alias_row = {new_alias_row{:} new_alias};
		end
	
		matrix = [matrix(:, 1:col_index - 1) new_vector matrix(:, col_index + 1:matrix_size)];
		setd(table, matrix);
		aliases{col_index} = new_alias_row;
		ref_out{col_index} = refs{i};
	end

	out{1} = matrix;
	out{2} = table{2};
	out{3} = aliases;
	out{4} = ref_out;
end
