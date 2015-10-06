classdef Newcl
    %% NEWCL is a factory for preformatted Matlab class files
    %  Usage:  Newcl.makecl    % static factories
    %          Newcl.maketests
    %          Newcl.makeall
    
    %  Version $Revision$ was created $Date$ by $Author$
    %  and checked into svn repository $URL$
    %  Developed on Matlab 7.10.0.499 (R2010a)
    %  $Id$
    
    properties
        classInfo
        preamble
        classSummary
        classNotes
        propsig
        methsig
        closing
    end
    
    properties (Dependent)
        packageHome
        verbose
    end
    
    methods (Static)
        function [this,cstatus] = makecl(pkgname, cllist, varargin)
            %% MAKECL guides writing a new subclassed file from templates
            %  Usage:  Newcl.makecl(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            
            p = inputParser;
            addRequired(p, 'pkgname', @ischar);
            addRequired(p, 'cllist',  @(x) ischar(x) || iscell(x));
            addOptional(p, 'summary', ' ', @ischar);
            addOptional(p, 'ctorUsage',  '', @ischar);
            parse(p, pkgname, cllist, varargin{:});
            cllist = ensureCell(p.Results.cllist);
                             
            this           = mlsystem.Newcl;
            inf.pkg        = p.Results.pkgname;
            inf.fqpath     = this.prepareDirectories(inf.pkg, 'src');
            inf.name       = this.queryname(     inf, cllist{1});
            if (length(cllist) > 1)
                inf.subname =  cllist(2:end); end
            inf.summary    = this.querysummary(  inf, p.Results.summary);
            inf.ctorUsage  = this.queryctorusage(inf, p.Results.ctorUsage);
            this.classInfo =                     inf;
            cstatus        = this.assemblecl;
        end        
        function [this,cstatus] = maketests(pkgname, cllist)
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
            
            this           = mlsystem.Newcl;
            inf.pkg        = p.Results.pkgname;
            inf.fqpath     = this.prepareDirectories(pkgname, 'test');
            inf.name       = this.queryname(inf,  cllist{1});
            inf.subname    = 'matlab.unittest.TestCase';
            inf.summary    = '';
            inf.ctorUsage  = '';
            this.classInfo = inf;
            cstatus        = this.assembletest;
        end     
        function [cl,tests] = makeall(  pkgname, cllist, varargin)
            %% MAKEALL guides writing a new class file and test file from templates
            %  Usage:  Newcl.makeall(pkgname, [{]classname [[pkgname2.]classname2}, classSummary, ctorUsage])
            %                                    ^ prefix "Test_" added as needed
            
            cl    = mlsystem.Newcl.makecl(   pkgname, cllist, varargin{:});            
            tests = mlsystem.Newcl.maketests(pkgname, cllist);
        end
                
        function this       = makeBuilder(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeCommand(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeComposite(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeDecorator(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeInterface(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeIterator(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeMemento(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeSingleton(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeState(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeStrategy(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
        function this       = makeVisitor(pkgname, cllist, varargin)
            this = mlsystem.Newcl.makecl(pkgname, cllist, varargin{:});
        end
    end
    
    methods %% GET
        function p = get.packageHome(this) %#ok<MANU>
            p = fullfile(getenv('HOME'), 'Local/src/mlcvl', '');
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
        function strng = classInheritance(classInfo)
            assert(isstruct(classInfo));
            if (isfield(classInfo, 'subname'))
                if (iscell(classInfo.subname))
                    for s = 1:length(classInfo.subname)-1
                        classInfo.subname{s} = [classInfo.subname{s} ' & '];
                    end
                    parents = [classInfo.subname{:}];
                else
                    parents = classInfo.subname;
                end
                strng = sprintf('< %s', parents);
            else
                strng = '';
            end
        end
        function strng = funInheritance(classInfo)
            assert(isstruct(classInfo));
            if (isfield(classInfo, 'subname'))
                if (iscell(classInfo.subname))
                    parent = classInfo.subname{1};
                else
                    parent = classInfo.subname;
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
        function clname    = queryname(     this, classInfo, clname)
            %% QUERYNAME determines a classname, querying user if the classname already exists
            %  clname = queryname(this, classInfo, clname)
            %                           ^ struct
            %                                  ^ string
            
            fqfn = [fullfile(classInfo.fqpath, clname) this.EXT];
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
                fqfn = [fullfile(classInfo.fqpath, clname) this.EXT];
            end
            assert(ischar(clname));
        end 
        function clsummary = querysummary(  this, classInfo, clsummary) %#ok<INUSL>
            %% QUERYSUMMARY
            
            assert(~isempty(classInfo.name));
            while (isempty(clsummary))
                clsummary = inputdlg( ...
                {sprintf(' Please summarize the class %s: ', classInfo.name), ' cont ...', ''}, ...
                          'Newcl.querysummary', [1 80; 1 80; 1 80 ], {'', '', ''});
                clsummary = mlsystem.Newcl.continueComment(1, clsummary);
            end
            assert(ischar(clsummary));
        end
        function ctorusage = queryctorusage(~,    inf,       ctorusage)
            if (isempty(ctorusage))
                ctorusage = sprintf('Usage:  this = %s()', inf.name); end
        end
        function status    = assemblecl(this)
            % ASSEMBLECL
            % TODO:  use continueComment
            
            import mlsystem.*;
            
            cinfo  = this.classInfo;
            this.preamble = ...
                sprintf('classdef %s %s \n', cinfo.name, Newcl.classInheritance(cinfo));    
            this.classSummary = ...
                sprintf('\t%s %s %s \n\n', '%%', upper(cinfo.name), cinfo.summary);

            chints = '';
            if (this.verbose)
                chints = '%  N.B. classdef (Sealed, Hidden, InferiorClasses = {?class1,?class2}, ConstructOnLoad)'; end
            this.classNotes = ...
                sprintf( ...
                '\t%s \n \t%s \n \t%s \n \t%s \n \t%s \n \t%s%s \n \t%s \n \t%s \n\n', ...                
                '%  $Revision$', ...
                '%  was created $Date$', ...
                '%  by $Author$, ', ...
                '%  last modified $LastChangedDate$', ...
                '%  and checked into repository $URL$, ', ...
                '%  developed on Matlab ', version, ...
                '%  $Id$', chints);  
            
            phints = '';
            if (this.verbose)
                phints = '% N.B. (Abstract, Access=private, GetAccess=protected, SetAccess=protected, Constant, Dependent, Hidden, Transient)'; end
            this.propsig = ...
                sprintf('\tproperties \n \t\t%s \n \tend \n\n', phints);
            
            ctorsig = ...
                sprintf( ...
                '\t\tfunction this = %s(varargin) \n \t\t\t%s %s \n \t\t\t%s %s \n\n \t\t\t%s \n \t\tend \n', ...
                cinfo.name, ...
                '%%', upper(cinfo.name), ...
                '% ', cinfo.ctorUsage, ...
                Newcl.funInheritance(cinfo));
            
%            funsig = ...
%                sprintf('\t\tfunction afun(this) \n \t\tend \n');
            
            mhints = '';
            if (this.verbose)
                mhints = '% N.B. (Static, Abstract, Access='''', Hidden, Sealed)'; end
            this.methsig = ...
                sprintf('\tmethods \n\t\t %s \n %s \tend \n\n', ...
                mhints, ctorsig);
%                 sprintf('\tmethods \n \t\t%s \n\n %s %s \tend \n\n', ...
%                 mhints, ...
%                 funsig, ctorsig);
            
            this.closing = ...
                sprintf('\t%s \nend\n\n', ...
                '%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy');

            status = this.writecl(cinfo);
        end
        function status    = assembletest(this)
            % ASSEMBLETEST
            % TODO:  use continueComment
            
            import mlsystem.*;            
            cinfo  = this.classInfo;
            
            this.preamble = ...
                sprintf('classdef %s %s \n', cinfo.name, Newcl.classInheritance(cinfo));    
            this.classSummary = ...
                sprintf('\t%s %s %s \n\n', '%%', upper(cinfo.name), cinfo.summary);
            
            testusage   = ...
                sprintf('\t%s%s_unittest.%s%s\n \t%s%s_unittest.%s%s\n \t%s\n\n', ...
                '%  Usage:  >> results = run(', cinfo.pkg, cinfo.name, ')', ...
                '%          >> result  = run(', cinfo.pkg, cinfo.name, ', ''test_dt'')', ...
                '%  See also:  file:///Applications/Developer/MATLAB_R2014b.app/help/matlab/matlab-unit-test-framework.html');            
            this.classNotes = ...
                sprintf( ...
                '\t%s \n \t%s \n \t%s \n \t%s \n \t%s \n \t%s%s \n \t%s \n\n', ...                
                '%  $Revision$', ...
                '%  was created $Date$', ...
                '%  by $Author$, ', ...
                '%  last modified $LastChangedDate$', ...
                '%  and checked into repository $URL$, ', ...
                '%  developed on Matlab ', version, ...
                '%  $Id$');
            this.classNotes = [testusage this.classNotes];   
            
            this.propsig = ...
                sprintf('\tproperties \n \t\ttestObj \n \tend \n\n');
                       
            funsig = ...
                sprintf('\t\tfunction test_afun(this) \n \t\t\timport %s.*; \n \t\t\t%s \n \t\t\t%s \n \t\t\t%s \n \t\tend \n', ...
                cinfo.pkg, ...
                'this.assumeEqual(1,1);', ...
                'this.verifyEqual(1,1);', ...
                'this.assertEqual(1,1);'); 
            setupsig = ...
                sprintf('\t\tfunction %s(this) \n \t\t\t%s \n \t\tend \n', ...
                ['setup' cinfo.name(6:end)], ...
                ['this.testObj = ' cinfo.pkg '.' cinfo.name(6:end) ';']);            
            this.methsig = ...
                sprintf('\tmethods (Test) \n %s \tend \n\n \tmethods (TestClassSetup) \n %s \tend \n\n \tmethods (TestClassTeardown) \n \tend \n\n', ...
                funsig, setupsig);
            
            this.closing = ...
                sprintf('\t%s \n end \n\n', ...
                '%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy');

            status = this.writecl(cinfo);
        end 
        function status    = writecl(this, cinfo)
            fqfn   = fullfile(cinfo.fqpath, [cinfo.name this.EXT]);
            fid    = fopen(fqfn,'w');
            fprintf( fid, '%s%s%s%s%s%s%s', ...
                     this.preamble, this.classSummary, this.classNotes, this.propsig, this.methsig, this.closing);
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
                error('mfiles:IOErr', 'Newcl.writecl: problems closing file->%s', fqfn);
            end
        end
        
    end % private methods
    
    %  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end
