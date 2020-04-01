% textgui() - make sliding vertical window. This window contain text
%             with optional function calls at each line.
%
% Usage:
%   >> textgui( commandnames, helparray, 'key', 'val' ...);
%
% Inputs:
%   commandnames - name of the commands. Either char array or cell
%                  array of char. All style are 'pushbuttons' exept
%                  for empty commands.
%   helparray    - cell array of commands to execute for each menu
%                  (default is empty)  
%
% Optional inputs:
%  'title'        - window title
%  'fontweight'   - font weight. Single value or cell array of value for each line.
%  'fontsize'     - font size. Single value or cell array of value for each line.
%  'fontname'     - font name. Single value or cell array of value for each line.
%  'linesperpage' - number of line per page. Default is 20.
% 
% Author: Arnaud Delorme, CNL / Salk Institute, 2001
%
% Example:
%  textgui({ 'function1' 'function2' }, {'hthelp(''function1'')' []});
%  % this function will call a pop_up window with one button on 
%  % 'function1' which will call the help of this function. 
%

% Copyright (C) 2001 Arnaud Delorme, Salk Institute, arno@salk.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function tmp = textgui( textmenu, helparray, varargin);

XBORDERS   = 0; % pixels
TOPORDINATE = 1.09;
TOPLINES    = 2;

if nargin < 1
	help textgui;
	return;
end;	
if nargin <2
	helparray = cell(1, length(	textmenu ));
end

% optional parameters
% -------------------
if nargin >2
    for i = 1:length(varargin)
        if iscell(varargin{i}), varargin(i) = { varargin(i) }; end
    end;        
    g=struct(varargin{:});
else
    g = [];
end
try, g.title;    catch, g.title = ''; end;    
try, g.fontname; catch, g.fontname = 'courier'; end;    
try, g.fontsize; catch, g.fontsize = 12; end;    
try, g.fontweight; catch, g.fontweight = 'normal'; end;    
try, g.linesperpage; catch, g.linesperpage = 20; end;    

if isempty( helparray )
	helparray = cell(1,200);
else
	tmpcell = cell(1,200);
	helparray = { helparray{:} tmpcell{:} };
end

% number of elements
% ------------------
if iscell(textmenu)	nblines = length(textmenu);
else				nblines = size(textmenu,1);
end;	

% generating the main figure
% --------------------------
fig = figure('position', [100 100 800 25*15], 'menubar', 'none', 'numbertitle', 'off', 'name', 'Help', 'color', 'w');
pos = get(gca,'position'); % plot relative to current axes
q = [pos(1) pos(2) 0 0];
s = [pos(3) pos(4) pos(3) pos(4)]./100;

% generating cell arrays
% ----------------------
if ischar(g.fontname),     tmp1(1:nblines) = {g.fontname}; g.fontname = tmp1; end
if isnumeric(g.fontsize), tmp2(1:nblines) = {g.fontsize}; g.fontsize = tmp2; end
if ischar(g.fontweight),   tmp3(1:nblines) = {g.fontweight}; g.fontweight = tmp3; end
switch g.fontname{1}
    case 'courrier', CHAR_WIDTH = 11; % pixels
    case 'times', CHAR_WIDTH = 11; % pixels
    otherwise, CHAR_WIDTH = 11;
end

topordi = TOPORDINATE;
if ~isempty(g.title)
    addlines = size(g.title,1)+1+TOPLINES;
    if nblines+addlines < g.linesperpage 
        divider = g.linesperpage;
    else
        divider = nblines+addlines;
    end;    
    ordinate      = topordi-topordi*TOPLINES/divider;
    currentheight = topordi/divider;
    
    for index=1:size(g.title,1)
      ordinate      = topordi-topordi*(TOPLINES+index-1)/divider;
      h = text( -0.1, ordinate, g.title(index,:), 'unit', 'normalized', 'horizontalalignment', 'left', ...
		 'fontname', g.fontname{1}, 'fontsize', g.fontsize{1},'fontweight', fastif(index ==1, 'bold', ...
		  'normal'), 'interpreter', 'none' );
    end
    %h = uicontrol( gcf, 'unit', 'normalized', 'style', 'text', 'backgroundcolor', get(gcf, 'color'), 'horizontalalignment', 'left', ...
    %		'position', [-0.1 ordinate 1.1 currentheight].*s*100+q, 'string', g.title, ...
    %	       'fontsize', g.fontsize{1}+1, 'fontweight', 'bold', 'fontname', g.fontname{1});
 else
    addlines = TOPLINES;
    if nblines+addlines < g.linesperpage
        divider = g.linesperpage;
    else
        divider = nblines+addlines;
    end;    
end

maxlen = size(g.title,2);
for i=1:nblines
	if iscell(textmenu)	tmptext = textmenu{i};
	else			tmptext = textmenu(i,:);
	end
	ordinate      = topordi-topordi*(i-1+addlines)/divider;
	currentheight = topordi/divider;

	if isempty(helparray{i})
		h = text( -0.1, ordinate, tmptext, 'unit', 'normalized', 'horizontalalignment', 'left', ...
		 'fontname', g.fontname{i}, 'fontsize', g.fontsize{i},'fontweight', g.fontweight{i}, 'interpreter', 'none' );
%		h = uicontrol( gcf, 'unit', 'normalized', 'style', 'text', 'backgroundcolor', get(gcf, 'color'), 'horizontalalignment', 'left', ...
%			'position', [-0.1 ordinate 1.1 currentheight].*s*100+q, 'string', tmptext, 'fontname', g.fontname{i}, 'fontsize', g.fontsize{i},'fontweight', g.fontweight{i} );
	else
		h = text( -0.1, ordinate, tmptext, 'unit', 'normalized', 'color', 'b', 'horizontalalignment', 'left', ...
		 'fontname', g.fontname{i}, 'buttondownfcn', helparray{i}, 'fontsize', g.fontsize{i},'fontweight', g.fontweight{i}, 'interpreter', 'none' );
%		h = uicontrol( gcf,  'callback', helparray{i}, 'unit','normalized', 'style', 'pushbutton',  'horizontalalignment', 'left', ...
%			'position', [-0.1 ordinate 1.1 currentheight].*s*100+q, 'string', tmptext, 'fontname', g.fontname{i}, 'fontsize', g.fontsize{i},'fontweight', g.fontweight{i});
	end
	maxlen = max(maxlen, length(tmptext));
end
pos = get(gcf, 'position');
set(gcf, 'position', [pos(1:2) maxlen*CHAR_WIDTH+2*XBORDERS 400]);
% = findobj('parent', gcf);
%set(h, 'fontname', 'courier');

if nblines+addlines < g.linesperpage 
    zooming  = 1;
else
    zooming  = (nblines+addlines)/g.linesperpage;
end

slider(gcf, 0, 1, 1, zooming, 0);
axis off;
