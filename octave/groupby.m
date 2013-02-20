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
%	group. All groups can then be reduced to one row then merged together
%	into a single matrix thanks to the function reduce(). The rows within a
%	group keep the same order as they had in the input matrix.
%	
%	
%	Parameters:
%	table:	Table to be separated separate into groups (matrix)
%	coln:	Column names taken into account when forming
%		groups (cell of strings).
%	apply:	Column names on which to apply a function (cell of strings).
%	func:	Functions to apply to previously mentioned columns. This function
%		should take a vector as input and output a scalar; @mean and @std
%		are suitable. Note that columns that do not appear in col or apply
%		parameters are undefined and can be removed (cell of function
%		pointers).
%	out:	The table so transformed (table)
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
%	b = groupby(a, {'col1' 'col2'}, {'col3'}, {@mean})
%	b = {
%	      [1,1] =
%		1 1 4 undef
%		1 2 7 undef
%		2 3 4 undef
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%	}

function out = groupby(table, coln, apply, func)

coln_size = size(coln);
coln_size = coln_size(2);

for i=1:coln_size
	col(i) = cellfindstr(table{2}, coln{i});
	if col(i) < 1
		error(['Could not find column ''' coln{i} ''' in table.']);
	end
end

matrix = table{1};
nb_col = size(col);
nb_col = nb_col(2);

% Warm-up
old_size = 1;
old_recipient = {matrix};

for i = 1:nb_col
	new_recipient = {};
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

% now old_recipient holds separated data into groups, let's reduce it into as much lines
size_grp = size(old_recipient);
size_grp = size_grp(2);

coln_size = size(coln);
coln_size = coln_size(2);

apply_size = size(apply);
apply_size = apply_size(2);

out_col = {coln{:} apply{:}};

for i = 1:size_grp
	for j = 1:coln_size
		index = cellfindstr(table{2}, coln{j});
		line(1, j) = old_recipient{i}(1, index);
	end
	for j = 1:apply_size
		index = cellfindstr(table{2}, apply{j});
		line(1, j + coln_size) = func{j}(old_recipient{i}(:, index));
	end
	data(i, :) = line;
end

out{1} = data;
out{2} = out_col;

end
