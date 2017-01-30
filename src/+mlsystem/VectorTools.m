classdef VectorTools  
	%% VECTORTOOLS   

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
 	 
	methods (Static)
        function [times,f] = shiftVector(times, f, Dt)
            import mlsystem.*
            if (Dt > 0)
                [times,f] = VectorTools.shiftVectorRight(times, f, Dt);
                return
            end
            if (Dt < 0)
                [times,f] = VectorTools.shiftVectorLeft( times, f, Dt);
                return
            end
        end
        function [times,f] = shiftVectorLeft(times0, f0, Dt)
            %  Dt in sec
            Dt     = abs(Dt);
            idx_0  = floor(sum(double(times0 < Dt + times0(1)))+1);
            times  = times0(idx_0:end);
            times  = times - times(1);
            f = f0(idx_0:end);
            f = f - min(f);
        end
        function [times,f] = shiftVectorRight(times0, f0, Dt)
            %  Dt in sec
            Dt     = abs(Dt);
            lenDt  = ceil(Dt/(times0(2) - times0(1)));
            newLen = length(f0) + lenDt;
            
            times0 = times0 - times0(1) + Dt;
            times  = [0:1:lenDt-1 times0];
            f = f0(1) * ones(1,newLen);            
            f(end-length(f0)+1:end) = f0;
            f = f - min(f);
        end
        function f = shiftTime(f, Dt)
            %% SHIFTTIME shifts the time-indices of vector f(t) or the right-most indices of tensor F(a, b, c, t).
            %  Usage:  F = VectorTools.shiftTime(F, Delta_t, property, property_value);
            %          Delta_t > 0 shifts F later in time;
            %          Delta_t < 0 shifts F earlier in time.
            %  Properties:
            %          'ZeroPad' true (default):  values of F revealed by the shift are zeros;
            %                    false:           values revealed are the boundary value of F.   
            
            import mlsystem.*;
            sizeF = size(f);
            if (length(sizeF) < 3 && (1 == sizeF(1) || 1 == sizeF(2)))
                f = VectorTools.shiftVectorTime(f, Dt);
            else
                f = VectorTools.shiftTensorTime(f, Dt);
            end
        end  
        function x = ensureColVector(x)
            %% ENSURECOLVECTOR reshapes row vectors to col vectors, leaving matrices untouched
            
            if (numel(x) > length(x)); return; end
            if (size(x,2) > size(x,1)); x = x'; end
        end
        function x = ensureRowVector(x)
            %% ENSUREROWVECTOR reshapes row vectors to col vectors, leaving matrices untouched
            
            if (numel(x) > length(x)); return; end
            if (size(x,1) > size(x,2)); x = x'; end
        end       
    end 
    
    methods (Static, Access = 'private')
        function f = shiftVectorTime(f, Dt, varargin)
            p = inputParser;
            addRequired(p, 'f',             @isnumeric);
            addRequired(p, 'Dt',            @isnumeric);
            addOptional(p, 'ZeroPad', true, @islogical);
            parse(p, f, Dt, varargin{:});
            
            assert(p.Results.ZeroPad, 'mlsystem:notImplemented', 'VectorTools.shiftVectorTime has not implemented ZeroPad false');
            
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
        function f = shiftTensorTime(f, Dt, varargin) %#ok<INUSD>
            error('mlsystem:notImplemented', 'VectorTools.shiftTensorTime');
        end
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

