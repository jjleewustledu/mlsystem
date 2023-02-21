classdef Newcl
    %% NEWCL is a factory for pre-populated, pre-formatted Matlab class files.
    %  Usage:  import mlsystem.Newcl
    %          Newcl.makecl(pkgname, inheritance)
    %          Newcl.maketests(pkgname, inheritance)
    %          Newcl.makeall(pkgname, inheritance)
    %  
    %  Created $Date$ by jjlee in repository /Users/jjlee/MATLAB-Drive/mlsystem.
    %  Developed on Matlab 7.10.0.499 (R2010a) for MACI64.  Copyright 2017 & 2021 John J. Lee.    
    
    properties (Constant)
        Args = "arg_name (arg_class): Description of arg."
        ext = ".m"
        EXT = '.m'
        inspiration = "%  Created with mlsystem.Newcl, inspired by Frank Gonzalez-Morphy's newfcn."
        ip = ["ip = inputParser;"; ...
              "addRequired(ip, ""p1"", @(x));"; ...
              "addOptional(ip, ""p2"", [], @(x));"; ...
              "addParameter(ip, ""p3"", [], @(x));"; ...
              "parse(ip, varargin{:});"; ...
              "ipr = ip.Results;"]
        Returns = "returned_name: Description of returned."
    end

    properties
        class_info
    end
    
    methods (Static)
        function this = makecl(varargin)
            %% MAKECL guides building a new class from templates
            %  Args:
            %      pkgname (text): is a Matlab package.
            %      clname (text): is the class name.
            %      access (text): e.g., Abstract, ConstructOnLoad, Hidden, InferiorClasses = {?class1,?class2}, Sealed.
            %                     Default := "".
            %      inheritance (text): or the class, e.g., handle & mlsystem.SuperClass.  
            %                          Default := "".
            %      Desc (text): param contains the class docstring without comment tokens, one line per row.
            %                   Default := "".
            %  Returns:
            %      this: instance of Newcl.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, "pkgname", @istext)
            addRequired(ip, "clname", @istext)
            addParameter(ip, "access", "", @istext)
            addParameter(ip, "inheritance", "", @istext)
            addParameter(ip, "Desc", ["line1"; "line2"], @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            info.pkgname = convertCharsToStrings(ipr.pkgname);
            info.clname = convertCharsToStrings(ipr.clname);
            info.access = convertCharsToStrings(ipr.access);
            info.inheritance = convertCharsToStrings(ipr.inheritance);
            info.Desc = convertCharsToStrings(ipr.Desc);

            this = mlsystem.Newcl();
            info.fqpath = this.prepare_paths(info.pkgname, "src");
            info = this.queryname(info);
            info.str = this.class_block(info.clname, ...
                "access", info.access, ...
                "inheritance", info.inheritance, ...
                "Desc", info.Desc, ...
                "repos", info.fqpath);
            this.writecl(info)
            this.class_info = info;
        end
        function this = maketests(varargin)
            %% MAKETESTS guides building a new test class from templates
            %  Args:
            %      pkgname (text): is a Matlab package.
            %      clname (text): is the class name.
            %      Desc (text): param contains the class docstring without comment tokens, one line per row.
            %                   Default := "".
            %  Returns:
            %      this: instance of Newcl.

            ip = inputParser;
            ip.KeepUnmatched = true;
            addRequired(ip, "pkgname", @istext)
            addRequired(ip, "clname", @istext)
            addParameter(ip, "Desc", ["line1"; "line2"], @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;
            info.pkgname = convertCharsToStrings(ipr.pkgname);
            info.clname = convertCharsToStrings(ipr.clname);
            if ~strncmp(info.clname, "Test_", 5)
                info.clname = "Test_" + info.clname;
            end
            info.Desc = convertCharsToStrings(ipr.Desc);

            this = mlsystem.Newcl();
            info.fqpath = this.prepare_paths(info.pkgname, "test");
            info = this.queryname(info);
            info.str = this.test_class_block(info.clname, ...
                "Desc", info.Desc, ...
                "repos", info.fqpath, ...
                "pkg", info.pkgname);
            this.writecl(info)
            this.class_info = info;
        end
        function [this,that] = makeall(varargin)
            %% MAKEALL guides building a new class and corresponding test class from templates
            %  Args:
            %      pkgname (text): is a Matlab package.
            %      clname (text): is the class name.
            %      access (text): e.g., Abstract, ConstructOnLoad, Hidden, InferiorClasses = {?class1,?class2}, Sealed.
            %                     Default := "".
            %      inheritance (text): for the class, e.g., handle & mlsystem.SuperClass.  
            %                          Default := "".
            %      Desc (text): param contains the class docstring without comment tokens, one line per row.
            %                   The test class will receive automated docstrings.
            %                   Default := "".
            %  Returns:
            %      this: instance of Newcl for class.
            %      that: instance of Newcl for test class.

            this = mlsystem.Newcl.makecl(varargin{:});
            that = this.maketests(varargin{:});
        end

        function [cstatus,this] = makecl__(pkgname, cllist, varargin)
            %% MAKECL guides writing a new subclassed file from templates
            %  Usage:  Newcl.makecl(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            
            p = inputParser;
            addRequired(p, 'pkgname', @ischar);
            addRequired(p, 'cllist',  @(x) ischar(x) || iscell(x));
            addOptional(p, 'summary', ' ', @ischar);
            addOptional(p, 'ctorUsage', '', @ischar);
            parse(p, pkgname, cllist, varargin{:});
            cllist = ensureCell(p.Results.cllist);
                             
            this              = mlsystem.Newcl;
            cinfo.pkg         = p.Results.pkgname;
            cinfo.fqpath      = this.prepare_paths(cinfo.pkg, 'src');
            cinfo.name        = this.queryname__(     cinfo, cllist{1});
            if (length(cllist) > 1)
                cinfo.subname =  cllist(2:end); end
            cinfo.summary     = this.querysummary__(  cinfo, p.Results.summary);
            cinfo.ctorUsage   = this.queryctorusage__(cinfo, p.Results.ctorUsage);
            this.class_info   =                       cinfo;
            cstatus           = this.assemblecl__;
        end        
        function [cstatus,this] = maketests__(pkgname, cllist)
            %% MAKETESTS guides writing a new test-class file from templates
            %  Usage:  Newcl.maketests(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            %                                      ^ prefix "Test_" added as needed
            
            p = inputParser;
            addRequired(p, 'pkgname', @ischar);
            addRequired(p, 'cllist',  @(x) ischar(x) || iscell(x));
            parse(p, pkgname, cllist);           
                              cllist = ensureCell(p.Results.cllist);            
            if (~strncmp(     cllist{1},   'Test_', 5))
                              cllist{1} = ['Test_' cllist{1}]; end
            
            this            = mlsystem.Newcl;
            cinfo.pkg       = p.Results.pkgname;
            cinfo.fqpath    = this.prepare_paths(pkgname, 'test');
            cinfo.name      = this.queryname__(cinfo,  cllist{1});
            cinfo.subname   = 'matlab.unittest.TestCase';
            cinfo.summary   = '';
            cinfo.ctorUsage = '';
            this.class_info = cinfo;
            cstatus         = this.assembletest__;
        end     
        function [cstatus,tstatus,cl,tests] = makeall__(pkgname, cllist, varargin)
            %% MAKEALL guides writing a new class file and test file from templates
            %  Usage:  Newcl.makeall(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            %                                    ^ prefix "Test_" added as needed
            
            import mlsystem.Newcl

            [cstatus,cl]    = Newcl.makecl(   pkgname, cllist, varargin{:});            
            [tstatus,tests] = Newcl.maketests(pkgname, cllist);
        end                

        function s = class_block(varargin)
            %% CLASS_BLOCK
            %  Args:
            %      name (text): is the class name.
            %      access (text): param contains access specifications, 
            %                     e.g., Abstract, ConstructOnLoad, Hidden, InferiorClasses = {?class1,?class2}, Sealed.
            %                     Default := "".
            %      inheritance (text): param for, e.g., handle & matlab.mixin.Heterogeneous & matlab.mixin.Copyable & mlsystem.SuperClass 
            %                          Default := "".           
            %      Desc (text): param contains the class docstring without comment tokens, one line per row.
            %                   Default := "".
            %      repos (text): param identifies a revision control repository.  
            %                    Default := Newcl.repositoryHome().
            %  Returns:
            %      s: string array 
            %          "classdef (Sealed) NewClass < handle & mlsystem.SuperClass 
            %               %% NEWCLASS
            %               %
            %               %  Created 30-Nov-2021 11:04:17 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlsystem.
            %               %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee."
            %
            %               methods
            %                   function this = NewClass(varargin)
            %                       this = this@mlsystem.SuperClass(varargin{:});
            %                   end
            %               end
            %           end"

            import mlsystem.Newcl

            ip = inputParser;
            addRequired(ip, "name", @istext)
            addParameter(ip, "access", "", @istext)
            addParameter(ip, "inheritance", "", @istext)
            addParameter(ip, "Desc", "", @istext)
            addParameter(ip, "repos", Newcl.repositoryHome(), @isfolder)
            parse(ip, varargin{:})
            ipr = ip.Results;

            % build class_sig
            class_sig = "classdef ";
            if strlength(ipr.access) > 0
                class_sig = class_sig + "(" + ipr.access + ") ";
            end
            class_sig = class_sig + ipr.name;
            if strlength(ipr.inheritance) > 0
                class_sig = class_sig + " < " + ipr.inheritance;
            end

            % build this_super
            try
                ss = asrow(strtrim(strsplit(ipr.inheritance, "&")));
                ss = ss(~contains(ss, 'handle') & ~contains(ss, "matlab"));
                super = ss(1);
                if strlength(super) > 0
                    this_super = "this = this@" + super + "(varargin{:});";
                else
                    this_super = "";
                end
            catch %#ok<CTCH> 
                this_super = "";
            end

            % build body
            body = [Newcl.class_docstr("Desc", ipr.Desc, "repos", ipr.repos); ...
                    ""; ...
                    Newcl.methods_block( ...
                    Newcl.ctor_block(ipr.name, "this_super", this_super)); ...
                    ""; ...
                    Newcl.inspiration];

            s = [class_sig; ...
                 "    " + body; ...
                 "end"];
        end
        function s = class_docstr(varargin)
            %% CLASS_DOCSTR
            %  Args:
            %      Desc (text): contains the class docstring without comment tokens, one line per row.
            %                   Default := "".
            %      repos (text): parameter identifies a revision control repository.  
            %                    Default := Newcl.repositoryHome().
            %  Returns:
            %      s: string array 
            %         "%% Desc line 1
            %          %  Desc line 2
            %          %
            %          %  Created 30-Nov-2021 11:04:17 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlsystem.
            %          %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee."

            import mlsystem.Newcl

    		ip = inputParser;
            addParameter(ip, "Desc", "", @istext)
 			addParameter(ip, "repos", Newcl.repositoryHome(), @istext)
 			parse(ip, varargin{:})
 			ipr = ip.Results;

            s = [ipr.Desc; ...
                 ""; ...
                 "Created " + datestr(now) + " by " + getenv('USER') + " in repository " + ipr.repos + "."; ...
                 "Developed on Matlab " + version + " for " + computer + ".  Copyright " + datetime('today').Year + " John J. Lee."];
            s = Newcl.docstr(s);
        end
        function s = ctor_block(varargin)
            %% CTOR_BLOCK
            %  Args:
            %      name (text): is the class name.
            %      in (text): parameter specifying inputs, e.g., "in1, in2, varargin".  
            %                 Default := "varargin".
            %      Args (text): parameter specifying doc-string "arg_name (arg_class):  Description of arg."
            %                   Default := "".
            %      this_super (text): parameter, e.g., "this = this@mlsystem.SuperClass(v1, v2, varargin{:});".
            %                         Default := "".
            %  Returns:
            %      s: string array "function this = NewClass(v1, v2, varargin)
            %                            %  Args:
            %                            %      v1 (v1_class):  Description.
            %                            %      v2 (v2_class):  Description.
            %                            %      varargin(varargin_class):  Description.
            % 
            %                            this = this@mlsystem.SuperClass(v1, v2, varargin{:});
            %                            
            %                            ip = inputParser;
            %                            ip.KeepUnmatched = true;
            %                            addRequired(ip, "v1", @(x) true);
            %                            addRequired(ip, "v2", @(x) true);
            %                            addParameter(ip, "varargin", [], @(x) true);
            %                            parse(ip, v1, v2, varargin{:});
            %                            ipr = ip.Results;
            %             
            %                       end"

            import mlsystem.Newcl
    		ip = inputParser;
 			addRequired(ip, "name", @istext)
 			addParameter(ip, "in", "varargin", @istext)
 			addParameter(ip, "Args", "arg1 (its_class): Description of arg1.", @istext)
            addParameter(ip, "this_super", "", @istext)
 			parse(ip, varargin{:})
 			ipr = ip.Results;

            s = Newcl.function_block(ipr.name, ...
                "out", "this", ...
                "in", ipr.in, ...
                "Desc", "", ...
                "Args", ipr.Args, ...
                "Returns", missing, ...
                "early_code", ipr.this_super);
        end
        function str = docstr(str)
            %% DOCSTR
            %  Args:
            %      str (text): contains one or more rows for a doc-string.
            %  Returns:
            %      str: string array "%% doc-string line 1
            %                         %  doc-string line 2"

            if 0 == strlength(str(1))
                str = "%  " + str(2:end);
                return
            end
            str(1) =     "%% " + str(1);
            str(2:end) = "%  " + str(2:end);
        end
        function s = function_block(varargin)
            %% FUNCTION_BLOCK
            %  Args:
            %      name (text): is the function name.
            %      out (text): parameter specifying outputs, e.g., "[out1,out2]".
            %                  Default := "out".
            %      in (text): parameter specifying inputs, e.g., "this, in1, in2, varargin".
            %                 Default := "varargin".
            %      Desc (text): parameter specifying doc-string top line | missing.
            %                   Default := "".
            %      Args (text): parameter specifying doc-string "arg_name (arg_class):  Description of arg" | missing.
            %                   Default := "".
            %      Returns (text): parameter specifying doc-string "returned_name:  Description of returned" | missing.
            %                      Default := "".
            %      show_docstring (logical): show any available doc-string.
            %                                Default := true.
            %      early_code (text): parameter specifying code before parser.
            %                         Default := "".
            %      late_code (text): parameter specifying code after parser.
            %                        Default := "".
            %      trim (logical): trim whitespace.
            %                      Default := false.
            %  Returns:
            %      s: string array  "function [out1,out2] = name(v1, v2, varargin)
            %                            %% NAME Desc line 1
            %                            %  Desc line 2
            %                            %  Args:
            %                            %      v1(v1_class):  Description.
            %                            %      v2(v2_class):  Description.
            %                            %      varargin(varargin_class):  Description.
            %                            %  Returns:
            %                            %      out1:  Description.
            %                            %      out2:  Description.
            % 
            %                            early_code
            %                            
            %                            ip = inputParser;
            %                            addRequired(ip, "v1", @(x) true)
            %                            addRequired(ip, "v2", @(x) true)
            %                            addParameter(ip, "varargin", [], @(x) true)
            %                            parse(ip, v1, v2, varargin{:})
            %                            ipr = ip.Results;
            %             
            %                            late_code
            %
            %                        end"

            import mlsystem.Newcl

    		ip = inputParser;
 			addRequired(ip, "name", @istext)
 			addParameter(ip, "out", "out", @istext)
 			addParameter(ip, "in", "varargin", @istext)
            addParameter(ip, "Desc", "", @(x) istext(x) || ismissing(x))
 			addParameter(ip, "Args", Newcl.Args, @(x) istext(x) || ismissing(x))
 			addParameter(ip, "Returns", Newcl.Returns, @(x) istext(x) || ismissing(x))
            addParameter(ip, "show_docstring", true, @islogical)
            addParameter(ip, "early_code", "", @istext)
            addParameter(ip, "late_code", "", @istext)
            addParameter(ip, "trim", false, @islogical)
 			parse(ip, varargin{:})
 			ipr = ip.Results;
            if ~ismissing(ipr.Desc) && ~contains(ipr.Desc, ipr.name, "IgnoreCase", true)
                ipr.Desc = upper(ipr.name) + " " + ipr.Desc;
            end
            
            % build func_sig
            func_sig = "function ";
            if strlength(ipr.out) > 0
                func_sig = func_sig + ipr.out + " = ";
            end
            func_sig = func_sig + ipr.name;
            if strlength(ipr.in) > 0
                func_sig = func_sig + "(" + ipr.in + ")";
            else
                func_sig = func_sig + "()";
            end

            % build body
            body = "";
            if ipr.show_docstring
                body = Newcl.function_docstr( ...
                    "Desc", ipr.Desc, ...
                    "Args", Newcl.Args_docstr(ipr.Args, ipr.in), ...
                    "Returns", Newcl.Returns_docstr(ipr.Returns, ipr.out));
            end
            if strlength(ipr.early_code) > 0
                body = [body; ...
                      ""; ...
                      ipr.early_code];
            end
            if contains(ipr.in, "varargin")
                varname = strsplit(ipr.Args, " ");
                varname = varname(1);
                body = [body; ...
                      ""; ...
                      Newcl.ip_code(ipr.in, varname)];
            end
            if strlength(ipr.late_code) > 0
                body = [body; ...
                      ""; ...
                      ipr.late_code];
            end
            body = [body; ...
                  ""];
            if ipr.trim
                body = body(strlength(body) > 0);
            end

            s = [func_sig; ...
                 "    " + body; ...
                 "end"];
        end
        function s = function_docstr(varargin)
            %% FUNCTION_DOCSTR
            %  Args:
            %      Desc (text): parameter specifying doc-string top line | missing.
            %                   Default := "".
            %      Args (text): parameter specifying doc-string "arg_name (arg_class):  Description of arg" | missing.
            %                   Default := Newcl.Args.
            %      Returns (text): parameter specifying doc-string "returned_name:  Description of returned" | missing.
            %                      Default := Newcl.Returns.
            %  Returns:
            %      s: string array "%% Desc line 1
            %                       %  Desc line 2
            %                       %  Args:
            %                       %      arg_name (arg_class):  Description of arg.
            %                       %  Returns:
            %                       %      returned_name:  Description of returned."
            
            import mlsystem.Newcl

    		ip = inputParser;
            addParameter(ip, "Desc", "", @(x) istext(x) || ismissing(x))
 			addParameter(ip, "Args", Newcl.Args, @(x) istext(x) || ismissing(x))
 			addParameter(ip, "Returns", Newcl.Returns, @(x) istext(x) || ismissing(x))
 			parse(ip, varargin{:})
 			ipr = ip.Results;
            if ismissing(ipr.Desc)
                ipr.Desc = "";
            end
            if ismissing(ipr.Args)
                ipr.Args = "";
            end
            if ismissing(ipr.Returns)
                ipr.Returns = "";
            end

            s = ipr.Desc;
            if strlength(ipr.Args) > 0
                s = [s; ...
                     "Args:"; ...
                     "    " + ipr.Args];
            end
            if strlength(ipr.Returns) > 0
                s = [s; ...
                     "Returns:"; ...
                     "    " + ipr.Returns];
            end
            s = Newcl.docstr(s);
        end
        function s = methods_block(str, varargin)
            %% METHODS_BLOCK
            %  Args:
            %      str (text): contains the methods body, one line per row.
            %      access (text):  contains access specifications, 
            %                      e.g., Abstract, Access = private, Constant, Hidden, Sealed, Static.  
            %                      Default := "".
            %  Returns:
            %      s: string array "methods ... end".

            ip = inputParser;
            addRequired(ip, "str", @istext)
            addOptional(ip, "access", "", @istext)
            parse(ip, str, varargin{:})
            ipr = ip.Results;
            if strlength(ipr.access) > 0
                access_ = " (" + ipr.access + ")";
            else
                access_ = "";
            end

            s = ["methods" + access_; ...
                 "    " + ipr.str; ...
                 "end"];
        end
        function s = properties_block(str, varargin)
            %% PROPERTIES_BLOCK
            %  Args:
            %      str (text): contains the properties body, one line per row.
            %      access (text): contains access specifications, 
            %                     e.g., Abstract, Access = private, GetAccess=protected, SetAccess=protected, 
            %                           Constant, Dependent, Hidden, Transient.  
            %                     Default := "".
            %  Returns:
            %      s: string array "properties ... end".

            ip = inputParser;
            addRequired(ip, "str", @istext)
            addOptional(ip, "access", "", @istext)
            parse(ip, str, varargin{:})
            ipr = ip.Results;
            if strlength(ipr.access) > 0
                access_ = " (" + ipr.access + ")";
            else
                access_ = "";
            end

            s = ["properties" + access_; ...
                 "    " + ipr.str; ...
                 "end"];
        end
        function pth = repositoryHome()
            pth = fullfile(getenv('HOME'), 'MATLAB-Drive', '');
        end
        function s = test_class_block(varargin)
            %% TEST_CLASS_BLOCK
            %  Args:  
            %      name (text): is the class name.        
            %      Desc (text): contains the class docstring without comment tokens, one line per row.
            %                   Default := "".
            %      repos (text): parameter identifies a revision control repository.  
            %                    Default := Newcl.repositoryHome().
            %  Returns:
            %      s: string array 
            %          "classdef Test_NewClass < matlab.unitest.TestCase
            %               %% TEST_NEWCLASS
            %               %
            %               %  Created 30-Nov-2021 11:04:17 by jjlee in repository /Users/jjlee/MATLAB-Drive/mlsystem.
            %               %  Developed on Matlab 9.11.0.1809720 (R2021b) Update 1 for MACI64.  Copyright 2021 John J. Lee."
            %
            %               properties
            %                   testObj
            %               end
            %
            % 	            methods (Test)
            % 		            function test_afun(this)
            %  			            import mlfourd.*;
            %  			            this.assumeEqual(1,1);
            %  			            this.verifyEqual(1,1);
            %  			            this.assertEqual(1,1);
            %  		            end
            % 	            end
            %             
            %  	            methods (TestClassSetup)
            % 		            function setupTest(this)
            %  			            import mlsystem.*;
            %  			            this.testObj_ = NewClass();
            %  		            end
            % 	            end
            %             
            %  	            methods (TestMethodSetup)
            % 		            function setupTestTest(this)
            %  			            this.testObj = this.testObj_;
            %  			            this.addTeardown(@this.cleanTestMethod);
            %  		            end
            % 	            end
            %             
            % 	            properties (Access = private)
            %  		            testObj_
            %  	            end
            %             
            % 	            methods (Access = private)
            % 		            function cleanTestMethod(this)
            %  		            end
            % 	            end
            %           end"

            import mlsystem.Newcl

            ip = inputParser;
            addRequired(ip, "name", @istext)
            addParameter(ip, "Desc", "", @istext)
            addParameter(ip, "repos", Newcl.repositoryHome(), @isfolder)
            addParameter(ip, "pkg", "mlsystem", @istext)
            parse(ip, varargin{:})
            ipr = ip.Results;

            % build code lines
            re = regexp(ipr.name, "Test_(?<class_name>\w+)", "names");
            code1 = ["import " + ipr.pkg + ".*"; ...
                     "this.assumeEqual(1,1);"; ...
                     "this.verifyEqual(1,1);"; ...
                     "this.assertEqual(1,1);"];
            code2 = ["import " + ipr.pkg + ".*"; ...
                     "this.testObj_ = " + re.class_name + "();"];
            code3 = ["this.testObj = this.testObj_;"; ...
                     "this.addTeardown(@this.cleanTestMethod)"];

            % build body
            body = [Newcl.class_docstr("Desc", ipr.Desc, "repos", ipr.repos); ...
                    ""; ...
                    Newcl.properties_block("testObj"); ...
                    ""; ...
                    Newcl.methods_block( ...
                        Newcl.function_block( ...
                            "test_afun", "out", "", "in", "this", "early_code", code1, "show_docstring", false, "trim", true), ...
                        "Test"); ...
                    ""; ...
                    Newcl.methods_block( ...
                        Newcl.function_block( ...
                            "setup" + re.class_name, "out", "", "in", "this", "early_code", code2, "show_docstring", false, "trim", true), ...
                        "TestClassSetup"); ...
                    ""; ...
                    Newcl.methods_block( ...
                        Newcl.function_block( ...
                            "setup" + re.class_name + "Test", "out", "", "in", "this", "early_code", code3, "show_docstring", false, "trim", true), ...
                        "TestMethodSetup"); ...
                    ""; ...
                    Newcl.properties_block("testObj_", "Access = private"); ...
                    ""; ...
                    Newcl.methods_block( ...
                        Newcl.function_block( ...
                            "cleanTestMethod", "out", "", "in", "this", "show_docstring", false, "trim", true), ...
                        "Access = private"); ...
                    ""; ...
                    Newcl.inspiration];

            s = ["classdef " + "Test_" + re.class_name + " < matlab.unittest.TestCase"; ...
                 "    " + body; ...
                 "end"];
        end
    end
    
    %% PRIVATE 

    properties (Access = private)
        classNotes_
        propsig_
        methsig_
        privatePropsig_
        privateMethsig_
    end
    
    methods (Static, Access = private)
        function s = Args_docstr(Args_, instr)
            if ismissing(Args_)
                s = "";
                return
            end
            if strlength(Args_) > 0
                s = Args_;
                return
            end
            strarr = ascol(strtrim(strsplit(instr, ",")));
            s = strarr + " (" + strarr + "_class): Description of " + strarr + ".";
        end
        function s = ip_code(instr, varname)
            strarr = ascol(strtrim(strsplit(instr, ",")));
            isreq = ~contains(strarr, "varargin");
            s = "addParameter(ip, """ + strarr + """, [], @(x) true)";
            s(isreq) = "addRequired(ip, """ + strarr(isreq) + """, @(x) true)";
            s = strrep(s, "varargin", varname);
            s = ["ip = inputParser;"; ...
                 s; ...
                 "parse(ip, " + instr + "{:})"; ...
                 "ipr = ip.Results;"];
        end
        function apth = prepare_paths(pkgname, srctype)
            %% PREPARE_PATHS creates package, src or test directories as needed.
            %  Args:
            %      pkgname (text):  to be located in repositoryHome().
            %      srctype (text):  is "src" | "test" | 'src' | 'test'.
            
            import mlsystem.Newcl

            srctype = convertCharsToStrings(srctype);
            switch lower(srctype)
                case "src"
                    plusfold = "+" + pkgname;
                case "test"
                    plusfold = "+" + pkgname + "_unittest";
                otherwise
                    error('mlsystem:UnsupportedParamValue', 'Newcl.prepare_paths.srctype was %s', srctype);
            end            
            apth = fullfile(Newcl.repositoryHome(), pkgname, srctype, plusfold, '');
            if ~isfolder(apth)
                mkdir(apth)
            end
        end 
        function s = Returns_docstr(Returns_, outstr)
            if ismissing(Returns_)
                s = "";
                return
            end
            if strlength(Returns_) > 0
                s = Returns_;
                return
            end
            outstr = strrep(outstr, "[", "");
            outstr = strrep(outstr, "]", "");
            strarr = ascol(strtrim(strsplit(outstr, ",")));
            s = strarr + ": Description of " + strarr+ ".";
        end

        function strng = classInheritance__(cinfo)
            assert(isstruct(cinfo));
            if (isfield(cinfo, 'subname'))
                if (iscell(cinfo.subname))
                    for s = 1:length(cinfo.subname)-1
                        cinfo.subname{s} = [cinfo.subname{s} ' & '];
                    end
                    parents = [cinfo.subname{:}];
                else
                    parents = cinfo.subname;
                end
                strng = sprintf('< %s', parents);
            else
                strng = '';
            end
        end
        function strng = funInheritance__(cinfo)
            assert(isstruct(cinfo));
            if (isfield(cinfo, 'subname'))
                if (iscell(cinfo.subname))
                    parent = cinfo.subname{1};
                    if (strcmp(parent, 'handle'))
                        parent = cinfo.subname{2};
                    end
                else
                    parent = cinfo.subname;
                end
                strng = sprintf('this = this@%s%s', parent, '(varargin{:});');
            else
                strng = '';
            end
        end
    end
    
    methods (Access = private)
        function this = Newcl
        end % ctor

        function info = queryname(this, info)
            fqfn = fullfile(info.fqpath, info.clname + this.ext);
            while exist(fqfn, "file")
                choice = string(questdlg( ...
                    "Class file " + fqfn + " already exists.  Overwrite?", ...
                    "mlsystem.Newcl.queryname()", "Yes", "No", "No"));
                if (strcmpi(choice, "Yes"))
                    return;
                else
                    new_name = string(inputdlg( ...
                        "New class name?", ...
                        "mlsystem.Newcl.queryname()", 1, info.clname));
                    if strlength(new_name) > 0
                        info.clname = new_name;
                        fqfn = fullfile(info.fqpath, info.clname + this.ext);
                    end
                end
            end
        end
        function status = writecl(this, info)
            fqfn = fullfile(info.fqpath, info.clname + this.ext);
            fid = fopen(fqfn,'w');
            fprintf(fid, '%s\n', info.str);
            status = fclose(fid);
            assert(0 == status, 'mlsystem:IOErr', 'Newcl.writecl could not close %s', fqfn)
            edit(fqfn);
        end

        function clname    = queryname__(this, cinfo, clname)
            %% QUERYNAME determines a classname, querying user if the classname already exists
            %  clname = queryname__(this, class_info, clname)
            %                           ^ struct
            %                                  ^ string
            
            fqfn = [fullfile(cinfo.fqpath, clname) this.EXT];
            opts.Interpreter='none'; opts.Default = 'No';
            while (exist(fqfn, 'file') || exist(clname, 'class'))
                choice = questdlg( ...
                    sprintf(' Class file %s already exists.  Overwrite? \n', fqfn),...
                             'mfiles:  Newcl', ...
                             'Yes', 'No', opts);
                if (strcmpi(choice, 'Yes'))
                    return;
                else
                    clname = char(inputdlg(' New class name? ', 'Newcl.queryname__', 1, {clname}));
                    pos    = strfind(clname, '.m');
                    if (any(pos))
                        clname = clname(1:pos-1);
                        break;
                    end
                    if (isempty(clname))
                        paramError(?meta.class, 'clname', clname);
                    end
                end
                fqfn = [fullfile(cinfo.fqpath, clname) this.EXT];
            end
            assert(ischar(clname));
        end 
        function clsummary = querysummary__(this, cinfo, clsummary) %#ok<INUSL>
            %% QUERYSUMMARY presents a dialogue box
            
            assert(~isempty(cinfo.name));
            if isempty(clsummary)
                clsummary = [upper(cinfo.name) ' '];
            end
        end
        function ctorusage = queryctorusage__(~, ~, ctorusage)
            if isempty(ctorusage)
                ctorusage = 'Usage:  >>'; 
            end
        end
        function status    = assemblecl__(this)
            % ASSEMBLECL
            
            import mlsystem.*;
            cinfo = this.class_info;
            classusage = ...
                sprintf('\t%s%s.%s()\n\n', ...
                '%  Usage:  >> obj = ', cinfo.pkg, cinfo.name);
            this.classNotes_ = [classusage this.topClassNotes__('')];
            this.propsig_ = ...
                sprintf('\t%s\n\t\t%s\n\t%s\n\n', ...
                'properties', '', 'end');     
            this.methsig_ = ...
                sprintf('\tmethods\n\t\t%s%s\tend\n\n', ...
                '', this.ctorSig__);
            this.privatePropsig_ = '';
            this.privateMethsig_ = '';            
            status = this.writecl__;
        end
        function status    = assembletest__(this)
            % ASSEMBLETEST
            
            import mlsystem.*;            
            cinfo = this.class_info;            
            testusage = ...
                sprintf('\t%s%s_unittest.%s%s\n \t%s%s_unittest.%s%s\n \t%s\n\n', ...
                '%  Usage:  >> results = run(', cinfo.pkg, cinfo.name, ')', ...
                '%          >> result  = run(', cinfo.pkg, cinfo.name, ', ''test_dt'')', ...
                '%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html');
            this.classNotes_ = [testusage this.topClassNotes__];            
            this.propsig_ = ...
                sprintf('\t%s\n \t\t%s\n \t\t%s\n \t%s\n\n', ...
                'properties', 'registry', 'testObj', 'end'); 
            setupSig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', ['setup' cinfo.name(6:end) '(this)'], ...
                ['import ' cinfo.pkg '.*;'], ...
                ['this.testObj_ = ' cinfo.name(6:end) '();'], 'end');  
            setupTestSig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', ['setup' cinfo.name(6:end) 'Test(this)'], ...
                'this.testObj = this.testObj_;', 'this.addTeardown(@this.cleanTestMethod);', 'end');  
            funsig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', 'test_afun(this)', ...
                ['import ' cinfo.pkg '.*;'] , ...
                'this.assumeEqual(1,1);', ...
                'this.verifyEqual(1,1);', ...
                'this.assertEqual(1,1);', 'end');  
            this.methsig_ = ...
                sprintf('\t%s\n%s\t%s\n\n \t%s\n%s\t%s\n\n \t%s\n%s\t%s\n\n', ...
                'methods (Test)', funsig, 'end', ...
                'methods (TestClassSetup)', setupSig, 'end', ...
                'methods (TestMethodSetup)', setupTestSig, 'end');  
            this.privatePropsig_ = ...
                sprintf('\t%s\n \t\t%s\n \t%s\n\n', ...
                'properties (Access = private)', 'testObj_', 'end');  
            privateFunsig = ...
                sprintf('\t\t%s %s\n \t\t%s\n', ...
                'function', 'cleanTestMethod(this)', 'end'); 
            this.privateMethsig_ = ...
                sprintf('\t%s\n%s\t%s\n\n', ...
                'methods (Access = private)', privateFunsig, 'end');            
            status = this.writecl__;
        end
        function str       = preamble__(this)
            cinfo = this.class_info;
            str = sprintf('classdef %s %s\n\t%s %s %s\n', ...
                          cinfo.name, ...
                          mlsystem.Newcl.classInheritance__(cinfo), ...
                          '%%', ...
                          upper(cinfo.name), ...
                          cinfo.summary);    
        end
        function str       = topClassNotes__(this, varargin)
            ip = inputParser;
            addOptional(ip, 'classHints', '', @ischar);
            parse(ip, varargin{:});
            
            str = sprintf('\t%s\n \t%s\n \t%s\n \t%s\n \t%s\n', ...                
                 '%  $Revision$', ...
                ['%  was created ' datestr(now) ' by ', getenv('USER') ','], ...
                ['%  last modified $LastChangedDate$ and placed into repository ' this.class_info.fqpath '.'], ...
                ['%% It was developed on Matlab ' version ' for ' computer '.  Copyright ' num2str(datetime('today').Year) ' John Joowon Lee.'], ... 
                ip.Results.classHints);  
        end
        function str       = ctorSig__(this)
            if (strcmp(this.class_info.name(1), 'I'))
                str = '';
                return
            end 
            cinfo = this.class_info; 
            str = sprintf( ...
                '%s\n \t\t\t%s\n \t\t\t%s\n \t\t\t%s\n\n \t\t\t%s\n \t\t%s\n', ...
                ['function this = ' cinfo.name '(varargin)'], ...
                ['%% ' upper(cinfo.name)], ...
                ['%  ' this.Args{1}], ...
                ['%  ' this.Args{2}], ...
                mlsystem.Newcl.funInheritance__(cinfo), ...
                'end');
            return
        end
        function str       = closing__(~)
            str = sprintf('\t%s\nend\n', ...
                '%  Created with mlsystem.Newcl by John J. Lee, as inspired by Frank Gonzalez-Morphy newfcn.');
        end
        function status    = writecl__(this)
            fqfn   = fullfile(this.class_info.fqpath, [this.class_info.name this.EXT]);
            fid    = fopen(fqfn,'w');
            fprintf( fid, '%s%s%s%s%s%s%s%s', ...
                this.preamble__,       this.classNotes_, ...
                this.propsig_,        this.methsig_, ...
                this.privatePropsig_, this.privateMethsig_, this.closing__);
            status = fclose(fid);
            if (status == 0)
                % Open the written file in the MATLAB Editor/Debugger
                v = version;
                if v(1) == '7'             % R14 Version
                    opentoline(fqfn, 12);  % Open File and highlight the start Line
                else
                    edit(fqfn);
                end
            else
                error('mlsystem:IOErr', 'Newcl.writecl__: problems closing__ file->%s', fqfn);
            end
        end
      
    end % private methods
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end
