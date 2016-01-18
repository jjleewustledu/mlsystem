classdef DirTools
    %% DIRTOOLS extends DirTool for multiple name-arguments and cell-arrays of them.
    
    properties
        itsPath
        itsListing
    end
    
    methods
        function pth = get.itsPath(this)
            pth = cellfun(@(t) t.itsPath, this.dirTools_, 'UniformOutput', false);
            pth = unique(pth);
        end
        function list = get.itsListing(this)            
            ca = cellfun(@(t) t.itsListing, this.dirTools_, 'UniformOutput', false);
            list = struct([]);
            for c = 1:length(ca)
                sa = ca{c};
                for s = 1:length(sa)
                    list = [list; sa(s)]; %#ok<AGROW>
                end
            end
        end
        
        %% return concatenated struct-arrays
        function sarr = files2sa(this, idx)
            sarr = arrayfun(@(t) t.files2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end
        end
        function sarr = directories2sa(this, idx)
            sarr = arrayfun(@(t) t.directories2sa, this.dirTools_, 'UniformOutput', false);
            if (exist('idx','var'))
                sarr = sarr(idx); end
        end
        
        %% return concatenated cell-arrays
        function ff = fqfns(this, idx)
            ff = cellfun(@(t) t.fqfns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function ff = fns(this, idx)
            ff = cellfun(@(t) t.fns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
            
        end
        function ff = fqdns(this, idx)
            ff = cellfun(@(t) t.fqdns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function ff = dns(this, idx)
            ff = cellfun(@(t) t.dns, this.dirTools_, 'UniformOutput', false);
            ff = [ff{:}];
            if (exist('idx','var'))
                ff = ff{idx}; end
        end
        function len = length(this)
            len = 0;
            for t = 1:length(this.dirTools_)
                len = len + length(this.dirTools_{t});
            end
        end
        
        function this = DirTools(varargin)
 			%% DirTools
 			%  Usage:  expects 0+ string arguments or cell arguments compatible with dir
            
            import mlsystem.*;
            if (0 == nargin)
                this.dirTools_ = {DirTool};
            end
            for v = 1:length(varargin)
                if (iscell(varargin{v}))
                    cargin = varargin{v};
                    for c = 1:length(cargin)
                        this.dirTools_ = [this.dirTools_ {DirTool(cargin{c})}];
                    end
                else                    
                    this.dirTools_ = [this.dirTools_ {DirTool(varargin{v})}];
                end
            end
        end
    end    
    
    %% PRIVATE
    
    properties (Access = 'private')
        dirTools_ = {}
    end
end

