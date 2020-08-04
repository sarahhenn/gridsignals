function [stepLengthTot,stepLength,occStepLength] = calcStepLength(seq)
    %%function for the calculation of the step lengths of a PRBS sequence
    idxStepUp=find(diff(seq)>0);
    idxStepDown=find(diff(seq)<0);
    if idxStepUp(1)<idxStepDown(1)
       if length(idxStepUp)==length(idxStepDown) 
            stepLengthTot=idxStepDown-idxStepUp;
       else
           stepLengthTot=idxStepDown-idxStepUp(1:end-1);
       end
    else
       if length(idxStepUp)==length(idxStepDown)         
           stepLengthTot=idxStepDown(2:end)-idxStepUp(1:end-1); 
       else
           stepLengthTot=idxStepDown(2:end)-idxStepUp(1:end);
       end
    end
    
    [occStepLength,stepLength]=hist(stepLengthTot,unique(stepLengthTot));
end

