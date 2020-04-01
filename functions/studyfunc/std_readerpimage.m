% std_readerpimage()  - load ERPimage measures for data channels or 
%                       for all components of a specified cluster.
% Usage:
%   >> [STUDY, erpimagedata, times, trials, events] = std_readerpimage(STUDY, ALLEEG, varargin);
%
% Note: this function is a helper function that contains a call to the 
% std_readersp function that reads all 2-D data matrices for EEGLAB STUDY.
% See the std_readersp help message for more information.
%
% Author: Arnaud Delorme, CERCO, 2006-

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, October 11, 2004, arno@sccn.ucsd.edu
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

function [STUDY, erspdata, alltimes, allfreqs, events] = std_readerpimage(STUDY, ALLEEG, varargin);

disp('This function is obsolete and only partially backward compatible use std_readdata instead');
[STUDY, erspdata, alltimes, allfreqs, events] = std_readdata(STUDY, ALLEEG, 'datatype', 'erpim', varargin{:});