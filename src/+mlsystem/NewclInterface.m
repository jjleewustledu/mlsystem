classdef NewclInterface  
	%% NEWCLINTERFACE   
    %
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.532 (R2014a) 
 	%  $Id$  	 

	properties (Abstract)
        classSummary
        ctorUsage
        packageHome
        packageName
        verbose
 	end 

	methods (Abstract, Static)
        makecl
    end 
    
    methods (Abstract)
        classInheritance(this)
        className(this)
        classSignature(this)
        fqpath(this)
        functionSignature(this)
        methodsSignature(this)
        propertiesSignature(this)
        superClassNames(this)
    end
    
    %% PROTECTED
    
    properties (Constant, Access = 'protected')
        EXT = '.m';
    end
    

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

