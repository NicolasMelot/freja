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
% =============================================================================
%
%
%	Defines default settings (font size, legend location) for all plots
%	to be generated and defines special values for particular plots.
%	This is useful to arrange easily each plot with the layout constraint
%	their content brings. Each plot generates a file prefixed with
%	an integer that matches the index for each settings listed here.
%	
%	If you generate the same graphs with different data, then you can
%	duplicate this file and arrange settings to each data set.
%	
%
%

% First define the number of plots to be generated 
global plot_number = 4;

%% Default graph parameters
%% Seems like octave support for alternate hatch pattern is broken. Only '-' works
%global default_hatches = {'-' '--' ':' '-.' 'none' '-' '--' ':' '-.'};
global default_hatches = {'-' '-' '-' '-' '-' '-' '-' '-' '-'};
global default_hatch_pattern = {'swne' 'nwse' 'hrzt' 'vert' 'cross' 'swne' 'nwse' 'hrzt' 'vert'};
global default_hatch_colors = {[0 0 0] [0 0 1] [0 1 0] [0 1 1] [1 0 0] [1 0 1] [1 1 0] [1 1 1] [0 0 0]};
global default_hatch_thickness = 0.7;
global default_pattern_thickness = 2;
global default_pattern_space = 1;

global default_colors = {[1 0 0] [1 0 1] [0 0 1] [0 0 0] [0 0.5 0.5] [0 0.5 0] [0 0 0.5] [0.5 0 0.5] [0.5 0 0]};
global default_markers = {'o' '^' '.' 'x' '>' '<' 'v' '*'};
global default_thickness = 2;
global default_marker_size = 5;
global default_font = 'MgOpenModernaBold.ttf';
global default_font_size = 8;
global default_width = 800;
global default_height = 400;

global default_output_format = 'epsc';
global default_output_prefix = '';
global default_output_extension = 'eps';
global default_legend_location = 'northeast';
global default_legend_box = 0;

%% Declaration for default graph-specific parameters
global hatches;
global hatch_pattern;
global hatch_colors;
global hatch_thickness;
global pattern_thickness;
global pattern_space;

global colors;
global markers;
global thickness;
global marker_size;
global font;
global font_size;
global width;
global height;

global output_format;
global output_prefix;
global output_extension;
global legend_location;
global legend_box;

%% Generate settings for each plot to be generated
generate_settings

%% Give specific graphs a particular value
%% The Gantt chart (graph #4) is higher than other plots
height{4} = 600;

%% Now generate all plots
drawgraphs
