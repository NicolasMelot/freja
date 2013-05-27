%Copyright 2011 Nicolas Melot
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
%	Function request_name
%
%	Takes a cell of distinct columns names and a new column name candidate
%	and returns the name candidate after adequat transformation so no name
%	pairs are the same.
%	
%	
%	Parameters:
%	cnames:	All column names already existing (cell of strings).
%	req:	Requested name to insert in column name collection (string)
%	out:	Requested name, possibly modified (appended or updated suffix)
%		so it can be safely used as a unique column identifier in the
%		given already existing name collection.
%
%	Example:
%	a = {
%		col2
%		col4
%	}
%	b = request_name(a, 'col4')
%	b = 'col4_2'

function out = request_name(cnames, request)
	cnames_size = size(cnames);
	cnames_size = cnames_size(2);

	% By default, get what you asked for
	out = request;

	max_num = 2;
	for i = 1:cnames_size
		name = cnames{i};
		refname = regexp(request, '^((\w*)_[0-9]+|(\w*))$', 'tokens');
		refname = refname{1, 1};
		refname = refname{1, 2};
		[match num] = regexp(name, ['^' refname '(?:_([0-9]+))?$'], 'start', 'tokens');
	
		if prod(size(match)) > 0
			% Found a match
			num = num{1};
			if prod(size(num)) > 0
				% found a suffix number
				num = str2num(num{1});
				num = num + 1;
				max_num = max(num, max_num);
			end
			
			out = [refname '_' int2str(max_num)];
		end
	end
end
