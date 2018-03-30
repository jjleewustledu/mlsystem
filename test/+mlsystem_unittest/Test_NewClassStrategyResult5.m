classdef Test_NewClassStrategyResult5 < mlsystem_unittest.Test_NewClassStrategyResult
	%% TEST_NEWCLASSSTRATEGYRESULT5 is testing the output of NewTestStrategy
	%  Usage:  >> results = run(mlsystem.Test_NewClassStrategyResult5)
	%          >> result  = run(mlsystem.Test_NewClassStrategyResult5)
	%  See also:  file:///Applications/Developer/MATLAB_R2014a.app/help/matlab/matlab-unit-test-framework.
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
		testData 
	end 

	methods (Test) 
		function test_afun(this) 
			import mlsystem.*; 
		end 
	end 

	methods (TestClassSetup) 
		function addPathAndData(this) 
			this.testData.origPath = pwd;
			this.testData.workPath = fullfile(getenv('HOME'), 'MATLAB-Drive/mlsystem/test/+mlsystem_unittest');
			cd(this.testData.workPath); 
		end 
	end 

	methods (TestClassTeardown) 
		function removePath(this) 
			cd(this.testData.origPath); 
		end 
	end 

	%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy 
end

