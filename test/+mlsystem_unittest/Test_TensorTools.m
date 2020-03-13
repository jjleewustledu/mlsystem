classdef Test_TensorTools < matlab.unittest.TestCase
	%% TEST_TENSORTOOLS 

	%  Usage:  >> results = run(mlsystem_unittest.Test_TensorTools)
 	%          >> result  = run(mlsystem_unittest.Test_TensorTools, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 13-Mar-2020 16:13:38 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/MATLAB-Drive/mlsystem/test/+mlsystem_unittest.
 	%% It was developed on Matlab 9.7.0.1296695 (R2019b) Update 4 for MACI64.  Copyright 2020 John Joowon Lee.
 	
	properties
 		registry
 		testObj
 	end

	methods (Test)
		function test_afun(this)
 			import mlsystem.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
 		end
	end

 	methods (TestClassSetup)
		function setupTensorTools(this)
 			import mlsystem.*;
 			this.testObj_ = TensorTools;
 		end
	end

 	methods (TestMethodSetup)
		function setupTensorToolsTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanTestMethod);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanTestMethod(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

