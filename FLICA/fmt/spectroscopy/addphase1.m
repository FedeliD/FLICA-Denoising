function PhasedSpecs=addphase1(specs,ppm,timeShift,ppm0,B0);
%phasedspecs=addphase1(specs,addedphaseperpoint);

if nargin<4
    ppm0=4.7;
end


f=(ppm'-ppm0)*42.577*B0; %Frequency scale in Hz.  Currently specific to 3T;
rep=size(specs);
rep(1)=1;
f=repmat(f,rep);

%we need to make a vector of added phase values based on the frequency
%scale of the spectrum.  the phsae shift at any given point should be given
%by the time shift (in the time domain), multiplied by the frequency at
%that point:  phas[cycles]=f[Hz]*timeShift;
            % phas[radians]=f[Hz]*timeShift*2*pi;
phas=f*timeShift*2*pi;

PhasedSpecs=specs.*exp(-i*phas);

%plot([1:b],PhasedSpecs(1,:));


