

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
global default_bar_thickness = 0.5;
global default_style = 'grouped';
global default_marker_size = 5;
global default_font = 'MgOpenModernaBold.ttf';
global default_font_size = 8;
global default_width = 800;
global default_height = 400;
global default_scale = 0;
global default_group = 0;
global default_labels_angle = 0;

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
global bar_thickness;
global style;
global marker_size;
global font;
global font_size;
global width;
global height;
global scale;
global group;
global labels_angle;

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

legend_location(3) = 'eastoutside';
scale(3) = 0.2;
width(3) = 1000;
height(3) = 1000;

%% Now generate all plots
drawplots
