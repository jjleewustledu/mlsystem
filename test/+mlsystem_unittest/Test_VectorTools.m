classdef Test_VectorTools < matlab.unittest.TestCase
	%% TEST_VECTORTOOLS 

	%  Usage:  >> results = run(mlsystem_unittest.Test_VectorTools)
 	%          >> result  = run(mlsystem_unittest.Test_VectorTools, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 20-Jul-2017 15:31:25 by jjlee,
 	%  last modified $LastChangedDate$ and placed into repository /Users/jjlee/Local/src/mlcvl/mlsystem/test/+mlsystem_unittest.
 	%% It was developed on Matlab 9.2.0.538062 (R2017a) for MACI64.  Copyright 2017 John Joowon Lee.
 	
	properties
        vec0
 		registry
 		testObj
        times0
 	end

	methods (Test)
		function test_afun(this)
 			import mlsystem.*;
 			this.assumeEqual(1,1);
 			this.verifyEqual(1,1);
 			this.assertEqual(1,1);
        end
        function test_vec0(this)
            plot(this.vec0);
            title('Test_VectorTools.vec0');
        end
        function test_shiftVector(this)
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, 5);
            plot(this.times0, this.vec0, t, f);
            title('shift Dt = 5');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 25);
            this.verifyEqual(length(f), 25);
            
            figure;
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, -5);
            plot(this.times0, this.vec0, t, f);
            title('shift Dt = -5');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 15);
            this.verifyEqual(length(f), 15);
            
            figure;
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, -10);
            plot(this.times0, this.vec0, t, f);
            title('shift Dt = -10');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 10);
            this.verifyEqual(length(f), 10);
        end
	end

 	methods (TestClassSetup)
		function setupVectorTools(this)
 			import mlsystem.*;
            this.times0 = 0:19;
            this.vec0 = zeros(1, 20);
            this.vec0(6:20) = exp(-(0:14)/10);
 			this.testObj_ = VectorTools;
 		end
	end

 	methods (TestMethodSetup)
		function setupVectorToolsTest(this)
 			this.testObj = this.testObj_;
 			this.addTeardown(@this.cleanFiles);
 		end
	end

	properties (Access = private)
 		testObj_
 	end

	methods (Access = private)
		function cleanFiles(this)
 		end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

