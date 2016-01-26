classdef Test_DirTools < matlab.unittest.TestCase
	%% TEST_DIRTOOLS 

	%  Usage:  >> results = run(mlsystem_unittest.Test_DirTools)
 	%          >> result  = run(mlsystem_unittest.Test_DirTools, 'test_dt')
 	%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html

	%  $Revision$
 	%  was created 17-Jan-2016 22:36:32
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlsystem/test/+mlsystem_unittest.
 	%% It was developed on Matlab 8.5.0.197613 (R2015a) for MACI64.
 	

	properties
 		registry
 		testObj
 	end

	methods (Test)
        function test_itsPath(this)
            this.verifyEqual(this.testObj.itsPath{1}, this.pwd_);
        end
        function test_itsListing(this)
            this.verifyTrue(isstruct(this.testObj.itsListing));
            this.verifyEqual(size(this.testObj.itsListing), [66 1]);
            this.verifyTrue(isfield(this.testObj.itsListing, 'name'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'date'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'bytes'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'isdir'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'datenum'));
        end
        
        function test_ctor(this)
            this.verifyEqual(this.testObj, mlsystem.DirTools(this.pwd_));
            
            dts = mlsystem.DirTools({'ECAT_EXACT' 'Trio'}, 'mri');            
            this.verifyEqual(dts.itsPath{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT');
            this.verifyEqual(size(dts.itsListing), [82 1]);
        end
        function test_fqfns(this)
            dts = mlsystem.DirTools({'ECAT_EXACT' 'Trio'}, 'mri');
            this.verifyEqual(length(dts.fqfns), 60);
            this.verifyEqual(dts.fqfns{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/mri/T1.mgz');
            this.verifyEqual(dts.fqfns{end}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/mri/xdebug_mris_calc');
        end
        function test_fqdns(this)
            dts = mlsystem.DirTools({'ECAT_EXACT' 'Trio'}, 'mri');            
            this.verifyEqual(length(dts.fqdns), 11);
            this.verifyEqual(dts.fqdns{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/962_4dfp');
        end
        function test_cd(this)            
            for d = 1:length(this.testObj.fqdns)-1
                cd(this.testObj.fqdns{d});
                this.verifyTrue(lexist(this.testObj.fqdns{d+1}, 'dir'));
            end
        end
	end

 	methods (TestClassSetup)
		function setupDirTools(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            cd(fullfile(this.registry.sessionPath, ''));
            this.pwd_ = pwd;
 			this.testObj_ = mlsystem.DirTools;
 		end
	end

 	methods (TestMethodSetup)
		function setupDirToolsTest(this)
 			this.testObj = this.testObj_;
 		end
	end

	properties (Access = 'private')
        pwd_
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

