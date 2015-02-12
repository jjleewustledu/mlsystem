classdef Test_FilesystemRegistry < MyTestCase
	%% TEST_CVLREGISTRY 
    %% Usage:  runtests Test_FilesystemRegistry
    %%
	%% Version $Revision: 2501 $ was created $Date: 2013-08-18 17:52:21 -0500 (Sun, 18 Aug 2013) $ by $Author: jjlee $  
	%% and checked into svn repository $URL: file:///Users/jjlee/Library/SVNRepository_2012sep1/mpackages/mlfourd/test/+mlfourd_xunit/trunk/Test_FilesystemRegistry.m $ 
	%% Developed on Matlab 7.10.0.499 (R2010a) 
	%% $Id: Test_FilesystemRegistry.m 2501 2013-08-18 22:52:21Z jjlee $ 

	properties
        fsr
	end 

	methods 
		function this = Test_FilesystemRegistry(varargin)
            this      = this@MyTestCase(varargin{:});
        end
        
        function setUp(this)
            this.fsr = mlsystem.FilesystemRegistry.instance;
        end
        
	end 
    %  Created with newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end 
