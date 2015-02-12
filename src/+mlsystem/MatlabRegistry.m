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
            'mlaif'      'mlanalysis'   'mlaveraging'  'mlbayesian'  'mlbet'       'mlcaster'    'mlct' 'mlchoosers' ...
            'mldb'       'mlentropy'    'mlfourd'      'mlfsl'       'mlio'        'mlkety' ...
            'mlmr'       'mlnest'       'mlniftitools' 'mlparallel'  'mlpatterns'  'mlperfusion' 'mlpet' ...
            'mlpipeline' 'mlpublish'    'mlrois'       'mlsurfer'    'mlsystem'    'mlunpacking' ...
            'mlusmle'    'mlstep2cs'    'mlarbelaez' };
        MLV_SERIAL = '7_9';
    end
    
    properties
        dipcommon = '/opt/dip/common/';
        dipos
        docroot
        fslroot   = '/usr/local/fsl/';
        homeroot
        llpenv
        mexroot
        srcroot
        randstream
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
            this.setSrcPath();
            this.setTestPath();
            this.setMexPath();
            this.setFslPath();
            % this.setDip();
        end
        function setDip(this)
            %if (isempty(strfind(path, this.dipcommon)))
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
            %end
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
            path( ...
                fullfile(this.srcroot,  'mlcvl/mlniftitools/global'), path);
            if (isempty(strfind(path, this.fslroot(1:end-1))))
                path(...
                    fullfile(this.fslroot,  'etc/matlab'), path);
            end
        end
        function setMexPath(this)
            if (isempty(strfind(path, this.mexroot(1:end-1))))
                path(this.mexroot, path);
            end
        end
        function setTestPath(this)
            if (isempty(strfind(path, 'mlniftitools/tests')))
                assert(~verLessThan('matlab', '7.11.0'));
                path(fullfile(this.srcroot, 'mlcvl/mlniftitools/test'), path);
                for p = 1:length(this.MLPACKAGES) %#ok<*FORFLG>
                    path(fullfile(this.srcroot, 'mlcvl', this.MLPACKAGES{p}, 'test'), path);
                end
            end
        end
        function setSrcPath(this)
            if (isempty(strfind(path, 'mfiles')))
                assert(~verLessThan('matlab', '7.11.0'));
                path([...
                    fullfile(this.srcroot, 'mlcvl/dicom_sort_convert/src') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/dicom_spectrum/src') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/export_fig') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/explorestruct') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/lutbar') pathsep ... 
                    fullfile(this.srcroot, 'mlcvl/mfiles') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/mlniftitools/src/') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/StructBrowser') pathsep ...
                    fullfile(this.srcroot, 'mlcvl/xml_io_tools') ...
                    ], path);
                for p = 1:length(this.MLPACKAGES) %#ok<*FORFLG>
                    path(fullfile(this.srcroot, 'mlcvl', this.MLPACKAGES{p}, 'src'), path);
                end
            end
        end        
        function clear(this)
            this.delete;
            clear(this);
        end
    end
    
    methods (Access=private)        
        function this = MatlabRegistry()
            if (exist(          '/Library/Documentation/Applications/','dir'))
                this.docroot = '/Library/Documentation/Applications/';
            elseif (exist(       [getenv('HOME') '/Library/Documentation/Applications/'],'dir'))
                this.docroot = [getenv('HOME') '/Library/Documentation/Applications/'];
            end
            switch (computer('arch'))
                case 'maci64'
                    this.llpenv       = 'DYLD_LIBRARY_PATH';
                    this.dipos = '/opt/dip/Darwin/';
                case {'glnxa64' 'glnx86'}
                    this.llpenv       =   'LD_LIBRARY_PATH';
                    this.dipos = '/opt/dip/Linux/';
                otherwise
                    error('mlsystem:NotImplemented', 'MatlabRegistry.ctor.computer() -> %s\n', computer('arch'));
            end
            this.homeroot   = [getenv('HOME') '/'];
            this.mexroot    = fullfile(this.homeroot, 'Local/mex/');
            this.srcroot    = fullfile(this.homeroot, 'Local/src/');
            this.randstream = RandStream('mt19937ar','seed',sum(100*clock));
            RandStream.setGlobalStream(this.randstream);
        end
    end
end
