

%
% =========================================================================
%
%	Function data
%
%	Extract one or several data columns from a table
%	
%	
%	Parameters:
%	table:	The table containing data (table)
%	col:	Columns to be extracted from the table (cell of strings)
%	def:	Default value if a was not found (scalar)
%	out:	Output data matrix. Cannot be used in analysis functions
%		(matrix).

function out = data(table, col, def)
	check(table);
	out = select(table, col, def);
	out = out{1};
end

