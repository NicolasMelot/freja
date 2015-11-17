% Copyright 2015 Nicolas Melot
%
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
%	Function setc
%
%	Replace the data matrix with the one provided
%	
%	
%	Parameters:
%	table:	The table where to store the data (table).
%	coln:	New names to give to columns (cell of strings).
%	out:	The table from merged data (table).
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
%	cols = {'colA' 'colB' 'colC' 'colD'}
%	b = setc(a, coln)
%	b = {
%	      [1,1] =
%		7 7 8 2
%		4 5 3 2
%
%	      [1,2] =
%		colA
%		colB
%		colC
%		colD
%	}

function out = setc(table, coln)
	check(table);
	sizem = size(table{1});
	sizem = sizem(2);
	sizec = size(coln);
	sizec = sizec(2);

	if sizem != sizec
		error(['Column name collection size (' int2str(sizec) ') incompatible with matrix line size (' int2str(sizem) ').']);
	end

	out{1} = table{1};
	out{2} = coln;
	out{3} = table{3};
	out{4} = table{4};
end






