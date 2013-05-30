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
%	Function groupby
%
%	Separate rows of a table into groups within which the set of values in
%	given columns are identical in every row, but different between rows of
%	different groups. A group takes shape of a subset data of the whole
%	table's data. Each row of the original table is mapped to exactly one
%	group. All groups are then be reduced column by colum using functions 
%	given in func parameter (at most one function per column), to as many
%	rows as the maximum amount of values all functions output. If a column
%	is not given a reduction function, then its first value in the group is
%	used and other are discarded (apply the function @all to keep all
%	lines); it is repeated until it fits the final group size. All rows
%	produced by each column are combined with other columns in a cross-
%	product manner. If several column reduction result in several lines
%	then the output group size grow in a factorial manner, use this
%	feature with caution. Rows within a group keep the same order as they
%	had in the input table, but they stay grouped. The function may shuffle
%	columns ordering.
%	
%	Parameters:
%	table:	Table to be separated separate into groups (matrix)
%	colg:	Column names taken into account when forming
%		groups (cell of strings).
%	apply:	Column names on which to apply a function (cell of strings).
%	func:	Functions to apply to previously mentioned columns. This function
%		should take a vector as input and output a scalar; @mean and @std
%		are suitable. Note that columns that do not appear in col or apply
%		parameters are undefined and can be removed (cell of function
%		pointers). @first and @all respectively return the first row in a
%		group and all rows of the group.
%	out:	The table so transformed (table)
%
%	Example:
%	a = {
%	      [1,1] =
%		1 1 3 4 8
%		1 1 5 6 3
%		2 3 3 9 7
%		2 3 5 5 6
%		1 2 7 7 2
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%		col5
%	}
%	b = groupby(a, {'col1' 'col2'}, {'col3' 'col4'}, {@mean, @returns_2_rows_of_constant_values_x_and_y})
%	b = {
%	      [1,1] =
%		1 1 4 x 8
%		1 1 4 y 8
%		1 2 7 x 2
%		1 2 7 y 2
%		2 3 4 x 7
%		2 3 4 y 7
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%		col5
%	}

function out = groupby(table, colg, apply, func, def)

colg_size = size(colg);
colg_size = colg_size(2);

for i=1:colg_size
	col(i) = cellfindstr(table{2}, colg{i});
	if col(i) < 1
		error(['Could not find column ''' colg{i} ''' in table.']);
	end
end

matrix = table{1};
nb_col = size(col);
nb_col = nb_col(2);

% Warm-up
old_size = 1;
old_recipient = {matrix};

for i = 1:nb_col
	new_recipient = {[]};
	new_size = 0;

	for j = 1:old_size
		% sort the matrix regarding the current column
		mat = sortrows(old_recipient{j}, col(1, i));

		% The matrix is copied from the old container to the new container
		% beginning with first line
		new_size = new_size + 1;
		new_recipient{new_size}(1, :) = mat(1, :);
		new_mat_size = 2;

		% Browse the rest of the matrix and copy its rows in the new recipient
		size_mat = size(mat);
		size_mat = size_mat(1);
		key = mat(1, col(1, i));
		for k = 2:size_mat
			% If a new key has been found
			if mat(k, col(1, i)) ~= key
				new_size = new_size + 1; % increment the size of new_recipient
				new_mat_size = 1; % reset the new matrix' size
				
				% Update the key
				key = mat(k, col(1, i));
			end

			% Copy another matrix row into the new matrix
			new_recipient{new_size}(new_mat_size, :) = mat(k, :);
			new_mat_size = new_mat_size + 1;
		end
	end

	% Get ready for a new recursion step
	old_recipient = new_recipient;
	old_size = new_size;
end

cell_size = size(old_recipient);
cell_size = cell_size(2);

apply_size = size(apply);
apply_size = apply_size(2);

func_size = size(func);
func_size = func_size(2);

if apply_size != func_size
	error(['Number of columns to be reduced (' int2str(apply_size) ') doesn''t match number of functions provided (' int2str(func_size) ').']);
end

new_data = [];

for i = 1:cell_size
	# extract the group's key (denoted by colg parameter).
	group_key = [];
	for j = 1:colg_size
		index = cellfindstr(table{2}, colg{j});		
		group_key(1, j) = old_recipient{i}(1, index);
		table_name{1, j} = colg{j};
	end

	% Take all non-selected columns and add them to the basic group
	non_selected = except(coln(table), {colg{:} apply{:}});
	size_non_selected = size(non_selected);
	size_non_selected = size_non_selected(2);

	for j = 1:size_non_selected
		index = cellfindstr(table{2}, non_selected{j});
		group_key(1, colg_size + j) = old_recipient{i}(1, index);
	end

	# Apply function to the rest of data
	for j = 1:apply_size
		index = cellfindstr(table{2}, apply{j});
		if index < 1
			error(['Could not find column ''' apply{j} ''' in table.']);
		end

		new_col = func{j}(old_recipient{i}(:, index));
		new_col = new_col(:, 1);

		% Get number of rows in both group recomputer this far and the latest column
		new_col_size = size(new_col);
		new_col_size = new_col_size(1);
		group_size = size(group_key);
		group_size = group_size(1);

		gap = group_size / new_col_size;
		% Either the group or the new column needs padding
		if gap != 1
			padding = [];
			for k = 2:new_col_size
				padding = [padding; group_key];
			end
			group_key = [group_key; padding];

			padding = [];
			for l = 1:new_col_size
				for k = 1:group_size
					padding = [padding; new_col(l, :)];
				end
			end
			new_col = padding;
		end
		group_key = [group_key new_col];
	end

	new_data = [new_data; group_key];
end

% Add non-selected and apply column names 
table_name = {table_name{:} non_selected{:} apply{:}};

% Wrap everything up in a cell
out = {new_data, table_name};

return

% now old_recipient holds separated data into groups, let's reduce it into as much lines
size_grp = size(old_recipient);
size_grp = size_grp(2);

colg_size = size(colg);
colg_size = colg_size(2);

apply_size = size(apply);
apply_size = apply_size(2);

out_col = {colg{:} apply{:}};

for i = 1:size_grp
	for j = 1:colg_size
		index = cellfindstr(table{2}, colg{j});
		line(1, j) = old_recipient{i}(1, index);
	end
	for j = 1:apply_size
		index = cellfindstr(table{2}, apply{j});
		if index < 1
			error(['Could not find column ''' apply{i} ''' in table.']);
		end
		line(1, j + colg_size) = func{j}(old_recipient{i}(:, index));
	end
	data(i, :) = line;
end

out{1} = data;
out{2} = out_col;

end
