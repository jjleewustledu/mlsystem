classdef NewTestStrategy < mlsystem.NewClassStrategy
	%% NEWTESTSTRATEGY   
    %
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.532 (R2014a) 
 	%  $Id$ 
 	 
	properties (Constant)
 		 TEST_PACKAGE_NAME_SUFFIX = '_unittest'
    end 
    
    methods (Static)        
        function this = makecl(varargin)
            %% MAKECL writes a new class file to the filesystem
            %  Usage:  NewClassStrategy.makecl(pkgname, [{]classname [pkgname2.]classname2[}][, class_summary, ctor_usage])
            
            this = mlsystem.NewTestStrategy(varargin{:});
            this.writecl;
        end       
    end
    
	methods 
        function f = fqpath(this)
            f = fullfile(this.packageHome, this.packageName, 'test', ['+' this.packageName this.TEST_PACKAGE_NAME_SUFFIX], '');
        end
        function n = className(this)
            assert(~isempty(this.className_));
            n = char(this.className_);
            if (length(n) < 6)
                n = ['Test_' n]; end
            if (~strcmp('Test_', n(1:5)))
                n = ['Test_' n]; end
        end
        function s = classSignature(this)
            preamble = sprintf( ...
                'classdef %s %s\n', this.className, this.classInheritance);
            cidentifiers = sprintf( ...
                '\t%%%% %s %s\n', upper(this.className), this.classSummary);
            unotes = sprintf( ...
                '\t%s\n\t%s\n\t%s\n', ...
               ['%  Usage:  >> results = run(' this.packageName '.' this.className ')'], ...
               ['%          >> result  = run(' this.packageName '.' this.className ', ''test_afun'')'], ...
                '%  See also:  file:///Applications/Developer/MATLAB_R2014a.app/help/matlab/matlab-unit-test-framework.');
            cnotes = sprintf( ...
                '\t%%\n\t%s \n\t%s \n\t%s \n\t%s \n\t%s \n\t%s%s \n\t%s \n\t%s \n\n', ...                
                '%  $Revision$', ...
                '%  was created $Date$', ...
                '%  by $Author$,', ...
                '%  last modified $LastChangedDate$', ...
                '%  and checked into repository $URL$,', ...
                '%  developed on Matlab ', version, ...
                '%  $Id$', ...
                '%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)');
            s = [preamble cidentifiers unotes cnotes];
        end
        function s = functionSignature(this)
            s = sprintf( ...
                '\t\tfunction test_afun(this) \n\t\t\timport %s.*; \n\t\tend \n', ...
                this.packageName);
        end
        function s = methodsSignature(this)
            s = sprintf( ...
                '\tmethods (Test) \n%s\tend \n\n', ...
                this.functionSignature);
        end
        function s = propertiesSignature(this) %#ok<MANU>
            s = sprintf( ...
                '\tproperties \n\t\t%s \n\tend \n\n', ...
                'testData');
        end
        function s = setupSignature(this) 
            s = sprintf( ...
                '\tmethods (TestClassSetup) \n%s\tend \n\n', ...
                this.setupFunctionSignature);
        end
        function s = teardownSignature(this)
            s = sprintf( ...
                '\tmethods (TestClassTeardown) \n%s\tend \n\n', ...
                this.teardownFunctionSignature);
        end
        function s = setupFunctionSignature(this)
            content = sprintf( ...
                '\t\t\t%s\n\t\t\t%s\n\t\t\t%s', ...
                'this.testData.origPath = pwd;', ...
               ['this.testData.workPath = fullfile(''' this.fqpath ''');'], ...
                'cd(this.testData.workPath);');
            s = sprintf( ...
                '\t\tfunction addPathAndData(this) \n%s \n\t\tend \n', ...
                content);
        end
        function n = superClassNames(this)
            if (isempty(this.superClassNames_))
                n = {'matlab.unittest.TestCase'}; return; end
            if (lstrfind(this.superClassNames_, 'matlab.unittest.TestCase'))
                n = this.superClassNames_; return; end
            n = this.superClassNames_; 
        end
        function s = teardownFunctionSignature(this) %#ok<MANU>
            content = sprintf( ...
                '\t\t\t%s', ...
                'cd(this.testData.origPath);');
            s = sprintf( ...
                '\t\tfunction removePath(this) \n%s \n\t\tend \n', ...
                content);
        end
    end
    
    methods (Access = 'protected')
 		function this = NewTestStrategy(varargin)
 			%% NEWTESTSTRATEGY 
 			%  Usage:  this = NewClassStrategy() 
            
            this = this@mlsystem.NewClassStrategy(varargin{:});
 		end 
        function        writecl(this)
            fqfn = fullfile(this.fqpath, [this.className this.EXT]);
            fid  = fopen(fqfn,'w');
            fprintf(fid, '%s%s%s%s%s%s', ...
                    this.classSignature, this.propertiesSignature, this.methodsSignature, this.setupSignature, this.teardownSignature, this.closing);
            if (fclose(fid) ~= 0)  
                error('mlsystem:IOError', 'NewClassStrategy.writecl:  problems closing file->%s', fqfn); end
            v = version; assert(num2str(v(1)) >= 7);
            edit(fqfn);
        end
 	end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

