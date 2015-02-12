classdef NewClassStrategyResult4 < mlsystem.NewClassStrategyResult3 & mlsystem.NewClassStrategyResult2
	%% NEWCLASSSTRATEGYRESULT4 is the output result of NewClassStrategy that has two superclasses
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
 		function this = NewClassStrategyResult4(varargin) 
			%% NEWCLASSSTRATEGYRESULT4 
			%  Usage:   this = NewClassStrategyResult4([parameter_name, parameter_value, ...]) 

			this = this@mlsystem.NewClassStrategyResult3(varargin{:});
		end 
 	end 

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

