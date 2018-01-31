classdef Newcl
    %% NEWCL is a factory for pre-populated, pre-formatted Matlab class files.
    %  Usage:  Newcl.makecl  
    %          Newcl.maketests
    %          Newcl.makeall
    
    %  Version $Revision$ was created $Date$ by $Author$
    %  and checked into svn repository $URL$
    %  Developed on Matlab 7.10.0.499 (R2010a).  Copyright 2017 John Joowon Lee.
    %  $Id$
    
    properties
        classInfo
        classSummary
        classNotes
        propsig
        methsig
        privatePropsig
        privateMethsig
    end
    
    properties (Dependent)
        packageHome
        verbose
    end
    
    methods (Static)
        function [cstatus,this] = makecl(pkgname, cllist, varargin)
            %% MAKECL guides writing a new subclassed file from templates
            %  Usage:  Newcl.makecl(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            
            p = inputParser;
            addRequired(p, 'pkgname', @ischar);
            addRequired(p, 'cllist',  @(x) ischar(x) || iscell(x));
            addOptional(p, 'summary', ' ', @ischar);
            addOptional(p, 'ctorUsage',  '', @ischar);
            parse(p, pkgname, cllist, varargin{:});
            cllist = ensureCell(p.Results.cllist);
                             
            this              = mlsystem.Newcl;
            cinfo.pkg         = p.Results.pkgname;
            cinfo.fqpath      = this.prepareDirectories(cinfo.pkg, 'src');
            cinfo.name        = this.queryname(     cinfo, cllist{1});
            if (length(cllist) > 1)
                cinfo.subname =  cllist(2:end); end
            cinfo.summary     = this.querysummary(  cinfo, p.Results.summary);
            cinfo.ctorUsage   = this.queryctorusage(cinfo, p.Results.ctorUsage);
            this.classInfo    =                     cinfo;
            cstatus           = this.assemblecl;
        end        
        function [cstatus,this] = maketests(pkgname, cllist)
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
            cinfo.fqpath    = this.prepareDirectories(pkgname, 'test');
            cinfo.name      = this.queryname(cinfo,  cllist{1});
            cinfo.subname   = 'matlab.unittest.TestCase';
            cinfo.summary   = '';
            cinfo.ctorUsage = '';
            this.classInfo  = cinfo;
            cstatus         = this.assembletest;
        end     
        function [cstatus,tstatus,cl,tests] = makeall(pkgname, cllist, varargin)
            %% MAKEALL guides writing a new class file and test file from templates
            %  Usage:  Newcl.makeall(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            %                                    ^ prefix "Test_" added as needed
            
            [cstatus,cl]    = mlsystem.Newcl.makecl(   pkgname, cllist, varargin{:});            
            [tstatus,tests] = mlsystem.Newcl.maketests(pkgname, cllist);
        end
                
        function [stat,this] = makeBuilder(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeCommand(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeComposite(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeDecorator(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeInterface(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeIterator(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeMemento(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeSingleton(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeState(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeStrategy(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function [stat,this] = makeVisitor(pkgname, cllist, varargin)
            [stat,this] = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
    end
    
    methods %% GET
        function p = get.packageHome(this) %#ok<MANU>
            p = fullfile(getenv('HOME'), 'MATLAB-Drive', '');
        end
        function v = get.verbose(this) %#ok<MANU>
            v = ~isempty(getenv('VERBOSE'));
        end
    end
    
    %% PRIVATE 
    
    properties (Constant, Access = 'private')
        EXT = '.m';
    end
    
    methods (Static, Access='private')
        
        function s     = continueComment(ntabs, commentCells)
            %% CONTINUECOMMENT formats a cell-array of strings to continue a comment to multiple lines;
            %                  use no tabs, no %-marks, no end-of-lines
            %  Usage:  s = continueComment(ntabs, commentCells)
            %          ^ string            ^ # of tabs of indentation
            %                                     ^ string or cell
            
            assert(isnumeric(ntabs));
            commentCells = ensureCell(commentCells);
                frmt = '%s\n';
            for t = 1:ntabs %#ok<*FORPF>
                frmt = [frmt '\t']; %#ok<*AGROW>
            end
                frmt0 = frmt;
            for c = 2:length(commentCells) %#ok<*FORFLG>
                frmt = [frmt '%   ' frmt0];
            end
            s = sprintf(frmt, commentCells{:});
        end 
        function strng = classInheritance(cinfo)
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
        function strng = funInheritance(cinfo)
            assert(isstruct(cinfo));
            if (isfield(cinfo, 'subname'))
                if (iscell(cinfo.subname))
                    parent = cinfo.subname{1};
                else
                    parent = cinfo.subname;
                end
                strng = sprintf('this = this@%s%s', parent, '(varargin{:});');
            else
                strng = '';
            end
        end
    end
    
    methods (Access='private')
        
        function this      = Newcl
        end % ctor        
        function sdir      = prepareDirectories(this, pkgnam, srctype)
            %% PREPAREDIRECTORIES create package, src or test directories as needed
            
            switch (lower(srctype))
                case 'src'
                    plusdir = ['+' pkgnam];
                case 'test'
                    plusdir = ['+' pkgnam '_unittest'];
                otherwise
                    error('mfiles:UnsupportedParamValue', 'Newcl.preFilesystem.srctype->%s\n', srctype);
            end            
            sdir = fullfile(this.packageHome, pkgnam, srctype, plusdir, '');
            if (~exist(sdir, 'dir')); mkdir(sdir); end        
        end 
        function clname    = queryname(this, cinfo, clname)
            %% QUERYNAME determines a classname, querying user if the classname already exists
            %  clname = queryname(this, classInfo, clname)
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
                    clname = char(inputdlg(' New class name? ', 'Newcl.queryname', 1, {clname}));
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
        function clsummary = querysummary(this, cinfo, clsummary) %#ok<INUSL>
            %% QUERYSUMMARY presents a dialogue box
            
            assert(~isempty(cinfo.name));
            while (isempty(clsummary))
                clsummary = inputdlg( ...
                {sprintf(' Please summarize the class %s: ', cinfo.name), ' cont ...', ''}, ...
                          'Newcl.querysummary', [1 80; 1 80; 1 80 ], {'', '', ''});
                clsummary = mlsystem.Newcl.continueComment(1, clsummary);
            end
            assert(ischar(clsummary));
        end
        function ctorusage = queryctorusage(~, cinfo, ctorusage)
            if (isempty(ctorusage))
                ctorusage = sprintf('Usage:  this = %s()', cinfo.name); end
        end
        function status    = assemblecl(this)
            % ASSEMBLECL
            
            import mlsystem.*;            
            this.classNotes = this.topClassNotes(this.ctorHints);            
            this.propsig = ...
                sprintf('\t%s\n \t\t%s\n \t%s\n\n', ...
                'properties', this.propertyHints, 'end');     
            this.methsig = ...
                sprintf('\tmethods \n\t\t %s \n %s \tend \n\n', ...
                this.methodHints, this.ctorSig);
            this.privatePropsig = '';
            this.privateMethsig = '';            
            status = this.writecl;
        end
        function str       = ctorSig(this)
            if (strcmp(this.classInfo.name(1), 'I'))
                str = '';
                return
            end 
            cinfo = this.classInfo; 
            str = sprintf( ...
                '\t\t%s %s\n \t\t\t%s %s\n \t\t\t%s %s\n\n \t\t\t%s\n \t\t%s\n', ...
                'function', ['this = ' cinfo.name '(varargin)'], ...
                '%%', upper(cinfo.name), ...
                '% ', cinfo.ctorUsage, ...
                mlsystem.Newcl.funInheritance(cinfo), 'end');           
            return
        end
        function str       = ctorHints(this)
            str = '';
            if (this.verbose)
                str = '%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)'; 
            end
        end
        function str       = propertyHints(this)
            str = '';
            if (this.verbose)
                str = '% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, Constant, Dependent, Hidden, Transient)'; 
            end
        end
        function str       = methodHints(this)
            str = '';
            if (this.verbose)
                str = '% N.B. (Static, Abstract, Access='''', Hidden, Sealed)'; 
            end
        end
        function status    = assembletest(this)
            % ASSEMBLETEST
            
            import mlsystem.*;            
            cinfo = this.classInfo;            
            testusage   = ...
                sprintf('\t%s%s_unittest.%s%s\n \t%s%s_unittest.%s%s\n \t%s\n\n', ...
                '%  Usage:  >> results = run(', cinfo.pkg, cinfo.name, ')', ...
                '%          >> result  = run(', cinfo.pkg, cinfo.name, ', ''test_dt'')', ...
                '%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html');
            this.classNotes = [testusage this.topClassNotes];            
            this.propsig = ...
                sprintf('\t%s\n \t\t%s\n \t\t%s\n \t%s\n\n', ...
                'properties', 'registry', 'testObj', 'end'); 
            setupSig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', ['setup' cinfo.name(6:end) '(this)'], ...
                ['import ' cinfo.pkg '.*;'], ...
                ['this.testObj_ = ' cinfo.name(6:end) ';'], 'end');  
            setupTestSig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', ['setup' cinfo.name(6:end) 'Test(this)'], ...
                'this.testObj = this.testObj_;', 'this.addTeardown(@this.cleanFiles);', 'end');  
            funsig = ...
                sprintf('\t\t%s %s\n \t\t\t%s\n \t\t\t%s\n \t\t\t%s\n \t\t\t%s\n \t\t%s\n', ...
                'function', 'test_afun(this)', ...
                ['import ' cinfo.pkg '.*;'] , ...
                'this.assumeEqual(1,1);', ...
                'this.verifyEqual(1,1);', ...
                'this.assertEqual(1,1);', 'end');  
            this.methsig = ...
                sprintf('\t%s\n%s\t%s\n\n \t%s\n%s\t%s\n\n \t%s\n%s\t%s\n\n', ...
                'methods (Test)', funsig, 'end', ...
                'methods (TestClassSetup)', setupSig, 'end', ...
                'methods (TestMethodSetup)', setupTestSig, 'end');  
            this.privatePropsig = ...
                sprintf('\t%s\n \t\t%s\n \t%s\n\n', ...
                'properties (Access = private)', 'testObj_', 'end');  
            privateFunsig = ...
                sprintf('\t\t%s %s\n \t\t%s\n', ...
                'function', 'cleanFiles(this)', 'end'); 
            this.privateMethsig = ...
                sprintf('\t%s\n%s\t%s\n\n', ...
                'methods (Access = private)', privateFunsig, 'end');
            
            status = this.writecl;
        end 
        function str       = preamble(this)
            cinfo = this.classInfo;
            str = sprintf('classdef %s %s\n\t%s %s %s\n\n', ...
                        cinfo.name, mlsystem.Newcl.classInheritance(cinfo), '%%', upper(cinfo.name), cinfo.summary);    
        end
        function str       = topClassNotes(this, varargin)
            % TODO:  use continueComment
            
            ip = inputParser;
            addOptional(ip, 'classHints', '', @ischar);
            parse(ip, varargin{:});
            
            str = sprintf('\t%s\n \t%s\n \t%s\n \t%s\n \t%s\n', ...                
                 '%  $Revision$', ...
                ['%  was created ' datestr(now) ' by ', getenv('USER') ','], ...
                ['%  last modified $LastChangedDate$ and placed into repository ' this.classInfo.fqpath '.'], ...
                ['%% It was developed on Matlab ' version ' for ' computer '.  Copyright ' num2str(datetime('today').Year) ' John Joowon Lee.'], ... 
                ip.Results.classHints);  
        end
        function str       = closing(~)
            str = sprintf('\t%s\n end\n\n', ...
                '%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy');
        end
        function status    = writecl(this)
            fqfn   = fullfile(this.classInfo.fqpath, [this.classInfo.name this.EXT]);
            fid    = fopen(fqfn,'w');
            fprintf( fid, '%s%s%s%s%s%s%s%s', ...
                     this.preamble,       this.classNotes, ...
                     this.propsig,        this.methsig, ...
                     this.privatePropsig, this.privateMethsig, this.closing);
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
                error('mlsystem:IOErr', 'Newcl.writecl: problems closing file->%s', fqfn);
            end
        end
        
    end % private methods
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end
