classdef VectorTools  
	%% VECTORTOOLS 

	%  $Revision$ 
 	%  was created $Date$ 
 	%  by $Author$,  
 	%  last modified $LastChangedDate$ 
 	%  and checked into repository $URL$,  
 	%  developed on Matlab 8.4.0.150421 (R2014b) 
 	%  $Id$ 
    
    properties
        resizable
    end
 	 
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
    end 
    
    methods 
        function this = VectorTools(varargin)
            ip = inputParser;
            addOptional(ip, 'resizable', true, @islogical);
            parse(ip, varargin{:});
            this.resizable = ip.Results.resizable;
        end
        
        function [times,f] = shiftVector(this, times, f, Dt)
            %% SHIFTVECTOR shifts f backwards in time by Delta t < 0 and forwards in time by Delta t > 0.
            %  If VectorTools.resizable, the data window contracts for backward shifts, losing data, and  
            %  expands for forward shifts without loss of data.  Internal operations use row vectors.   
            
            import mlsystem.*
            times = VectorTools.ensureRowVector(times);
            f     = VectorTools.ensureRowVector(f);
            if (Dt > 0)
                [times,f] = this.shiftVectorRight(times, f, Dt);
                return
            end
            if (Dt < 0)
                [times,f] = this.shiftVectorLeft( times, f, Dt);
                return
            end
        end
        function [times,f] = shiftVectorLeft(this, times0, f0, Dt)
            %  Dt in sec
            Dt    = abs(Dt);            
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = len0 - lenDt;
            
            if (this.resizable)
                times = times0(1:len1);
                f     = f0(lenDt+1:end);
                return
            end
            times          = times0;
            f              = f0(end)*ones(size(f0));
            f(1:end-lenDt) = f0(lenDt+1:end);
        end
        function [times,f] = shiftVectorRight(this, times0, f0, Dt)
            %  Dt in sec
            Dt    = abs(Dt);
            dt0   = abs(times0(2) - times0(1));
            lenDt = floor(Dt/dt0);
            len0  = length(times0);
            len1  = lenDt + len0;            
            
            if (this.resizable)
                times1 = times0(end)+dt0:dt0:times0(end)+dt0*lenDt;
                times  = [times0 times1];   
                f      = f0(1) * ones(1,len1);            
                f(end-len0+1:end) = f0;
                return
            end
            times          = times0;
            f              = f0(1)*ones(size(f0));
            f(lenDt+1:end) = f0(1:end-lenDt);
        end 
    end

	%  Created with Newcl by John J. Lee after newfcn by Frank Gonzalez-Morphy 
end

