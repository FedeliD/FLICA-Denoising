function out=jn_freqrange(in,ppmmin,ppmmax);

%Calculate Specs using fft
fullspecs=fftshift(ifft(in.fids,[],in.dims.t),in.dims.t);

%now take only the specified range of the spectrum
specs=fullspecs(in.ppm>ppmmin & in.ppm<ppmmax,:,:);

%convert back to time domain
fids=fft(fftshift(specs,in.dims.t),[],in.dims.t);

%calculate the size;
sz=size(fids);

%calculate the ppm scale
ppm=in.ppm(in.ppm>ppmmin & in.ppm<ppmmax);

%calculate the new spectral width and dwelltime:
ppmrange=-(ppm(end)-ppm(1));
spectralwidth=ppmrange*123.24;
dwelltime=1/spectralwidth;

%calculate the time scale
t=[0:dwelltime:(sz(1)-1)*dwelltime];



%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;
out.sz=sz;
out.ppm=ppm;  
out.t=t; 
out.spectralwidth=spectralwidth;
out.dwelltime=dwelltime;

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;
out.flags.freqranged=1;