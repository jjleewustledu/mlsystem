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
            %% SHIFTVECTOR shifts f backwards in time by Delta t < 0 and forwards in time by Delta t > 0.
            %  The data window contracts for backward shifts, losing data, and expands for forward shifts 
            %  without loss of data.  Internal operations use row vectors.   
            
            import mlsystem.*
            times = VectorTools.ensureRowVector(times);
            f     = VectorTools.ensureRowVector(f);
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
            Dt    = abs(Dt);            
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = len0 - lenDt;
            
            times = times0(1:len1);
            f     = f0(lenDt+1:end);
        end
        function [times,f] = shiftVectorRight(times0, f0, Dt)
            %  Dt in sec
            Dt    = abs(Dt);
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = lenDt + len0;
            
            times1 = times0(end)+dt0:dt0:times0(end)+dt0*lenDt;
            times  = [times0 times1];   
            f      = f0(1) * ones(1,len1);            
            f(end-len0+1:end) = f0;
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

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

