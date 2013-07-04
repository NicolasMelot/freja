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
	out = select(table, col, def);
	out = out{1};
end

