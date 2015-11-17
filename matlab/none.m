

%
% =========================================================================
%
%	Function none
%
%	Returns the first value of the vector given in input. This function is
%	recommended when reducing columns that were considered when forming groups
%	using groupby(). Other functions normally equally suitable (such as @mean)
%	may generate a strange behavior due to rounding errors, invisible to debug
%	and thus hard to detect and fix.
%	
%	
%	Parameters:
%	vector:	The column to be reduced to one value (vector)
%	out:	The first element of the input vector (scalar)
%
%	Example:
%	a = [1; 2; 3; 4]
%	a = [
%		1 ;
%		2 ;
%		3 ;
%		4;
%	]
%	b = none(a)
%	b = 1

function y = none(vector)
	y = vector(1,1);
end
