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
%	Function check
%
%	makes sure the input table is consistent. A consistent table has as many
%	dolumns as column names and column value aliases. If an inconsistency
%	is detected, then the function issues an error message and interrupts
%	the execution flow.
%	
%	
%	Parameters:
%	table:	The matrix to be filtered (table)
%	return:	1 if the table is correct, 0 otherwise.

function y = check(table)
	data = table{1};
	data = size(data);
	data = data(2);

	columns = table{2};
	columns = size(columns);
	columns = columns(2);

	alias = table{3};
	alias = size(alias);
	alias = alias(2);

	ref = table{4};
	ref = size(ref);
	ref = ref(2);

	if data != columns || data != alias || data != ref || columns != alias || columns != ref || alias != ref
		error(['Table format inconsistency: ' int2str(data) ' columns, ' int2str(columns) ' column names, ' int2str(alias) ' column value aliases and ' int2str(ref) ' value references. They should all be equal']);
		y = 0;
	end
	
	y = 1;
end
