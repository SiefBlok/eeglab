% newtimefbaseln() - Remove baseline power values for newtimef. This
%                    function assumes absolute power NOT log transformed power.
%                    This function only removes baseline. Data has to be
%                    averaged subsequently if necessary. This function
%                    works both for single trial data and for average data.
%
% Usage:
%   >>  [P,basesamples,basevals] = newtimefbaseln(P, tvals, baseline, 'key', val);
%
% Inputs:
%   P        - [3-D or 4-D array] Power array [freqs x times x trials] or
%              [channels x freqs x times x trials
%   tvals    - [array] time values
%   baseline - [] same format as for newtimef
%
% Optional inputs: 'powbase', 'basenorm', 'commonbase', 'verbose'
%                  and 'trialbase'. Same definition as for newtimef.
%
% Outputs:
%   P        - Baseline correct power (same size as input)
%   baseln   - Baseline sample time indices
%   mbase    - Baseline value
%
% Authors: Arnaud Delorme, SCCN, INC, UCSD, August 2016

% Copyright (C) Arnaud Delorme, SCCN, INC, UCSD, 2016, arno@sccn.ucsd.edu
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

function [PP, baseln, mbase] = newtimefbaseln(PPori, timesout, varargin)

if nargin < 3
    help newtimefbaseln;
    return;
end

[ g timefreqopts ] = finputcheck(varargin, ...
    {'powbase'       'real'      []          NaN;
    'basenorm'      'string'    {'on','off'} 'off';
    'baseline'      'real'      []          0;
    'commonbase'    'string'    {'on','off'} 'off';
    'singletrials'  'string'    {'on','off'} 'on';
    'trialbase'     'string'    {'on','off','full'} 'off'; % 'on' skip the baseline
    'verbose'       'string'    {'on','off'} 'on';
    }, 'newtimefbaseln', 'ignore');
if ischar(g) error(g); return; end
PP = PPori; if ~iscell(PP), PP = { PP }; end

% ---------------
% baseline length
% ---------------
if size(g.baseline,2) == 2
    baseln = [];
    for index = 1:size(g.baseline,1)
        tmptime   = find(timesout >= g.baseline(index,1) & timesout <= g.baseline(index,2));
        baseln = union_bc(baseln, tmptime);
    end
    if length(baseln)==0
        error( [ 'There are no sample points found in the default baseline.' 10 ...
            'This may happen even though data time limits overlap with' 10 ...
            'the baseline period (because of the time-freq. window width).' 10 ...
            'Either disable the baseline, change the baseline limits.' ] );
    end
else
    if ~isempty(find(timesout < g.baseline))
         baseln = find(timesout < g.baseline); % subtract means of pre-0 (centered) windows
    else baseln = 1:length(timesout); % use all times as baseline
    end
end

allMbase = cell(size(PP));
allPmean = cell(size(PP));
for ind = 1:length(PP(:))
    
    P = PP{ind};
    
    % -----------------------
    % compute baseline values
    % -----------------------
    if isnan(g.powbase(1))
        verboseprintf(g.verbose, 'Computing the mean baseline spectrum\n');
        if strcmpi(g.singletrials, 'on') && strcmpi(g.trialbase, 'off')
            if ndims(P) == 4, Pmean  = mean(P, 4); % average power over trials (channels x freq x time x trials)
            else              Pmean  = mean(P, 3); % average power over trials (freq x time x trials)
            end
        else
            Pmean = P;
        end
        mbase = mean(Pmean(:,baseln,:,:),2);
        mstd  = std(Pmean(:,baseln,:,:),[],2);
    else
        verboseprintf(g.verbose, 'Using the input baseline spectrum\n');
        mbase    = g.powbase;
        mstd     = [];
        if size(mbase,1) == 1 % if input was a row vector, flip to be a column
            mbase = mbase';
        end
    end
    
    PP{ind}       = P;
    baselength    = length(baseln);
    allMbase{ind} = mbase;
    allMstd{ind}  = mstd;
end

% ------------------------
% compute average baseline
% ------------------------
if strcmpi(g.commonbase, 'on')
    meanBaseln = allMbase{1}/length(PP(:));
    meanStd    = allMstd{1}/length(PP(:));
    for ind = 2:length(PP(:))
        meanBaseln = meanBaseln + allMbase{ind}/length(PP(:));
        meanStd    = meanBaseln + allMstd{ ind}/length(PP(:));
    end
    for ind = 1:length(PP(:))
        allMbase{ind} = meanBaseln;
        allMstd{ind}  = meanBaseln;
    end
end

% -------------------------
% remove baseline (average)
% -------------------------
% original ERSP baseline removal
if ~strcmpi(g.trialbase, 'on') % full or off
    for ind = 1:length(PP(:))
        if ~isnan( g.baseline(1) ) && any(~isnan( allMbase{ind}(1) )) && strcmpi(g.basenorm, 'off')
            PP{ind} = bsxfun(@rdivide, PP{ind}, allMbase{ind}); % use single trials
            % ERSP baseline normalized
        elseif ~isnan( g.baseline(1) ) && ~isnan( allMbase{ind}(1) ) && strcmpi(g.basenorm, 'on')
            PP{ind} = bsxfun(@rdivide, bsxfun(@minus, PP{ind}, allMbase{ind}), allMstd{ind});
        end
    end
end
for ind = 1:length(allMbase(:))
    if ndims(allMbase{ind}) > 2
        % The baseline is only used for plotting purposes
        % It is different from version EEGLAB v14 (not to be used)
        allMbase{ind} = mean(allMbase{ind},3);
    end
end
mbase = allMbase;
if ~iscell(PPori)
    PP = PP{1}; 
    mbase = allMbase{1};
end

% print
function verboseprintf(verbose, varargin)
if strcmpi(verbose, 'on') fprintf(varargin{:}); end
