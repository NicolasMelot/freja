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
%	Function extend
%
%	Creates dummy rows in order to make every groups (defined in the same way
%	as the groupby function) to have as many rows as the biggest group. The
%	columns of these dummy rows take the value of the same column in the 
%	original rows if the column is part of the group definition or the value of
%	parameter value if they don't. The values of columns defined by the
%	parameter cpy are copied from the biggest group to all other extended
%	groups.
%	This function is useful to present data at value zero when they were non
%	existant or relevant in the original data. For instance, to show the
%	work of threads 3 and 4 where experiments only involved 2 threads in some
%	cases and 4 threads in other cases.
%	
%	
%	Parameters:
%	table:	Table whose groups need extensions (table)
%	group:	Columns to defining the group (cell of strings).
%	copy:	Columns to be copied from the biggest group to all other groups.
%		Be careful when choosing the columns to be copied, not to make it
%		to erase important data in smaller groups (cell of strings).
%	value:	The value to copy to all other columns (columns that do not 
%		define the groups or that are not copied from the biggest group
%		(scalar).
%	out:	The output matrix with all dummy rows added.
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
%	b = extend(a, {'col1'}, {'col2'}, 0)
%	b = {
%	      [1,1] =
%		1 1 3 4
%		1 2 7 8
%		1 1 5 6
%		1 2 7 7
%		2 1 3 9
%		2 2 5 5
%		2 1 0 0
%		2 2 0 0
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{}(0x0) {}(0x0) {}(0x0) {}(0x0)}
%	}

function out = extend(table, grp, cpy, value)
check(table);
% Compute inputs to older version signatures
% Gets data into matrix
matrix = table{1};
coln = table{2};

% Compute group indexes
size_grp = size(grp);
size_grp = size_grp(2);
for i = 1:size_grp
	index = cellfindstr(coln, grp{i});
	if index > 0
		group(i) = index;
	else
		error(['Could not find column ''' coln{i} ''' in table.']);
	end
end

% Compute copy indexes
size_cpy = size(cpy);
size_cpy = size_cpy(2);
for i = 1:size_cpy
	index = cellfindstr(coln, cpy{i});
	if index > 0
		copy(i) = index;
	else
		error(['Could not find column ''' coln{i} ''' in table.']);
	end
end

sep = separate(matrix, group);
max_size=0;
max_index=0;

maxi = size(sep);
maxi = maxi(2);

for i = 1:maxi
    size_sep = size(sep{i});
	if size_sep(1) > max_size
		max_size = size_sep(1);
		max_index = i;
	end
end

data=[];

for i = 1:maxi
    size_sep = size(sep{i});
	height = max_size - size_sep(1);
	width = size_sep(2);
	append = [sep{i}; zeros(height, width)];

    maxj = size(copy);
    maxj = maxj(2);
	for j = 1:maxj
		append(:, copy(j)) = sep{max_index}(1:max_size, copy(j));		
    end

    maxj = size(group);
    maxj = maxj(2);
	for j = 1:maxj
		append(:, group(j)) = sep{i}(1, group(j));
	end

	data = [data; append];
end

out{1} = data;
out{2} = coln;
out{3} = table{3};

end

function out = separate(matrix, col)
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

out = old_recipient;

end
