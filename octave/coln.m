

%
% =========================================================================
%
%	Function coln
%
%	Extract all columns names from a table
%	
%	
%	Parameters:
%	table:	The table containing data (table)
%	out:	All names for columns in input table (cell of strings).
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
%	b = coln(a)
%	b = {
%		col1
%		col2
%		col3
%		col4
%	}

function out = coln(table)
	out = table{2};
end
