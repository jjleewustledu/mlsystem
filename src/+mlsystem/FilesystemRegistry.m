classdef FilesystemRegistry < handle
	%% FILESYSTEMREGISTRY is a singleton providing filesystem utilities	 
	%  Version $Revision: 2642 $ was created $Date: 2013-09-21 17:58:30 -0500 (Sat, 21 Sep 2013) $ by $Author: jjlee $,  
 	%  last modified $LastChangedDate: 2013-09-21 17:58:30 -0500 (Sat, 21 Sep 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/src/+mlfourd/trunk/FilesystemRegistry.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: FilesystemRegistry.m 2642 2013-09-21 22:58:30Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

    
    properties 
        noclobber = false
    end
    
    methods (Static)
        
        function this = instance(varargin)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            %  Usage:   obj = FilesystemRegistry.instance([qualifier, qualifier2, ...])
            %                                              e.g., 'initialize'
            persistent uniqueInstance
            
            for v = 1:length(varargin) %#ok<*FORFLG>
                if (strcmp(varargin{v}, 'initialize'))
                    uniqueInstance = []; 
                end
            end
            if (isempty(uniqueInstance))
                this = mlsystem.FilesystemRegistry;
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end % static instance
        
        function        cellToTextfile(cll, varargin)
            ip = inputParser;
            addRequired(ip, 'cll', @iscell);
            parse(ip, cll);
            
            cal = mlpatterns.CellArrayList;
            cal.add(ip.Results.cll);
            mlsystem.FilesystemRegistry.cellArrayListToTextfile(cal, varargin{:});
        end
        function        cellArrayListToTextfile(varargin)
            ip = inputParser;
            addRequired(ip, 'cal',       @(x) isa(x, 'mlpatterns.CellArrayList'));
            addRequired(ip, 'fqfn',      @ischar);
            addOptional(ip, 'perm', 'w', @ischar);
            parse(ip, varargin{:});
            
            iter = ip.Results.cal.createIterator;
            try
                fid = fopen(ip.Results.fqfn, ip.Results.perm);
                while (iter.hasNext)
                    fprintf(fid, '%s\n', char(iter.next));
                end
                fclose(fid);
            catch ME
                handexcept(ME);
            end
        end
        function pth  = composePath(pth, fld)
            
            %% COMPOSEPATH appends a path with a folder, dropping duplicate folder names
            %  Usage:  pth = FilesystemRegistry.composePath(pth, fld)
            import mlfsl.*;
            try
                assert(~lstrfind(pth, fld));
            catch ME
                handwarning(ME, 'composePath.pth->%s, fld->%s', pth, fld);
                indices = strfind(pth, fld);
                pth     = pth(1:indices(1)-1);
                fprintf('truncating pth to %s', pth);
            end
            pth = ensuredir(fullfile(pth, fld, ''));
        end % static composePath
        function s    = extractNestedFolders(pth, patt)
            %% EXTRACTNESTEDFOLDERS finds folders with string-pattern in the specified filesystem path
            %  and moves the folders to the path (flattens)
            %  Usage:  status = FilesystemRegistry.extractNestedFolders(path, string_pattern)
            
            s = 0;
            if (lstrfind(pth, patt))
                try
                    dlist = mlsystem.DirTool(fullfile(pth, '*', ''));
                    for d = 1:length(dlist.fqdns) %#ok<*FORFLG>
                        [s,msg,mid] = movefile(dlist.fqdns{d}, fullfile(pth, '..', ''));
                    end
                catch ME
                    handexcept(ME, msg, mid);
                end
            end
        end % static extractNestedFolders
        function cwd  = scd(targetfold)
            
            %% SCD is a static wrapper to Matlab's cd.  
            %  It makes targetfold as needed, handles exceptions as needed and displays messages to console
            %  Usage:  cwd = FilesystemRegistry.cd(targetfold)
            try
                targetfold = ensuredir(targetfold);
                try
                    cwd = cd(targetfold); %#ok<MCCD>
                    warning('mlsystem:IO', 'FilesystemRegistry.scd changed dir to %s\n', cwd);
                catch ME
                    handexcept(ME, 'FilesystemRegistry.scd failed to cd to %s\n', targetfold);
                end
            catch ME2
                handexcept(ME2, 'FilesystemRegistry.scd could not access %s from %s\n', targetfold, pwd);
            end
        end % static scd 
        function ca   = textfileToCell(fqfn, eol)  %#ok<INUSD>
            if (~exist('eol','var'))
                fget = @fgetl;
            else
                fget = @fgets;
            end
            ca = {[]};
            try
                fid = fopen(fqfn);
                i   = 1;
                while 1
                    tline = fget(fid);
                    if ~ischar(tline), break, end
                    ca{i} = tline;
                    i     = i + 1;
                end
                fclose(fid);
            catch ME
                handexcept(ME);
            end
            if (isempty(ca) || isempty(ca{1}))
                error('mlsystem:IOError', '%s was empty', fqfn);
            end
        end % static textfileToCell
        function cal  = textfileToCellArrayList(varargin)
            cal = mlpatterns.CellArrayList;
            cal.add( ...
                mlsystem.FilesystemRegistry.textfileToCell(varargin{:}));
        end
        function tf   = textfileStrcmp(fqfn, str)
            ca = mlsystem.FilesystemRegistry.textfileToCell(fqfn, true);
            castr = '';
            for c = 1:length(ca)
                castr = [castr ca{c}]; %#ok<AGROW>
            end
            tf = strcmp(strtrim(castr), strtrim(str));
        end        
    end
    
	methods (Access = 'private')
 		% N.B. (Static, Abstract, Access=', Hidden, Sealed) 

 		function this = FilesystemRegistry() 
 			%% FILESYSTEMREGISTRY (ctor) is private to enforce instantiation through instance 
 		end % FilesystemRegistry (ctor) 
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
 end 
