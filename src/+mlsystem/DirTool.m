classdef DirTool
	%% DIRTOOL extends functionality of dir.
    %  See also:  dir
    
    %  Version $Revision: 2467 $ was created $Date: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ by $Author: jjlee $,
 	%  last modified $LastChangedDate: 2013-08-10 21:27:41 -0500 (Sat, 10 Aug 2013) $ and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlsystem/src/+mlsystem/trunk/DirTool.m $ 
 	%  Developed on Matlab 7.13.0.564 (R2011b) 
 	%  $Id: DirTool.m 2467 2013-08-11 02:27:41Z jjlee $ 
 	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
        itsPath
        itsListing
    end
    
    methods %% GET
        function pth = get.itsPath(this)
            pth = this.itsPath_;
        end
        function lst = get.itsListing(this)
            lst = this.itsListing_;
        end
    end

    methods (Static)
        
        % filesystem methods
        function [S,R] = rm(ca, flags)
            import mlsystem.*;
            if (~exist('flags','var'));    flags  = ''; end
            if (DirTool.hasflags__(ca)); [ca,flags] = DirTool.swap__(ca, flags); end     
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['rm ' flags ' ' x]),          ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
        function [S,R] = cp(ca, dest, flags)
            import mlsystem.*;    
            if (~exist('flags','var'));        flags  = ''; end        
            if (DirTool.hasflags__(ca));   [ca,  flags] = DirTool.swap__(ca,   flags); end  
            if (DirTool.hasflags__(dest)); [dest,flags] = DirTool.swap__(dest, flags); end 
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['cp ' flags ' ' x ' ' dest]), ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
        function [S,R] = mv(ca, dest, flags)
            import mlsystem.*;
            if (~exist('flags','var'));        flags  = ''; end
            if (DirTool.hasflags__(ca));   [ca,  flags] = DirTool.swap__(ca,   flags); end  
            if (DirTool.hasflags__(dest)); [dest,flags] = DirTool.swap__(dest, flags); end 
            ca = ensureCell(ca);
            try
                [S,R] = cellfun(@(x) mlbash(['mv ' flags ' ' x ' ' dest]), ca, 'UniformOutput', false);
            catch ME
                handexcept(ME);
            end
        end
    end
    
	methods 
        
        %% return struct-arrays
        function sarr = files2sa(this, idx)
            list = this.itsListing_(~this.isdir__ & ~this.invisible__);
            if (isempty(list)); sarr = []; return; end
            sarr = this.includePath__(list);
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        function sarr = directories2sa(this, idx)
            list = this.itsListing_( this.isdir__ & ~this.invisible__);
            if (isempty(list)); sarr = []; return; end
            sarr = this.includePath__(list);
            if (exist('idx','var')); sarr = sarr(idx); end
        end
        
        %% return cell-arrays
        function ff   = fqfns(this, idx)
            sarr = this.files2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlsystem.DirTool.fqname__(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = fns(  this, idx)
            sarr = this.files2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlsystem.DirTool.name__(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = fqdns(this, idx)
            sarr = this.directories2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlsystem.DirTool.fqname__(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function ff   = dns(  this, idx)
            sarr = this.directories2sa;
            ff   = cell(1,length(sarr));
            for s = 1:length(ff)
                ff{s} = mlsystem.DirTool.name__(sarr(s));
            end
            if (exist('idx','var'))
                ff = ff{idx}; 
            else
                ff = ensureCell(ff);
            end
        end
        function len  = length(this)
            len = length(this.itsListing_);
        end
        
        %% ctor
 		function this = DirTool(varargin) 
 			%% DirTool 
 			%  Usage:  expects [0 1] string arguments required by dir            
            
            ip = inputParser;
            addOptional(ip, 'name', pwd, @ischar);
            parse(ip, varargin{:});
            
            this.name_ = ip.Results.name;
            this.itsListing_ = dir(this.name_);
            this.pwd_ = pwd;
            this.itsPath_ = this.setItsPath__;
 		end 
    end 
    
    %% PRIVATE
    
    properties %(Access = private)
        itsListing_
        itsPath_
        name_
        pwd_
    end
    
    methods (Access = 'private', Static)
        function tf    = hasflags__(obj)
            if (ischar(obj) && strncmp('-', obj, 1))
                tf = true;
            else
                tf = false;
            end
        end
        function [a,b] = swap__(a, b)
            tmp = a;
            a   = b;
            b   = tmp;
        end
        function ff    = fqname__(strct)
            ff = fullfile(strct.itsPath, strct.name);
        end
        function ff    = name__(strct)
            ff = strct.name;
        end
        function pth  = trimTerminalFilesep__(pth)
            if (strcmp(pth(end), filesep))
                pth = pth(1:end-1);
            end
        end
    end
    
    methods (Access = 'private')
        function tf   = isdir__(this)
            tf = this.zerosVec__;
            for z = 1:length(tf) %#ok<FORFLG>
                tf(z) = this.itsListing_(z).isdir; 
            end
        end
        function tf   = invisible__(this)
            tf = this.zerosVec__;
            for z = 1:length(tf) %#ok<FORFLG>
                tf(z) = strncmp('.', this.itsListing_(z).name, 1); 
            end
        end
        function sarr = includePath__(this, sarr)
            for s = 1:length(sarr) %#ok<FORFLG>
                sarr(s).itsPath = this.itsPath_;
            end
        end
        function pth  = setItsPath__(this)            
            pth = this.name_;
            if (~strcmp(pth(1), filesep))
                pth = fullfile(this.pwd_, pth);
            end
            if (isdir(pth))
                pth = this.trimTerminalFilesep__(pth);
                return
            end
            if (lstrfind(pth, '?'))
                pth = strtok(pth, '?');
                found = strfind(pth, filesep);
                pth = pth(1:found(end)-1);
                return
            end
            if (lstrfind(pth, '*'))
                pth = strtok(pth, '*');
                found = strfind(pth, filesep);
                pth = pth(1:found(end)-1);
                return
            end            
            if (0 == this.length || 1 == this.length)
                pth = this.pwd_;
                return
            end
            error('mlsystem:ioError', 'DirTool.setItsPath__');
        end
        function z    = zerosVec__(this)
            z = zeros(1,length(this.itsListing_));
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

