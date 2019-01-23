function out=jn_alignScans(in,in1,tmax,mode);

if ~in1.flags.addedrcvrs || ~in.flags.addedrcvrs
    error('ERROR:  I think it only makes sense to do this after you have combined the channels using jn_addrcvrs.  ABORTING!!');
end

if ~in1.flags.averaged || ~in.flags.averaged
    error('ERROR:  I think it only makes sense to do this after you have combined the averages using jn_averaging.  ABORTING!!');
end

if in1.flags.ismegaspecial || in.flags.ismegaspecial
    error('ERROR:  I think it only makes sense to do this after you have performed jn_makesubspecs.  ABORTING!!');
end

if ~in1.flags.subtracted  || ~in.flags.subtracted
    error('ERROR:  I think it only makes sense to do this after you have combined the subspectra using jn_combinesubspecs.  ABORTING!!');
end

if nargin<4
    mode='fp';
end

switch mode
    case 'f'
        parsFit=0;
    case 'p'
        parsFit=0;
    case 'fp'
        parsFit=[0 0];
    case 'pf'
        mode='fp'
        parsFit=[0 0];
    otherwise
        error('ERROR:mode unrecognized.  Use "1" or "2".  ABORTING!');
end


base=in1;
base=real(base.fids( in1.t>=0 & in1.t<tmax ));

%plot(in1.t,in1.fids,in.t,in.fids);

parsGuess=parsFit;
%disp(['fitting subspec number ' num2str(m) ' and average number ' num2str(n)]);
switch mode
    case 'f'
        parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax),base,@jn_freqShiftRealNest,parsGuess);
        fids=jn_freqShiftNest(parsFit,in.fids);
    case 'p'
        parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax),base,@jn_phaseShiftRealNest,parsGuess);
        fids=jn_phaseShiftNest(parsFit,in.fids);
    case 'fp'
        parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax),base,@jn_freqPhaseShiftRealNest,parsGuess);
        fids=jn_freqPhaseShiftNest(parsFit,in.fids);
end

%figure
%plot(in1.t,in1.fids,in.t,fids);


%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);

%plot(in1.ppm,combinedSpecs);

%FILLING IN DATA STRUCTURES
out=in;
out.fids=fids;
out.specs=specs;

%FILLING IN THE FLAGS
out.flags=in1.flags;


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

    function y=jn_freqShiftRealNest(pars,input);
        f=pars(1);     %Frequency Shift [Hz]
                
        dwelltime=in.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=real(fid.*exp(-1i*t'*f*2*pi));
        %y=real(fid.*exp(-1i*t'*f*2*pi));
        
    end

    function y=jn_freqShiftNest(pars,input);
        f=pars(1);     %Frequency Shift [Hz]
               
        dwelltime=in.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=fid.*exp(-1i*t'*f*2*pi);
        %y=real(fid.*exp(-1i*t'*f*2*pi));
    end
    function y=jn_phaseShiftRealNest(pars,input);
        p=pars(1);     %Phase Shift [deg]
        
        
        dwelltime=in.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=real(addphase(fid,p));
        %y=real(fid.*exp(-1i*t'*f*2*pi));
        
    end

    function y=jn_phaseShiftNest(pars,input);
        p=pars(1);     %Phase Shift [deg]
        
        
        dwelltime=in.dwelltime;
        t=[0:dwelltime:(length(input)-1)*dwelltime];
        fid=input(:);
        
        y=addphase(fid,p);
        %y=real(fid.*exp(-1i*t'*f*2*pi));
    end
    
end
