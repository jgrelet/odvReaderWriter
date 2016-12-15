classdef odvReader < containers.Map
  %ODVREADER extract data from ODV spreadsheet ascii file
  % odvReader inherit from containers.Map (hashTable class)
  % example:
  % ctd = odvReader('files\OUTPACE_CTD.txt',true);
  % nh4 = odvReader('files\NH4.txt',false);
  % ...
  % get keys and values:
  % keys = keys(ctd)
  % values = values(ctd)
  % value = ctd('theKey')
  %
  % iterate over each key and get the value
  % for k = keys(nh4), nh4(char(k)),end
  %
  % J. Grelet IRD US191 IMAGO - 2016
  
  properties % public
    fileName
    finalHeader
    % true (default): keep header all data
    % false : get only data
    keepHeader = 1;
    columns
  end
  
  properties( Access = private)
    fid   %file identifier
    defaultHeader = '%s %s %s %s %f %f %f %f';
    start
    %lengthData
  end
  
  methods % public
    
    % Constructor with file name and logical
    % --------------------------------------
    function self = odvReader(fileName, varargin)
      
      % pre initialization - select filename
      if nargin < 1 || isempty(fileName)
        [fileName, pathName] = uigetfile({'*.txt','ODV (*.txt)'},'Select file');
        
        if isempty(fileName)
          error(message('MATLAB:odvReader:Empty fileName'));
        else
          fileName = fullfile(pathName, fileName);
        end
      end
      % call containers.Map constructeur
      self@containers.Map('KeyType', 'char', 'ValueType', 'any');
      % check arguments type
      if ~ischar(fileName)
        error(message('MATLAB:odvReader:Invalid fileName'));
      end
      if nargin > 1 && ~islogical(varargin{1})
        error(message('MATLAB:odvReader:Invalid logical'));
      end
      if nargin > 1 && ~varargin{1}
        self.keepHeader = varargin{1};
      end
      % post initialization
      self.fileName = fileName;
      % read data and fill map
      %self.read;
      
    end % end of constructor
    
    % read data in file and fill containers.Map
    % -----------------------------------------
    function  self = read(self)
      
      fprintf(1, 'read file: %s\n', self.fileName);
      self.fid = fopen(self.fileName);  % open file to read
      fseek(self.fid,0,-1);             % set read position to beginning of file
      
      [self.finalHeader,self.columns] = self.skipHeader('^//');
      data = textscan(self.fid,[self.defaultHeader, ...
        repmat(' %f', 1, self.columns)] ,'Delimiter','\t');
      fclose(self.fid);
      % convert data to ISO8601 format
      if self.keepHeader
        data{4} = datestr(datenum(data{4},'dd/mm/yyyy HH:MM'),'yyyy-mm-ddTHH:MM:SS');
        % Convert to cell array of character
        data{4} = cellstr(data{4});
      end
      
      % loop over all samples
      buf = [];
      for i = 1 : length(data{1})
        % build composit key, ex: key = "out_c_213:SD15:23"
        key = sprintf('%s:%s:%02d',data{1,2}{i}, data{1,3}{i}, data{1,8}(i));
        % construct data line
        for j = self.start : size(data,2)
          if iscell(data{1,j})
            value = data{1,j}{i};
          else
            value = data{1,j}(i);
          end
          if isnumeric(value)
            if isnan(value)
              % missing value as tabulation (ascii code 9), works only
              % with sprintf
              value = sprintf('\t');
            else
              value = sprintf('%s\t', num2str(value));
            end
          else
            value = sprintf('%s\t', value);
          end
          buf = sprintf('%s%s', buf, value);
        end
        % fill map, see:
        % http://fr.mathworks.com/matlabcentral/newsreader/view_thread/250895
        S = substruct('()', key);
        self = subsasgn(self, S, buf);
        buf = [];
      end
      
    end % end of readODVFile
    
    % display object
    % --------------
    function disp(self)
      
      % display public properties
      % -------------------------
      fprintf('    FileName:  ''%s''\n', self.fileName);
      fprintf(' FinalHeader:  ''%s''\n', self.finalHeader);
      fprintf('     Columns:   %d\n',    self.columns);
      fprintf('\n');
      
      % call base class display
      % -----------------------
      disp@containers.Map(self)
      
      % diplay methods list in hypertext link
      % -------------------------------------
      disp('list of <a href="matlab:methods(''odvReader'')">methods</a>');
    end
    
  end % end of public methods
  
  methods( Access = private)
    
    % skip ODV header and return
    % --------------------------
    function [finalHeader,columns] = skipHeader(self, motif)
      
      while true
        str = fgetl(self.fid);
        % skip comments
        match = regexp(str, motif, 'ONCE');
        % leave the loop at the first header line
        if isempty(match)
          break
        end
      end
      % read parameters from header line
      hdr = regexp( str, '\t', 'split');
      columns = length(hdr) - length(split(self.defaultHeader));
      if self.keepHeader
        self.start = 1;
      else
        self.start = length(split(self.defaultHeader)) + 1;
      end
      % keep or remove header columns of data
      finalHeader = [];
      for j = self.start : length(hdr)
        tmp = sprintf('%s\t', hdr{j});
        if strfind(tmp,'Date')
          tmp = sprintf('%s\t', 'yyyy-mm-ddThh:mm:ss'); % ISO8601
        end
        finalHeader = sprintf('%s%s',finalHeader, tmp);
      end
    end % end of skipHeader
    
  end % end of private methods
  
end % end of readOdv class




