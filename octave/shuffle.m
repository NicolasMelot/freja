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
%	Rearranges data so values of refs are sorted in order given as
%	argument. This function can only rearrange values having refs.
%	Note that this function sorts the data to accelerate processing;
%	You may have to use orderby() if you need it sorted in a specific
%	order. Note further that this affect the value of refs, in
%	particular when used in "where" clauses.
%	
%	
%	Parameters:
%	table:	The matrix to be filtered (table)
%	cols:	Columns to rearrange (cell of strings).
%	ref:	New order of refs corresponding to the column in cols
%		(cell of cells of strings).
%	out:	Input table whose values with ref are rearranged
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
%             [1,3] = {{'valeur zero' 'valeur un' 'valeur deux'} {'value zero' 'value one' 'value two' 'value three' 'value four'} {}(0x0) {}(0x0)}
%             [1,4] = {{'valeur_zero' 'valeur_un' 'valeur_deux'} {'value_zero' 'value_one' 'value_two' 'value_three' 'value_four'} {}(0x0) {}(0x0)}
%	}
%	b = shuffle(a, {'col1' 'col2'}, {{'valeur_deux' 'valeur_un' 'valeur_zero'} {'value_four' 'value_three' 'value_two' 'value_one' 'value_zero'}})
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
%             [1,3] = {{'valeur deux' 'valeur un' 'valeur zero'} {'value four' 'value three' 'value two' 'value one' 'value zero'} {}(0x0) {}(0x0)}
%             [1,4] = {{'valeur_deux' 'valeur_un' 'valeur_zero'} {'value_four' 'value_three' 'value_two' 'value_one' 'value_zero'} {}(0x0) {}(0x0)}
%	}
function out = shuffle(table, cols, refs)
	check(table);
	size_cols = size(cols);
	size_cols = size_cols(2);

	alias_out = alias(table, {''});
	ref_out = ref(table, {''});

	for i = 1:size_cols
		table = orderby(table, {cols{i}});

		matrix = data(table, {''}, 0);
		matrix_size = size(matrix);
		matrix_size = matrix_size(2);

		values = data(groupby(table, {cols{i}}, {}, {}), {cols{i}}, 0);
		col_index = cellfindstr(coln(table), cols{i});

		%% Initialize a new empty vector for this column
		new_vector = [];

		%% Number of different values we need to update
		size_values = size(values);
		size_values = size_values(1);

		%% Number of refs provided
		size_new = size(refs{i});
		size_new = size_new(2);

		%% Number of refs already existing
		size_old = ref(table, {cols{i}});
		size_old = size_old{:};
		size_old = size(size_old);
		size_old = size_old(2);

		if size_new != size_old
			error(['New reference set for column ''' cols{i} ''' has a different amount of reference (' int2str(size_new) ') than in table (' int2str(size_old) ').']);
		end

		%% Initialise an empty alias collection
		aliases{i} = {};
		old_ref = ref(table, {cols{i}});
		old_ref = old_ref{:};
		old_alias = alias(table, {cols{i}});
		old_alias = old_alias{:};

		for j = 1:size_old
			ref_index = cellfindstr(old_ref, refs{i}{j});
			if ref_index < 1
				error(['Could not find alias ''' refs{i}{j} ''' in existing aliases for column ''' cols{i} '''.']);
			end
			tmp_alias = aliases{i};
			aliases{i} = {tmp_alias{:}, old_alias{ref_index}};
		end

		for j = 1:size_values
			value = values(j) + 1;

			%% Find the old ref for this value
			old_ref_val = old_ref{value};

			%% Find the new index for this ref
			new_index = cellfindstr(refs{i}, old_ref_val);
			if new_index < 1
				error(['Could not find ref ''' old_ref_val ''' in new refs for column ''' cols{i} '''.']);
			end

			delta_index = value - new_index;

			%% Get the complete vector of this value
			value_vector = data(where(table, [ cols{i} ' == ' int2str(values(j)) ]), {cols{i}}, 0);
			%% Apply the transformation
			value_vector = value_vector - delta_index;
			%% Add this vector to the new vector
			new_vector = [new_vector; value_vector];

		end
	
		matrix = [matrix(:, 1:col_index - 1) new_vector matrix(:, col_index + 1:matrix_size)];
		table = setd(table, matrix);
		ref_out{col_index} = refs{i};

		alias_out{col_index} = aliases{i};
	end

	out{1} = matrix;
	out{2} = table{2};
	%% Data have already been updated
	%% Column names are already copied
	%% Copy updated reference and aliases
	out{3} = alias_out;
	out{4} = ref_out;
end
