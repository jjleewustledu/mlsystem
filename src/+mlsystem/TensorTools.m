classdef TensorTools 
	%% TENSORTOOLS  

	%  $Revision$
 	%  was created 02-Feb-2017 16:14:55
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlsystem/src/+mlsystem.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64. 	

	
    properties
        resizable
    end
    
    methods
        function this = TensorTools(varargin)
            ip = inputParser;
            addOptional(ip, 'resizable', true, @islogical);
            parse(ip, varargin{:});
            this.resizable = ip.Results.resizable;
        end
        
        function [times,f] = shiftTensor(this, times, f, Dt)
            if (Dt > 0)
                [times,f] = this.shiftTensorRight(times, f, Dt);
                return
            end
            if (Dt < 0)
                [times,f] = this.shiftTensorLeft( times, f, Dt);
                return
            end
        end
        function [times,f] = shiftTensorLeft(this, times0, f0, Dt)
            %  Dt in sec
            assert(4 == length(size(f0)));
                
            Dt    = abs(Dt);            
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = len0 - lenDt;
            
            if (this.resizable)
                times = times0(1:len1);
                f     = f0(:,:,:,lenDt+1:end);
                return
            end            
            times                = times0;
            f                    = f0(:,:,:,end).*ones(size(f0));
            f(:,:,:,1:end-lenDt) = f0(:,:,:,lenDt+1:end);
        end
        function [times,f] = shiftTensorRight(this, times0, f0, Dt)
            %  Dt in sec
            assert(4 == length(size(f0)));
            
            Dt    = abs(Dt);
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = lenDt + len0;
            
            if (this.resizable)
                times1 = times0(end)+dt0:dt0:times0(end)+dt0*lenDt;
                times  = [times0 times1];  
                szf0   = size(f0);
                f      = f0(:,:,:,1).*ones(szf0(1),szf0(2),szf0(3),len1);
                f(:,:,:,end-len0+1:end) = f0;
                return
            end            
            times                = times0;
            f                    = f0(:,:,:,1).*ones(size(f0));
            f(:,:,:,lenDt+1:end) = f0(:,:,:,1:end-lenDt);
        end
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

