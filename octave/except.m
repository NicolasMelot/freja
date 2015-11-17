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
%	Function except
%
%	Returns all column names of a name list, except columns givens as argument
%	
%	
%	Parameters:
%	coln:	The matrix to be filtered (cell of string)
%	except:	All column names to exclude from the original list
%		(cell of strings).
%	out:	Original column names minus excluded ones (cell of string)
%
%	Example:
%	a = {'col1' 'col2' 'col3' 'col4'}
%	b = except(a, {'col3'})
%	b = {'col1' 'col2' 'col4'}

function out = except(coln, except)
	sizec = size(coln);
	sizec = sizec(2);

	sizee = size(except);
	sizee = sizee(2);

	out = {};

	for i = 1:sizec
		ok = 1;
		for j = 1:sizee
			ok = ok && !strcmp(coln{i}, except{j});
		end

		if ok
			out = {out{:} coln{i}};
		end
	end
end
