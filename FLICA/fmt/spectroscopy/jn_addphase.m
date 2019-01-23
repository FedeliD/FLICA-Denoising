function out=jn_addphase(in,ph0,ph1,ppm0);

if nargin<4
    ppm0=4.7;
    if nargin<3
        ph1=0;
    end
end

ph0;
ph1;
%Add Zero-order phase
fids=addphase(in.fids,ph0);

%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);

%Now add 1st-order phase
specs=addphase1(specs,in.ppm,ph1,ppm0,in.Bo);

%re-calculate Fids using fft
fids=fft(fftshift(specs,in.dims.t),[],in.dims.t);

plot(in.ppm,real(specs));

    
%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;