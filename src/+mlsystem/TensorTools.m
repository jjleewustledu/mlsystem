classdef TensorTools 
	%% TENSORTOOLS  

	%  $Revision$
 	%  was created 02-Feb-2017 16:14:55
 	%  by jjlee,
 	%  last modified $LastChangedDate$
 	%  and checked into repository /Users/jjlee/Local/src/mlcvl/mlsystem/src/+mlsystem.
 	%% It was developed on Matlab 9.1.0.441655 (R2016b) for MACI64. 	

	
	methods (Static)
        function [times,f] = shiftTensor(times, f, Dt)
            import mlsystem.*
            if (Dt > 0)
                [times,f] = TensorTools.shiftTensorRight(times, f, Dt);
                return
            end
            if (Dt < 0)
                [times,f] = TensorTools.shiftTensorLeft( times, f, Dt);
                return
            end
        end
        function [times,f] = shiftTensorLeft(times0, f0, Dt)
            %  Dt in sec
            Dt    = abs(Dt);            
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = len0 - lenDt;
            
            times = times0(1:len1);
            assert(4 == length(size(f0)));
            f     = f0(:,:,:,lenDt+1:end);
        end
        function [times,f] = shiftTensorRight(times0, f0, Dt)
            %  Dt in sec
            Dt    = abs(Dt);
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = lenDt + len0;
            
            times1 = times0(end)+dt0:dt0:times0(end)+dt0*lenDt;
            times  = [times0 times1];  
            szf0   = size(f0);
            assert(4 == length(szf0)); 
            f      = f0(:,:,:,1).*ones(szf0(1),szf0(2),szf0(3),len1);
            f(:,:,:,end-len0+1:end) = f0;
        end
        function f = shiftTime(f, Dt, varargin)
            %% SHIFTTIME shifts the time-indices of vector f(t) or the right-most indices of tensor F(a, b, c, t).
            %  Usage:  F = TensorTools.shiftTime(F, Delta_t, property, property_value);
            %          Delta_t > 0 shifts F later in time;
            %          Delta_t < 0 shifts F earlier in time.
            %  Properties:
            %          'ZeroPad' true (default):  values of F revealed by the shift are zeros;
            %                    false:           values revealed are the boundary value of F.   
            
            import mlsystem.*;
            f = TensorTools.shiftTensorTime(f, Dt, varargin{:});
        end        
    end 
    
    methods (Static, Access = 'private')
        function f = shiftTensorTime(f, Dt, varargin)
            p = inputParser;
            addRequired(p, 'f',             @isnumeric);
            addRequired(p, 'Dt',            @isnumeric);
            addOptional(p, 'ZeroPad', true, @islogical);
            parse(p, f, Dt, varargin{:});
            
            assert(p.Results.ZeroPad, 'mlsystem:notImplemented', 'TensorTools.shiftTensorTime has not implemented ZeroPad false');
            
            if (Dt > 0)
                f1 = zeros(size(f));
                f1(Dt+1:end) = f(1:end-Dt);
                f  = f1;
            elseif (Dt < 0)
                f1 = zeros(size(f));
                f1(1:end+Dt) = f(-Dt+1:end);
                f  = f1;
            end                
        end
    end
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end
