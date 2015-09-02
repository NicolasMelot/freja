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




%
% =========================================================================
%
%	Function export
%
%	Exports a table into a matlab-executable .m text file
%	
%	
%	Parameters:
%	table:	Table to export (table)
%	file:	Filename of the file to export the table to (string).
%	value:	The value to copy to all other columns (columns that do not 
%		define the groups or that are not copied from the biggest group
%		(scalar).
%	out:	Always 0.
%
%	Example:
%	export(table, '/tmp/table.m')

function out = export(table, file)
check(table);

allcols = coln(table);
size_cols = size(allcols);
size_cols = size_cols(2);
format='';
for i = 1:size_cols
	format=[format '%g '];
end

fileID = fopen(file,'w');
fprintf(fileID, 'function x = table()\nx = {[\n');
fprintf(fileID, [format '\n'], data(table, {''}, 0)');
fprintf(fileID, '] table_columns() table_symb() table_ref()};\nend\n\nfunction x = table_columns()\nx = {');
for i = coln(table)
	fprintf(fileID, ['''' i{} ''' ']);
end
fprintf(fileID, '};\nend\n\nfunction x = table_symb()\nx = {\n');
for i = alias(table, {''})
	fprintf(fileID, '{');
	for j = i{}
		if j{} != ''''
			fprintf(fileID, ['''' j{} ''' ']);
		else
			fprintf(fileID, ''''''''' ');
		end
	end
	fprintf(fileID, '} ');
end
fprintf(fileID, '};\nend\n\nfunction x = table_ref()\nx = {\n');
for i = ref(table, {''})
	fprintf(fileID, '{');
	for j = i{}
		fprintf(fileID, ['''' j{} ''' ']);
	end
	fprintf(fileID, '} ');
end
fprintf(fileID, '};\nend\n');
fclose(fileID);

out = 0;
end
