
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
%	Function alias
%
%	Extract aliases for values contained in columns given as input
%	
%	
%	Parameters:
%	table:	The table from where to read aliases (table).
%	cols:	Column from where to extract alises. An empty string denotes
%		all columns. A column selected twice or more duplicates the
%		aliases collection (cell of strings).
%		to be returned (list of strings).
%	out:	All aliases ordered as cols parameter (cell of cells of strings).
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
%		english
%		spanish
%		french
%		swedish
%
%             [1,3] = {{'zero' 'one'} {'zero' 'en' 'dos' 'tre'} {'un' 'deux' 'trois' 'quatre' 'cinq' 'six' 'sept'} {'en' 'tva' 'tre' 'fyra' 'fem' 'sex' 'sju' 'atta' 'nio'}}
%	}
%	b = alias(a, {'spanish' 'swedish'})
%	b = {
%             {'zero' 'en' 'dos' 'tre'} {'en' 'tva' 'tre' 'fyra' 'fem' 'sex' 'sju' 'atta' 'nio'}
%	}

function out = alias(table, cols)
	check(table);

	out = {};
	csize = size(cols);
	csize = csize(2);

	for i = 1:csize
		if strcmp(cols{i}, '')
			out = {out{:} table{3}{:}};
		else
			index = cellfindstr(coln(table), cols{i});
			if index > 0
				out = { out{:} table{3}{index} };
			end
		end
	end
end
