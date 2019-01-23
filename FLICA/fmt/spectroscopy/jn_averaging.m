function out=jn_averaging(in);

if in.flags.averaged
    error('ERROR:  Averaging has already been performed!  Aborting!');
end

if ~in.flags.freqcorrected
    disp('WARNING:  Frequency correction has not yet been performed!');
end
if ~in.flags.phasecorrected
    disp('WARNING:  Phase correction has not yet been performed!');
end


%add the spectrum along the averages dimension;
fids=sum(in.fids,in.dims.averages);
fids=squeeze(fids);

%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);

%change the dims variables
dims.t=in.dims.t;
dims.coils=in.dims.coils;
dims.averages=0;
dims.subSpecs=in.dims.subSpecs-1+((in.dims.subSpecs-1)<0); %Don't let it go negative

%re-calculate the sz variable
sz=size(fids);


%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;
out.sz=sz;
out.dims=dims;

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;
out.flags.averaged=1;


