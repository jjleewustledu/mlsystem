classdef (Sealed) MatlabRegistry < mlsystem.MatlabSingleton
    %SINGLETONIMPL Concrete Implementation of Singleton OOP Design Pattern
    %   Refer to the description in the abstract superclass Singleton for
    %   full detail.
    %   This class serves as a template for constructing your own custom
    %   classes.
    %
    %   Written by Bobby Nedelkovski
    %   The MathWorks Australia Pty Ltd
    %   Copyright 2009, The MathWorks, Inc.
    
    properties (Constant)
        MLPACKAGES = {  ...
            'dicm2nii' ...
            'mlaif'       'mlan'       'mlanalysis'  'mlarbelaez' 'mlarchitect'  'mlaveraging' 'mlbayesian' 'mlcaster' ...
            'mlct'        'mlchoosers' 'mlderdeyn'   'mldb'       'mldistcomp'   'mlentropy'   'mlfourd'    'mlfourdfp'  'mlfsl' ...
            'mlio'        'mlkety'     'mlkinetics'  'mlmr'       'mlniftitools' 'mlnest'      'mlparallel' 'mlpatterns' ...
            'mlperfusion' 'mlpet'      'mlpipeline'  'mlpowers'   'mlpublish'    'mlraichle'   'mlrois'     'mlsiemens' ...
            'mlstep2cs'   'mlsurfer'   'mlsystem'    'mltvd'      'mlunpacking'  'mlusmle'     'mlblazey' ...
            'mldata'} 
        MLV_SERIAL = '7_9'
        MIN_VERSION = '7.11.0'
    end
    
    properties
        dipcommon = '/opt/dip/common/';
        dipos
        docroot
        fslroot
        homeroot
        llpenv
        matlabProcessManagerRoot
        matlabStanRoot
        mexroot
        psisRoot
        srcroot
        randstream
        useDip    = false;
    end
    
    methods (Static)
        function this = instance(qualifier)
            %% INSTANCE uses string qualifiers to implement registry behavior that
            %  requires access to the persistent uniqueInstance
            
            persistent uniqueInstance
            
            if (exist('qualifier','var') && ischar(qualifier))
                switch (qualifier)
                    case 'initialize'
                        uniqueInstance = [];
                    case 'clear'
                        clear uniqueInstance;
                        return;
                    case 'delete'
                        if (~isempty(uniqueInstance))
                            uniqueInstance.delete;
                            return;
                        end
                end
            end
            
            if (isempty(uniqueInstance))
                this = mlsystem.MatlabRegistry();
                uniqueInstance = this;
            else
                this = uniqueInstance;
            end
        end
    end
    
    methods
        function startup(this)
            if (isdeployed)
                return; end
            this.setSrcPath();
            this.setTestPath();
            this.setMexPath();
            this.setFslPath();
            this.setStanPath();
            if (this.useDip)
                this.setDip(); end
        end
        function setDip(this)
            path([...
                fullfile(this.dipcommon, 'dipimage') pathsep ...
                fullfile(this.dipcommon, 'dipimage/demos') pathsep ...
                fullfile(this.dipcommon, 'dipimage/aliases') pathsep ...
                fullfile(this.dipos,     'include') pathsep ...
                fullfile(this.docroot,   'diplib')], path);
            
            dipllp = [...
                fullfile(this.dipcommon,['mlv' this.MLV_SERIAL '/dipimage_mex']) pathsep ...
                fullfile(this.dipcommon,['mlv' this.MLV_SERIAL '/diplib']) pathsep ...
                fullfile(this.dipcommon,['mlv' this.MLV_SERIAL '/diplib_dbg']) pathsep ...
                fullfile(this.dipos,     'lib')];
            setenv(this.llpenv, [dipllp pathsep getenv(this.llpenv)]);
            try
                dip_initialise
                dipsetpref('CommandFilePath',[this.srcroot, 'mlcvl/dipcommands']);
                dipsetpref('imagefilepath',   pwd);
            catch ME
                [s, s1] = system(['echo $' this.llpenv]);
                disp(['startup:  dip_initialise failed; check validity of ' this.llpenv]);
                disp(['          status -> ' num2str(s)]);
                disp(['         ' this.llpenv ' -> '  s1]);
                handwarning(ME);
            end
        end
        function setFslPath(this)
            if (~contains(path, this.fslroot(1:end-1)) && ~isempty(this.fslroot(1:end-1)))
                path(fullfile(this.fslroot,  'etc/matlab'), path);
            end
        end
        function setMexPath(this)
            if (~contains(path, this.mexroot(1:end-1)))
                path(this.mexroot, path);
            end
        end
        function setSrcPath(this)
            assert(~verLessThan('matlab', this.MIN_VERSION));
            path([...
                fullfile(this.srcroot, 'mlcvl/dicom_sort_convert/src') pathsep ...
                fullfile(this.srcroot, 'mlcvl/dicom_spectrum/src') pathsep ...
                fullfile(this.srcroot, 'mlcvl/export_fig') pathsep ...
                fullfile(this.srcroot, 'mlcvl/explorestruct') pathsep ...
                fullfile(this.srcroot, 'mlcvl/lutbar') pathsep ... 
                fullfile(this.srcroot, 'mlcvl/mfiles') pathsep ...
                fullfile(this.srcroot, 'mlcvl/f2matlab') pathsep ...
                fullfile(this.srcroot, 'mlcvl/StructBrowser') pathsep ...
                fullfile(this.srcroot, 'mlcvl/xml_io_tools') ...
                ], path);
                %fullfile(this.srcroot, 'mlcvl/mlniftitools/global') pathsep ...
            for p = 1:length(this.MLPACKAGES) %#ok<*FORFLG>
                srcPth = fullfile(this.srcroot, 'mlcvl', this.MLPACKAGES{p}, 'src');
                if (~contains(path, srcPth))
                    path(srcPth, path);
                end
            end
        end
        function setStanPath(this)
            if (~contains(path, this.matlabProcessManagerRoot(1:end-1)))
                path(this.matlabProcessManagerRoot, path);
            end
            if (~contains(path, this.matlabStanRoot(1:end-1)))
                path(this.matlabStanRoot, path);
            end
            if (~contains(path, this.psisRoot(1:end-1)))
                path(this.psisRoot, path);
            end
        end
        function setTestPath(this)
            assert(~verLessThan('matlab', this.MIN_VERSION));
            for p = 1:length(this.MLPACKAGES) %#ok<*FORFLG>    
                testPth = fullfile(this.srcroot, 'mlcvl', this.MLPACKAGES{p}, 'test');
                if (~contains(path, testPth))
                    path(testPth, path);
                end
            end
        end    
        function clear(this)
            this.delete;
            clear(this);
        end
    end
    
    %% PRIVATE
    
    methods (Access=private)        
        function this = MatlabRegistry()
            if (exist(         '/Library/Documentation/Applications/','dir'))
                this.docroot = '/Library/Documentation/Applications/';
            elseif (exist(     [getenv('HOME') '/Library/Documentation/Applications/'],'dir'))
                this.docroot = [getenv('HOME') '/Library/Documentation/Applications/'];
            end
            switch (computer('arch'))
                case 'maci64'
                    this.llpenv = 'DYLD_LIBRARY_PATH';
                    this.dipos  = '/opt/dip/Darwin/';
                case {'glnxa64' 'glnx86'}
                    this.llpenv =   'LD_LIBRARY_PATH';
                    this.dipos  = '/opt/dip/Linux/';
                case 'win64'
                otherwise
                    warning('mlsystem:NotImplemented', 'MatlabRegistry.ctor.computer() -> %s\n', computer('arch'));
            end
            this.fslroot                  = [getenv('FSLDIR') '/'];
            this.homeroot                 = [getenv('HOME') '/'];
            this.mexroot                  = fullfile(this.homeroot, 'Local/mex/');
            this.srcroot                  = fullfile(this.homeroot, 'Local/src/');
            this.matlabProcessManagerRoot = fullfile(this.srcroot,  'mlcvl/MatlabProcessManager/');
            this.matlabStanRoot           = fullfile(this.srcroot,  'mlcvl/MatlabStan-2.15.1.0/');
            this.psisRoot                 = fullfile(this.srcroot,  'mlcvl/MatlabStan-2.15.1.0/psis/');
        end
    end
end
