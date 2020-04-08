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
            %% SHIFTTENSOR shifts f backwards in time by Delta t < 0 and forwards in time by Delta t > 0.
            %  The data window contracts for backward shifts, losing data, and  
            %  expands for forward shifts without loss of data.  Internal operations use row vectors.   
            %  @param times is numeric, possibly nonuniform.
            %  @param f is vector.
            %  @param Dt is numeric, has uniform measure. 
            
            import mlsystem.TensorTools
            assert(ndims(f) == 4)
            
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
            
            [~,minpos] = min(abs(times0 + Dt));
            indicesDt = round(minpos);
            difft0 = diff(times0);
            times = [times0(1) cumsum(difft0(indicesDt:end))];
            f = f0(:,:,:,indicesDt:end);
        end 
        function [times,f] = shiftTensorRight(times0, f0, Dt)
            %  Dt in sec
            
            [~,minpos] = min(abs(times0 - Dt));
            indicesDt = round(minpos);
            difft0 = diff(times0);
            times = [times0(1:indicesDt) (times0(indicesDt) + cumsum(difft0))];
            switch indicesDt
                case 1
                    f = f0;
                otherwise                    
                    f = repmat(f0(:,:,:,1), [1 1 1 (indicesDt-1)]);
                    f(:,:,:,indicesDt:size(f0,4)+indicesDt-1) = f0;
            end
        end        
    end
    
	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy
 end

