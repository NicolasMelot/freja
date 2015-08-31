

%
% =========================================================================
%
%	Function duplicate
%
%	Duplicate or create once or more, one or several columns of a given table
%	as well as their alias values
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
%		1 2 0 4
%		5 6 1 8
%
%	      [1,2] =
%		col1
%		col2
%		col3
%		col4
%
%             [1,3] = {{}(0x0) {}(0x0) {'label zero' 'label one'} {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {'zero' 'one'} {}(0x0)}
%	}
%	b = duplicate(a, {'col3' 'col4' 'col4' 'col_none'}, {'col3b', 'col4b', 'col4c', 'new_col'}, 9)
%	b = {
%	      [1,1] =
%		1 2 0 4 0 4 4 9
%		5 6 1 8 1 8 8 9
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
%
%             [1,3] = {{}(0x0) {}(0x0) {'label zero' 'label one'} {}(0x0)} {'label zero' 'label one'} {}(0x0) {}(0x0) {}(0x0)}
%             [1,4] = {{}(0x0) {}(0x0) {'zero' 'one'} {}(0x0)} {'zero' 'one'} {}(0x0) {}(0x0) {}(0x0)}
%	} 

function out = duplicate(table, src, names, def)
	check(table);

	src_size = size(src);
	src_size = src_size(2);

	data = table{1};
	tbl_size = size(data);
	tbl_size = tbl_size(2);
	col = table{2};
	aliases = table{3};
	refs = table{4};

	for i = 1:src_size
		index = cellfindstr(table{2}, src{i});
		tbl_size += 1;
		if index > 0
			data(:, tbl_size) = data(:, index);
			aliases{tbl_size} = table{3}{index};
			refs{tbl_size} = table{4}{index};
		else
			data_size = size(data(:, 1));
			data_size = data_size(1);
			data(:, tbl_size) = ones(data_size, 1) .* def;
			aliases{tbl_size} = {};
			refs{tbl_size} = {};
		end
		col{tbl_size} = names{i};
	end

	out{1} = data;
	out{2} = col;
	out{3} = aliases;
	out{4} = refs;
end

