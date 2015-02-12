classdef NewInterfaceStrategy < mlsystem.NewClassStrategy
	%% NEWINTERFACESTRATEGY  
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
            
            this = mlsystem.NewInterfaceStrategy(varargin{:});
            this.writecl;
        end       
    end
    
    methods        
        function n = className(this)
            assert(~isempty(this.className_));
            n = char(this.className_);
            if (length(n) < 9)
                n = [n 'Interface']; end
            if (~strcmp('Interface', n))
                n = [n 'Interface']; end
        end
        function s = functionSignature(this) %#ok<MANU>
            s = sprintf('\t\tafun(this) \n');
        end
        function s = methodsSignature(this)
            s = sprintf( ...
                '\tmethods (Abstract) \n%s\tend \n\n', ...
                this.functionSignature);
        end
        function s = propertiesSignature(this) %#ok<MANU>
            s = sprintf( ...
                '\tproperties (Abstract) \n\t\t%s \n\tend \n\n', ...
                'aproperty');
        end
    end
    
	methods (Access = 'protected')
 		function this = NewInterfaceStrategy(varargin) 
			%% NEWINTERFACESTRATEGY 
			%  Usage:  NewClassStrategy(pkgname, [{]classname [pkgname2.]classname2[}][, class_summary, ctor_usage])
            %                                       ^ "Interface" suffix will be added as needed"

			this = this@mlsystem.NewClassStrategy(varargin{:});
		end 
 	end 

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

