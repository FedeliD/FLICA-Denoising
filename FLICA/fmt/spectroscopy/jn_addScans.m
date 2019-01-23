function out=jn_addScans(in1,in2);

fids=in1.fids+in2.fids;

%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in1.dims.t),in1.dims.t);

%FILLING IN DATA STRUCTURES
out=in1;
out.fids=fids;
out.specs=specs;

%FILLING IN THE FLAGS
out.flags=in1.flags;