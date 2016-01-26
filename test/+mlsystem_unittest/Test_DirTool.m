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
         function test_name_(this)
            import mlsystem.*;
%            dt = DirTool('/');
%            this.verifyEqual(dt.itsPath, '/');
            dt = DirTool('/Volumes');
            this.verifyEqual(dt.itsPath, '/Volumes');
            dt = DirTool('/Volumes/InnominateHD3');
            this.verifyEqual(dt.itsPath, '/Volumes/InnominateHD3');
            dt = DirTool('/Volumes/InnominateHD3/');
            this.verifyEqual(dt.itsPath, '/Volumes/InnominateHD3');
            
            cd(this.registry.sessionPath);
            dt = DirTool('ECAT_EXACT');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', ''));
            dt = DirTool('ECAT_EXACT/pet');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet', ''));
            dt = DirTool('ECAT_EXACT/pet/');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet', ''));
            dt = DirTool('ECAT_EXACT/*');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT',  ''));
            dt = DirTool('ECAT_EXACT/p*');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT',  ''));
            dt = DirTool('ECAT_EXACT/pe?');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT',  ''));
            dt = DirTool('ECAT_EXACT/p??');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT',  ''));
            dt = DirTool('ECAT_EXACT/*p');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT',  ''));
            dt = DirTool('ECAT_EXACT/pet/*v');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet',  ''));
            dt = DirTool('ECAT_EXACT/pet/*.v');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet',  ''));
            dt = DirTool('ECAT_EXACT/pet/*');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet',  ''));
            dt = DirTool('ECAT_EXACT/pet/nonexistent');
            this.verifyEqual(dt.itsPath, fullfile(this.registry.sessionPath, ''));
        end
        function test_itsPath(this)
            this.verifyEqual(this.testObj.itsPath, this.pwd_);
        end
        function test_itsListing(this)
            this.verifyTrue(isstruct(this.testObj.itsListing));
            this.verifyEqual(size(this.testObj.itsListing), [15 1]);
            this.verifyTrue(isfield(this.testObj.itsListing, 'name'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'date'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'bytes'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'isdir'));
            this.verifyTrue(isfield(this.testObj.itsListing, 'datenum'));
        end
        
        function test_ctor(this)
            this.verifyEqual(this.testObj, mlsystem.DirTool(this.pwd_));
        end
        function test_ctorDir(this)
            dt = mlsystem.DirTool('p7377tr1_frames');
            this.verifyTrue(isempty(dt.fqdns));
            this.verifyEqual(dt.fqfns{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/pet/p7377tr1_frames/p7377tr1.img.rec');
        end
        function test_fqfns(this)
            dt = mlsystem.DirTool('*.v');
            this.verifyEqual(length(dt.fqfns), 5);
            this.verifyEqual(dt.fqfns{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/pet/p7377ho1.v');
            this.verifyEqual(dt.fqfns{end}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/pet/p7377tr1.v');
        end
        function test_fqdns(this)
            dt = mlsystem.DirTool('..');
            this.verifyEqual(length(dt.fqdns), 4);
            this.verifyEqual(dt.fqdns{1}, ...
                '/Volumes/InnominateHD3/Local/test/cvl/np755/mm01-020_p7377_2009feb5/ECAT_EXACT/pet/../962_4dfp');
        end
	end

 	methods (TestClassSetup)
		function setupDirTool(this)
            this.registry = mlfourd.UnittestRegistry.instance('initialize');
            this.registry.sessionFolder = 'mm01-020_p7377_2009feb5';
            cd(fullfile(this.registry.sessionPath, 'ECAT_EXACT', 'pet', ''));
            this.pwd_ = pwd;
 			this.testObj_ = mlsystem.DirTool;
 		end
	end

 	methods (TestMethodSetup)
		function setupDirToolTest(this)
 			this.testObj = this.testObj_;
            cd(this.pwd_);
 		end
	end

	properties (Access = 'private')
        pwd_
 		testObj_
 	end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

