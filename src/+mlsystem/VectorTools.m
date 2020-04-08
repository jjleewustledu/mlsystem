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
        function [x,flipped] = ensureColVector(x)
            %% ENSURECOLVECTOR reshapes row vectors to col vectors, leaving matrices untouched
            
            flipped = false;
            if (numel(x) > length(x)); return; end
            if (size(x,2) > size(x,1))
                x = x'; 
                flipped = true;
            end
        end
        function [x,flipped] = ensureRowVector(x)
            %% ENSUREROWVECTOR reshapes row vectors to col vectors, leaving matrices untouched
            
            flipped = false;
            if (numel(x) > length(x)); return; end
            if (size(x,1) > size(x,2))
                x = x';
                flipped = true;
            end
        end           
        
        function [times,f] = shiftVector(times, f, Dt)
            %% SHIFTVECTOR shifts f backwards in time by Delta t < 0 and forwards in time by Delta t > 0.
            %  The data window contracts for backward shifts, losing data, and  
            %  expands for forward shifts without loss of data.  Internal operations use row vectors.   
            %  @param times is numeric, possibly nonuniform.
            %  @param f is vector.
            %  @param Dt is numeric, has uniform measure. 
            
            import mlsystem.VectorTools
            times_ = VectorTools.ensureRowVector(times);
            f_     = VectorTools.ensureRowVector(f);
            if (Dt > 0)
                [times,f] = VectorTools.shiftVectorRight(times_, f_, Dt);
                return
            end
            if (Dt < 0)
                [times,f] = VectorTools.shiftVectorLeft( times_, f_, Dt);
                return
            end
        end
        function [times,f] = shiftVectorLeft(times0, f0, Dt)
            %  Dt in sec
            
            [~,minpos] = min(abs(times0 + Dt));
            indicesDt = round(minpos);
            difft0 = diff(times0);
            times = [times0(1) cumsum(difft0(indicesDt:end))];
            f = f0(indicesDt:end);
        end 
        function [times,f] = shiftVectorRight(times0, f0, Dt)
            %  Dt in sec
            
            [~,minpos] = min(abs(times0 - Dt));
            indicesDt = round(minpos);
            difft0 = diff(times0);
            times = [times0(1:indicesDt) (times0(indicesDt) + cumsum(difft0))];
            f = [f0(1)*ones(1,indicesDt-1) f0];
        end   
    end 

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

