function [out,fs,phs]=jn_alignAverages_fd(in,minppm,maxppm,tmax,avg);

if ~in.flags.addedrcvrs
    error('ERROR:  I think it only makes sense to do this after you have combined the channels using jn_addrcvrs.  ABORTING!!');
end

parsFit=[0,0]

if in.dims.subSpecs==0
    B=1;
else
    B=in.sz(in.dims.subSpecs);
end

fs=zeros(in.sz(in.dims.averages),B);
phs=zeros(in.sz(in.dims.averages),B);
for m=1:B
    if avg=='y'||avg=='Y'
        base=jn_averaging(in);
        base=jn_freqrange(base,minppm,maxppm);
        base=real(base.fids(base.t>=0 & base.t<tmax,m))/in.sz(in.dims.averages);
        begin=1;
    else
        base=jn_freqrange(in,minppm,maxppm);
        base=real(base.fids(base.t>=0 & base.t<tmax,1,m));
        begin=2;
        fids(:,1,m)=in.fids(:,1,m);
    end
    for n=begin:in.sz(in.dims.averages)
        parsGuess=parsFit;
        %parsGuess(1)=parsGuess(1);
        %disp(['fitting subspec number ' num2str(m) ' and average number ' num2str(n)]);
        datarange=jn_freqrange(in,minppm,maxppm);
        start=datarange.fids(datarange.t>=0 & datarange.t<tmax,n,m);
        parsFit=nlinfit(start,base,@jn_freqPhaseShiftRealRangeNest,parsGuess);
        fids(:,n,m)=jn_freqPhaseShift(parsFit,in.fids(:,n,m));
        fs(n,m)=parsFit(1);
        phs(n,m)=parsFit(2);
        %plot(in.ppm,fftshift(ifft(fids(:,1,m))),in.ppm,fftshift(ifft(fids(:,n,m))));
    end
end


%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);


%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;
out.flags.freqcorrected=1;

    function y=jn_freqPhaseShiftRealRangeNest(pars,input);
        f=pars(1);     %Frequency Shift [Hz]
        p=pars(2);     %Phase Shift [deg]
        
        
        dwelltime=datarange.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=real(addphase(fid.*exp(-1i*t'*f*2*pi),p));
        %y=real(fid.*exp(-1i*t'*f*2*pi));
        
    end

    function y=jn_freqPhaseShiftNest(pars,input);
        f=pars(1);     %Frequency Shift [Hz]
        p=pars(2);     %Phase Shift [deg]
        
        
        dwelltime=in.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=addphase(fid.*exp(-1i*t'*f*2*pi),p);
        %y=real(fid.*exp(-1i*t'*f*2*pi));
        
    end
end
