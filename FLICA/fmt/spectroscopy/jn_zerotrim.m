function out=jn_zerotrim(in,zpFactor);

if ~in.flags.zeropadded
    error('ERROR:  Cannot trim zeros if Zero padding has not been performed!  ABORTING!');
end


%calculate how many zeros to leave
zp=(in.sz(1)/zpFactor);

sz=in.sz;
sz(1)=sz(1)/zpFactor;
%Trim zeros
fids=reshape(in.fids(1:zp,:),sz);

%Calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);

%Now re-calculate t and ppm arrays using the calculated parameters:
f=[(-in.spectralwidth/2)+(in.spectralwidth/(2*sz(1))):...
    in.spectralwidth/(sz(1)):...
    (in.spectralwidth/2)-(in.spectralwidth/(2*sz(1)))];

ppm=-f/(2.89*42.577);
ppm=ppm+4.65;

t=[in.dwelltime:in.dwelltime:sz(1)*in.dwelltime];


%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;
out.sz=sz;
out.ppm=ppm;  
out.t=t;    

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;
out.flags.zeropadded=0;