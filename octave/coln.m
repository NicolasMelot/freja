% This file is part of Freja.
% 
% Freja is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
% 
% Freja is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% 
% You should have received a copy of the GNU General Public License
% along with Freja. If not, see <http://www.gnu.org/licenses/>.
%




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
