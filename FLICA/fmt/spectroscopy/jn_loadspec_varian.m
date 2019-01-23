function out=jn_loadspec_varian(filename);

%read in the data using read_meas_dat
%dOut=jn_read_meas_dat2(filename);
%[par,img,k,fids]=fidread(filename);
[fids,hdr,block_hdr]=readfid(filename);
par=readprocpar(filename);


fids=squeeze(fids);
sz=size(fids);

%un-interleave the data for megapress2.c
tempfids(:,[1:1:sz(2)/2],1)=fids(:,[1:2:sz(2)]);
tempfids(:,[1:1:sz(2)/2],2)=fids(:,[2:2:sz(2)]);
fids=squeeze(tempfids);
%fids=fids([end:-1:1],:,:);


sz=size(fids);


%Now create a record of the dimensions of the data array.  
dims.t=1;
dims.coils=0;
dims.averages=2;
dims.subSpecs=3;

specs=fftshift(ifft(fids,[],dims.t),dims.t);

%Now get relevant scan parameters:*****************************

%Get Spectral width and Dwell Time
spectralwidth=par.sw;
dwelltime=1/spectralwidth;

    
%Get TxFrq
txfrq=par.sfrq*1e6;


%Get Date
date=par.date;


%****************************************************************


%Calculate t and ppm arrays using the calculated parameters:
f=[(-spectralwidth/2)+(spectralwidth/(2*sz(1))):spectralwidth/(sz(1)):(spectralwidth/2)-(spectralwidth/(2*sz(1)))];
ppm=f/(txfrq/1e6);
ppm=ppm+4.6082;

t=[0:dwelltime:(sz(1)-1)*dwelltime];


%FILLING IN DATA STRUCTURE
out.fids=fids;
out.specs=specs;
out.sz=sz;
out.ppm=ppm;  
out.t=t;    
out.spectralwidth=spectralwidth;
out.dwelltime=dwelltime;
out.txfrq=txfrq;
out.date=date;
out.dims=dims;
out.Bo=out.txfrq/42.577;

%FILLING IN THE FLAGS
out.flags.writtentostruct=1;
out.flags.gotparams=1;
out.flags.leftshifted=0;
out.flags.filtered=0;
out.flags.zeropadded=0;
out.flags.freqcorrected=0;
out.flags.phasecorrected=0;
out.flags.averaged=0;
out.flags.addedrcvrs=1;
out.flags.subtracted=0;
out.flags.writtentotext=0;
out.flags.ismegaspecial=0;



%DONE
