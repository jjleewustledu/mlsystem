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
            figure
            plot(this.vec0);
            title('Test_VectorTools.vec0');
        end
        function test_shiftVector(this)
            figure
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, 5);
            plot(this.times0, this.vec0, t, f, ':o');
            title('shift Dt = 5');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 25);
            this.verifyEqual(length(f), 25);
            
            figure;
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, -5);
            plot(this.times0, this.vec0, t, f, ':o');
            title('shift Dt = -5');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 15);
            this.verifyEqual(length(f), 15);
            
            figure;
            [t,f] = this.testObj.shiftVector(this.times0, this.vec0, -10);
            plot(this.times0, this.vec0, t, f, ':o');
            title('shift Dt = -10');
            legend('vec0(times0)', '[t,f] = shiftVector');
            this.verifyEqual(length(t), 10);
            this.verifyEqual(length(f), 10);
        end
        function test_shiftVectorNumeric(this)
            t = [0 1 3 7 15 31];
            f = 2*t;
            [a,b] = shiftVector(t, f, 0);
            this.verifyEqual(a, [0     1     3     7    15    31])
            this.verifyEqual(b, [0     2     6    14    30    62])
            [a,b] = shiftVector(t, f, 1);
            this.verifyEqual(a, [0     1     2     4     8    16    32])
            this.verifyEqual(b, [0     0     2     6    14    30    62])           
            [a,b] = shiftVector(t, f, 2);
            this.verifyEqual(a, [0     1     2     4     8    16    32])
            this.verifyEqual(b, [0     0     2     6    14    30    62])              
            [a,b] = shiftVector(t, f, 3);
            this.verifyEqual(a, [0     1     3     4     6    10    18    34])
            this.verifyEqual(b, [0     0     0     2     6    14    30    62])              
            [a,b] = shiftVector(t, f, 7);
            this.verifyEqual(a, [0     1     3     7     8    10    14    22    38])
            this.verifyEqual(b, [0     0     0     0     2     6    14    30    62])              
            [a,b] = shiftVector(t, f, -1);
            this.verifyEqual(a, [0     2     6    14    30])
            this.verifyEqual(b, [2     6    14    30    62])              
            [a,b] = shiftVector(t, f, -3);
            this.verifyEqual(a, [0     4    12    28])
            this.verifyEqual(b, [6    14    30    62])              
            [a,b] = shiftVector(t, f, -7);
            this.verifyEqual(a, [0     8    24])
            this.verifyEqual(b, [14    30    62])              
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

