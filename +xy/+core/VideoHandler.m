classdef VideoHandler < handle & xy.core.VideoReader & xy.core.BlobAnalysis
%FISHVIDEOHANDER  wrapper class
%
% Class for video reading of the xy.Tracker
%
%
  
  properties
    computeSegments = true;
    resizeif = 0; % 
    resizescale = 1; 
    knnMethod = true;
    fixedSize = 0;  % NOT SUPORTED WITHOUT MEX
    difffeature = false; % no supported
  end
  
  
  properties (SetAccess = private)
    detector;
    bwmsk = [];
  end
  
  properties (Dependent)
    history
  end

  methods
    
    function self = VideoHandler(vidname,timerange,knnMethod,opts)
    %VIDEOCAPTURE  Create a new VideoHandler object
    %
      if iscell(vidname)
        error('Capture not supported');
        vidname = vidname{1}; % capture device might be suported by
                              % open cv
      end

      self@xy.core.BlobAnalysis(opts); 
      self@xy.core.VideoReader(vidname,timerange); 

      if exist('knnMethod','var') && ~isempty(knnMethod)
        self.knnMethod = knnMethod;
      end

      if self.knnMethod
        self.detector = xy.core.ForegroundDetector();  
      else
        self.detector = xy.core.ForegroundDetectorMatlabCV();  
      end

      if self.knnMethod 
        xy.helper.verbose('Using KNN for foreground subtraction...');
      else
        xy.helper.verbose('Using Thresholder for foreground subtraction...');
      end

      if exist('opts','var')
        self.setOpts(opts);
      end
      
    end
    
    function bool = isGrabbing(self);
      bool = false ; % not supported;
    end
    
    function bwmsk = getCurrentBWImg(self);
      bwmsk = self.bwmsk;
    end
    
    function frame = getCurrentFrame(self);
      frame = getCurrentFrame@xy.core.VideoReader(self);
      if self.resizeif
        frame = cv.resize(frame,self.resizescale);
      end
    end
    
    
    function self = setOpts(self,opts)
    % to set the OPTIONS use the keywords "blob" "reader" and "detector"
      setif = 0;
      if isfield(opts,'blob')
        for f = fieldnames(opts.blob)'
          if isprop(self,f{1})
            self.(f{1}) = opts.blob.(f{1});
            setif = 1;
            xy.helper.verbose('Set BLOB option "%s" to "%s"',f{1},num2str(opts.blob.(f{1})));
          end
        end
      end
      
      if isfield(opts,'reader')
        for f = fieldnames(opts.reader)'
          if strcmp(f{1},'knnMethod')
            continue;
          end
          
          if isprop(self,f{1})
            self.(f{1}) = opts.reader.(f{1});
            setif = 1;
            xy.helper.verbose('Set READER option "%s" to "%s"',f{1},num2str(opts.reader.(f{1})));
          end
        end
      end

      if isfield(opts,'detector')
        for f = fieldnames(opts.detector)'
          if isprop(self.detector,f{1})
            self.detector.(f{1}) = opts.detector.(f{1});
            setif = 1;
            xy.helper.verbose('Set DETECTOR option "%s" to "%s"',f{1},num2str(opts.detector.(f{1})));
          end
        end
      end
      
      if ~setif
        xy.helper.verbose('WARNING: Nothing set in VideoHandler');
      end

      self.frameFormat = [self.grayFormat,self.detector.expectedFrameFormat];
    end

    
    function [segm,timeStamp,frame,varargout] = step(self)
    % STEP one frame
    %
    % [segments,timeStamp [frame]] = vh.step();
    %
    %

      if nargout>3 || self.colorfeature
        self.originalif = true; 
        [frame,oframe] = self.readFrame();            
        if self.resizeif
          oframe = cv.resize(oframe,self.resizescale);
          frame = cv.resize(frame,self.resizescale);
        end
        varargout{1} = oframe;
      else
        self.originalif = false;
        frame = self.readFrame();
        if self.resizeif
          frame = cv.resize(frame,self.resizescale);
        end

        oframe = frame;
      end
      timeStamp = self.currentTime;

      bwmsk = self.detector.step(frame);
      self.bwmsk = bwmsk;
      
      if self.computeSegments
        segm = self.stepBlob(bwmsk,frame,oframe);
      else
        segm = [];
      end
      
    end        

    %% detector methods
    function set.history(self,value)
      self.detector.history = value;
    end
    function value = get.history(self)
      value = self.detector.history;
    end
    
    function resetBkg(self)
      self.detector.reset();
    end
    
    function plotting(self,bool);
    % plotting not implemented...
    end
    
  end

  methods(Access=protected)
    
    function frameSize= a_getFrameSize(self);
      frameSize = a_getFrameSize@xy.core.VideoReader(self);
      if self.resizeif
        frameSize = round(self.resizescale*frameSize);
      end
    end

  end
end
