%y=jn_freqPhaseShift(pars,fid,ppm);
%pars=[frequency shift [Hz], phase shift [deg]];
%fid=spectrum to shift;
%t=time axis vector;
function [y]=jn_freqPhaseShift(pars,input)

f=pars(1);     %Frequency Shift [Hz]
p=pars(2);     %Phase Shift [deg]

%dwelltime=2.5e-4;
dwelltime=4.167e-4;
t=[0:dwelltime:(length(input)-1)*dwelltime];
fid=input(:);

y=addphase(fid.*exp(-1i*t'*f*2*pi),p);
%y=fid.*exp(-1i*t'*f*2*pi);

