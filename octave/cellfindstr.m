%    Copyright 2013 Nicolas Melot
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
%	Function cellfindstr
%
%	Find a string in a unidimensional cell of strings and returns index
%	of any matching string. Warning: Only search in the cell's first
%	line. Behavior is undefined if several matching string exist in the
%	list. If no matcing string could be found, return 0.
%	
%	Parameters:
%	cell:	Cell of strings containing the string looked for (cell of
%		strings).
%	str:	String to find in the list (string).
%	out:	Index of any matching string, if any; 0 otherwise (scalar)
%
%	Example:
%	a = {'str1' 'str2'; 'str3' 'str4'}
%
%	b = cellfindstr(a, 'str1')
%	b = 1
%
%	b = cellfindstr(a, 'str2')
%	b = 2
%
%	b = cellfindstr(a, 'str3')
%	b = 0
%
%	a = {'str1' 'str2'}
%
%	b = cellfindstr(a, 'str3')
%	b = 0


function y = cellfindstr(cell, str)
	cell_size = size(cell);
	cell_size = cell_size(2);

	y = 0;
	for i = 1:cell_size
		if(strcmp(cell{1, i}, str) == 1)
			y = i;
		end
	end
end
