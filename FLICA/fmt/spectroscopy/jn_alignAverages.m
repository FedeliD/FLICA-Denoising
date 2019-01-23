%[out,fs,phs]=jn_alignAverages(in,tmax,avg);
function [out,fs,phs]=jn_alignAverages(in,tmax,avg);

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
    if avg=='y' || avg=='Y'
        disp('aligning all averages to the Average of the averages');
        base=jn_averaging(in);
        base=real(base.fids( in.t>=0 & in.t<tmax ,m))/in.sz(in.dims.averages);
        begin=1;
    else
        disp('aligning all averages to the first average');
        base=real(in.fids(in.t>=0 & in.t<tmax,1,m));
        begin=2;
        fids(:,1,m)=in.fids(:,1,m);
    end
    for n=begin:in.sz(in.dims.averages)
        parsGuess=parsFit;
        %disp(['fitting subspec number ' num2str(m) ' and average number ' num2str(n)]);
        parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax,n,m),base,@jn_freqPhaseShiftRealNest,parsGuess);
        fids(:,n,m)=jn_freqPhaseShiftNest(parsFit,in.fids(:,n,m));
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


    function y=jn_freqPhaseShiftRealNest(pars,input);
        f=pars(1);     %Frequency Shift [Hz]
        p=pars(2);     %Phase Shift [deg]
        
        
        dwelltime=in.dwelltime;
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
