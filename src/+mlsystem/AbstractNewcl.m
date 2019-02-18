classdef AbstractNewcl < mlsystem.NewclInterface
	%% ABSTRACTNEWCL   
    %
	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.3.0.532 (R2014a) 
 	%  $Id$  	 

	properties (Dependent)
        classSummary
        closing
        ctorInheritance
        ctorSignature
        ctorUsage
        packageHome
        packageName
        preamble
        verbose 		 
    end 

    methods
        function s = classInheritance(this)
            if (isempty(this.superClassNames))
                s = ''; return; end
            scn = this.superClassNames;
            for n = 1:length(scn)-1
                scn{n} = [scn{n} ' & ']; end
            s = ['< ' scn{:}];
        end
        function n = className(this)
            assert(~isempty(this.className_));
            n = this.className_;
        end
        function s = classSignature(this)
            preamble = sprintf( ...
                'classdef %s %s\n', this.className, this.classInheritance);
            cidentifiers = sprintf( ...
                '\t%%%% %s %s\n', upper(this.className), this.classSummary);
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
            s = [preamble cidentifiers cnotes];
        end
        function f = fqpath(this)
            f = fullfile(this.packageHome, this.packageName, 'src', ['+' this.packageName], '');
        end
        function s = functionSignature(this)
            s = sprintf( ...
                '\t\tfunction this = afun(this) \n\t\t\timport %s.*; \n\t\tend \n', ...
                this.packageName);
        end
        function s = methodsSignature(this)
            s = sprintf( ...
                '\tmethods \n\t\t%s \n\n %s %s \tend \n\n', ...
                '% N.B. (Abstract, Access=''protected'', Hidden, Sealed, Static)', ...
                this.functionSignature, this.ctorSignature);
        end
        function s = propertiesSignature(this) %#ok<MANU>
            s = sprintf( ...
                '\tproperties \n\t\t%s \n\tend \n\n', ...
                '% N.B. (Abstract, Access=''private'', GetAccess=''protected'', SetAccess=''protected'', Constant, Dependent, Hidden, Transient)');
        end
        function n = superClassNames(this)
            n = this.superClassNames_;
        end
    end
    
    methods %% GET/SET
        function s    = get.classSummary(this)
            assert(~isempty(this.classSummary_));
            s = this.classSummary_;
        end
        function s    = get.closing(this) %#ok<MANU>
            s = sprintf('\t%s \nend\n\n', ...
                '%  Created with NewClassStrategy by John J. Lee, after newfcn by Frank Gonzalez-Morphy');
        end
        function s    = get.ctorInheritance(this)
            if (isempty(this.superClassNames))
                s = ''; return; end
            s = sprintf('this = this@%s%s', this.superClassNames{1}, '(varargin{:});');
        end
        function s    = get.ctorSignature(this)
            arguments = '';
            if (~isempty(this.ctorInheritance))
                arguments = '(varargin)'; end
            s = sprintf( ...
                '\t\tfunction this = %s%s \n\t\t\t%%%% %s \n\t\t\t%%  %s \n\n\t\t\t%s\n\t\tend \n', ...
                this.className, ...
                arguments, ...
                upper(this.className), ...
                this.ctorUsage, ...
                this.ctorInheritance);
        end
        function s    = get.ctorUsage(this)
            s = this.ctorUsage_;
        end
        function p    = get.packageHome(this) %#ok<MANU>
            p = fullfile(getenv('HOME'), 'MATLAB-Drive', '');
        end   
        function this = set.packageName(this, n)
            this.packageName_ = char(n);
           if (~lexist(fullfile(this.packageHome, n, '')))
               fprintf('\nREMINDER:  please add %s to MatlabRegistry\n\n', n);
               edit(fullfile(getenv('HOME'), 'Documents', 'MATLAB', 'MatlabRegistry.m'));
           end
        end
        function n    = get.packageName(this)
            assert(~isempty(this.packageName_));
            n = this.packageName_;
        end    
        function v    = get.verbose(this) %#ok<MANU>
            v = ~isempty(getenv('VERBOSE'));
        end
    end

    %% PROTECTED
    
    properties (Access = 'protected')
        className_
        classSummary_
        ctorUsage_
        packageName_
        superClassNames_
    end
    
    methods (Static, Access='protected')
        function s = continueComment(ntabs, commentCells)
            %% CONTINUECOMMENT formats a cell-array of strings to continue a comment to multiple lines;
            %                  include no tabs, no %-marks, no end-of-lines
            %  Usage:  s = continueComment(ntabs, commentCells)
            %          ^ string            ^ indentation
            %                                     ^ string or cell
            
            commentCells = ensureCell(commentCells);
            
            
                frmt0 = ['%s\n' printTabs(ntabs)];
                frmt  = frmt0;
            for c = 2:length(commentCells) %#ok<*FORFLG>
                frmt  = [frmt '%   ' frmt0]; %#ok<AGROW>
            end
            s = sprintf(frmt, commentCells{:});
            
            function t = printTabs(ntabs)
                t = '';
                for n = 1:ntabs
                    t = [t '\t']; %#ok<AGROW>
                end
            end
        end 
    end
    
    methods (Access = 'protected')
 		function this   = AbstractNewcl(pkgnam, cllist, varargin) 
 			%% ABSTRACTNEWCL 
            %  Usage:  AbstractNewcl(pkgname, [{]classname [pkgname2.]classname2[}][, class_summary, ctor_usage])
            
            p = inputParser;
            addRequired(p, 'pkgnam', @ischar);
            addRequired(p, 'cllist',  @(x) ischar(x) || (iscell(x) && ischar(x{1})));
            addOptional(p, 'clsummary', ' ', @ischar);
            addOptional(p, 'ctorusage', ' ', @ischar);
            parse(p, pkgnam, cllist, varargin{:});
            
            this.packageName = p.Results.pkgnam;            
            this.prepareDirectories;
            cllist = ensureCell(p.Results.cllist);                             
            this.className_ = this.checkClassName(cllist{1});  
            if (length(cllist) > 1)
                this.superClassNames_ = cllist(2:end); end 
            this.classSummary_ = p.Results.clsummary;
            this.ctorUsage_ = p.Results.ctorusage;
        end 
 		function clname = checkClassName(this, clname)
            %% CHECKCLASSNAME determines a classname, querying user if the classname already exists
            %  clname = this.checkClassName(this, clname)
            %                                     ^ string
            
            clname = char(clname);
            fqfn   = fullfile(this.fqpath, [clname this.EXT]);
            opts.Interpreter = 'none'; 
            opts.Default     = 'No';
            while (exist(fqfn, 'file') || exist(clname, 'class'))
                choice = questdlg( ...
                    sprintf(' Class file %s already exists.  Overwrite? \n', fqfn),...
                             'mlsystem.AbstractNewcl', ...
                             'Yes', 'No', opts);
                if (strcmpi(choice, 'Yes'))
                    return;
                else
                    clname = char(inputdlg( ...
                        ' New class name? ', ...
                        'mlsystem.AbstractNewcl.checkName', 1, {clname}));
                    pos    = strfind(clname, this.EXT);
                    if (any(pos))
                        clname = clname(1:pos-1);
                        break;
                    end
                    if (isempty(clname))
                        paramError(?meta.class, 'clname', clname);
                    end
                end
                fqfn = fullfile(this.fqpath, [clname this.EXT]);
            end
        end 
        function          prepareDirectories(this)
            %% PREPAREDIRECTORIES create package, src or test directories as needed
            
            if (~exist(this.fqpath, 'dir'))
                mkdir(this.fqpath); end        
        end
    end 
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

