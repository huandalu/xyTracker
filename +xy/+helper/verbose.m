function verbose(str,varargin)

  global VERBOSELEVEL
  global VERBOSEDIARY  

  
  if ~VERBOSELEVEL
    return
  end

  if any(VERBOSEDIARY)
    if ischar(VERBOSEDIARY)
      fid = fopen(VERBOSEDIARY,'a+');
    end
  else
    fid = 1;
  end
  
  
  nostack = 0;
  
  if str(1)=='0'
   str = str(2:end);
   nostack = 1;
  end

  if isempty(findstr(str,'\r'))
    str = [str  '\n']; % return;
  end

  if fid~=1
    str(findstr(str,'\r')+1) = 'n';
  end
  
  
  d = dbstack;
  if length(d)==1 || nostack
    fprintf(fid,['[%s]:  ' str ],datestr(now),varargin{:});
  else
    fprintf(fid,['[%s,%s]:  ' str],datestr(now),d(2).name,varargin{:});
  end
  
  if any(VERBOSEDIARY)
    fclose(fid);
  end
  