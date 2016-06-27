function res = getTrackingResults(self,timeRange,dagif,forceif)
% RES = GETTRACKINGRESULTS(TIMERANGE,DAGIF,FORCEIF) returns the current
% results. FORCIF==1 forces a re-generation of the pos/res
% structure. DAGIF==0 uses the switch-based tracks, otherwise the
% DAG-based tracks
  
  if isempty(self.res) || (exist('forceif','var') && ~isempty(forceif) && forceif)
    generateResults(self); % maybe not done yet
  end

  if ~exist('dagif','var') || isempty(dagif)
    dagif = self.getDefaultResultType();
  end
  
  if isempty(self.res)
    error('No results available. First track()...');
  else
    if dagif 
      fish.helper.verbose('Getting DAGraph tracking results')
      res = self.res.dag;
    else
      fish.helper.verbose('Getting Switch-based tracking results')
      res = self.res.swb;
    end
  end

  if exist('timeRange','var') && ~isempty(timeRange)
    n = length(res.tabs);
    idx = find(res.tabs>=timeRange(1) & res.tabs<timeRange(2));
    S.type = '()';
    for f = fieldnames(res)'
      sz= size(res.(f{1}));
      if sz(1)==n
        S.subs = cell(1,length(sz));
        [S.subs{:}] = deal(':');
        S.subs{1} = idx;
        res.(f{1}) = subsref(res.(f{1}),S);
      end
    end
    for f = fieldnames(res.tracks)'
      sz= size(res.tracks.(f{1}));
      if sz(1)==n
        S.subs = cell(1,length(sz));
        [S.subs{:}] = deal(':');
        S.subs{1} = idx;
        res.tracks.(f{1}) = subsref(res.tracks.(f{1}),S);
      end
    end
  end
end

