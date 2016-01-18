classdef Test_DirTool < matlab.unittest.TestCase
	%% TEST_DIRTOOL 

	%  Usage:  >> results = run(mlsystem_unittest.Test_DirTool)
 	%          >> result  = run(mlsystem_unittest.Test_DirTool, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 17-Jan-2016 20:37:01
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlsystem/test/+mlsystem_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

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
        function test_itsPath(this)
            this.verifyEqual(this.testObj, mlsystem.DirTool(this.pwd_));
        end
	end

 	methods (TestClassSetup)
		function setupDirTool(this)
 			import mlsystem.*;
            this.registry = mlfourd.UnittestRegistry.instance;
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            cd(this.registry.sessionPath);
            this.pwd_ = pwd;
 			this.testObj_ = DirTool;
 		end
	end

 	methods (TestMethodSetup)
		function setupDirToolTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = 'private')
        pwd_
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

