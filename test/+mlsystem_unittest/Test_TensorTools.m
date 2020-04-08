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
        function test_shiftTensorNumeric(this)
            t = [0 1 3 7 15 31];
            f = mlfourd.ImagingFormatContext( ...
                fullfile(MatlabRegistry.instance().srcroot, 'mlfourd', 'data', 'T1.nii.gz'));
            f.fileprefix = 'Test_TensorTools_test_shiftTensorNumeric';
            f.datatype = 64;
            f.img = repmat(f.img, [1 1 1 6]);
            for ti = 1:6
                f.img(:,:,:,ti) = f.img(:,:,:,ti)*2*t(ti)/dipmax(f.img);
            end
            
            [a,b] = shiftTensor(t, f.img, 0);
            this.verifyEqual( a, [0     1     3     7    15    31])
            this.verifyEqualb(b, [0     2     6    14    30    62])
            [a,b] = shiftTensor(t, f.img, 1);
            this.verifyEqual( a, [0     1     2     4     8    16    32])
            this.verifyEqualb(b, [0     0     2     6    14    30    62])           
            [a,b] = shiftTensor(t, f.img, 2);
            this.verifyEqual( a, [0     1     2     4     8    16    32])
            this.verifyEqualb(b, [0     0     2     6    14    30    62])              
            [a,b] = shiftTensor(t, f.img, 3);
            this.verifyEqual( a, [0     1     3     4     6    10    18    34])
            this.verifyEqualb(b, [0     0     0     2     6    14    30    62])              
            [a,b] = shiftTensor(t, f.img, 7);
            this.verifyEqual( a, [0     1     3     7     8    10    14    22    38])
            this.verifyEqualb(b, [0     0     0     0     2     6    14    30    62])              
            [a,b] = shiftTensor(t, f.img, -1);
            this.verifyEqual( a, [0     2     6    14    30])
            this.verifyEqualb(b, [2     6    14    30    62])              
            [a,b] = shiftTensor(t, f.img, -3);
            this.verifyEqual( a, [0     4    12    28])
            this.verifyEqualb(b, [6    14    30    62])              
            [a,b] = shiftTensor(t, f.img, -7);
            this.verifyEqual( a, [0     8    24])
            this.verifyEqualb(b, [14    30    62])              
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
        function verifyEqualb(this, b, expected)
            for ie = 1:length(expected)
                this.verifyEqual(dipmax(b(:,:,:,ie)), expected(ie))
            end
        end
	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

