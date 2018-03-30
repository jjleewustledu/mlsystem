classdef NewClassStrategyResult3 < mlsystem_unittest.NewClassStrategy2 & mlsystem_unittest.NewClassStrategy
	%% NEWCLASSSTRATEGYRESULT3 is the output result of NewClassStrategy that has two superclasses
	%
	%  $Revision$ 
	%  was created $Date$ 
	%  by $Author$, 
	%  last modified $LastChangedDate$ 
	%  and checked into repository $URL$, 
	%  developed on Matlab 8.3.0.532 (R2014a) 
	%  $Id$ 
	%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad) 

	properties 
		% N.B. (Abstract, Access='private', GetAccess='protected', SetAccess='protected', Constant, Dependent, Hidden, Transient) 
	end 

	methods 
		% N.B. (Abstract, Access='protected', Hidden, Sealed, Static) 

 		function this = afun(this) 
			import mlsystem.*; 
		end 
 		function this = NewClassStrategyResult3(varargin) 
			%% NEWCLASSSTRATEGYRESULT3 
			%  Usage:   this = NewClassStrategyResult3(varargin) 

			this = this@mlsystem_unittest.NewClassStrategy2(varargin{:});
		end 
 	end 

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

