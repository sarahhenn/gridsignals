Range = [0,1];
maxLength1=42*12;
n=6;

%Specify the clock period of the signal as 1 sample. That is, the signal value can change at each time step. For PRBS signals, the clock period is specified in Band = [0 B], where B is the inverse of the required clock period.

%input data is in 15 minute steps

%lowest expected time constant is 20 minutes (4 times the time step)
%further n of 

Band = [0 1/4];
actSeq=idinput([maxLength1,1,n],'prbs',Band,Range);
seq1=actSeq(1:maxLength1);

[stepLengthTot,stepLength,occStepLength] = calcStepLength(seq1);

%second sequence is generated with the lowest frequency of 20 hours (20*4)
n=4;
Band = [0 1/(20*12)];
maxLength2=300*12;

actSeq=idinput([maxLength2,1,n],'prbs',Band,Range);
seq2=actSeq(1:maxLength2);

[stepLengthTot2,stepLength2,occStepLength2] = calcStepLength(seq2);

sequenceTotal=[repmat(seq1,4,1);seq2;seq1];

[stepLengthTot3,stepLength3,occStepLength3] = calcStepLength(sequenceTotal);

time=(0:5*60:(length(sequenceTotal)-1)*5*60)';

plot(time/3600,sequenceTotal);
hold on;
plot(3*504*5*60/3600,0,'ro')

dlmwrite('InputSignalPRBS.txt',[time,sequenceTotal],'\t');