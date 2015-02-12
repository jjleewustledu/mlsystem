classdef NewClassStrategy < mlsystem.AbstractNewcl 
	%% NEWCLASSSTRATEGY   
    %
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.532 (R2014a) 
 	%  $Id$
    
    methods (Static)        
        function this = makecl(varargin)
            %% MAKECL writes a new class file to the filesystem
            %  Usage:  NewClassStrategy.makecl(pkgname, [{]classname [pkgname2.]classname2[}][, class_summary, ctor_usage])
            
            this = mlsystem.NewClassStrategy(varargin{:});
            this.writecl;
        end       
    end
    
    %% PROTECTED
    
	methods (Access = 'protected')
 		function this = NewClassStrategy(varargin) 
 			%% NEWCLASSSTRATEGY 
            %  Usage:  NewClassStrategy(pkgname, [{]classname [pkgname2.]classname2[}][, class_summary, ctor_usage])
            
            this = this@mlsystem.AbstractNewcl(varargin{:});
        end 
        function        writecl(this)
            fqfn = fullfile(this.fqpath, [this.className this.EXT]);
            fid  = fopen(fqfn,'w');
            fprintf(fid, '%s%s%s%s', ...
                    this.classSignature, this.propertiesSignature, this.methodsSignature, this.closing);
            if (fclose(fid) ~= 0)  
                error('mlsystem:IOError', 'NewClassStrategy.writecl:  problems closing file->%s', fqfn); end
            v = version; assert(num2str(v(1)) >= 7);
            edit(fqfn);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

