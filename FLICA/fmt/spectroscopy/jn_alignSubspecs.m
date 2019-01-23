function out=jn_alignSubspecs(in,Freq,showplots,filter,linbas);

if ~in.flags.averaged
    error('ERROR:  I think it only makes sense to do this after you have combined the averages');
end
if ~in.flags.addedrcvrs
    error('ERROR:  I think it only makes sense to do this after you have combined the channels using jn_addrcvrs.  ABORTING!!');
end
if in.flags.subtracted
    error('ERROR:  I think it only makes sense to do this on the subspectra using jn_makeSubspectra.m.  ABORTING!!');
end

%make Guess parameters (Cr f=3.0 is a good choice for edited MRS);
ppmMin=Freq-0.12;
ppmMax=Freq+0.12;

% plot(in.ppm(in.ppm>ppmMin&in.ppm<ppmMax),in.specs((in.ppm>ppmMin)&(in.ppm<ppmMax),1));
% Freq=input('Choose the approximate centre frequency: ');

ppmMin=Freq-0.12;
ppmMax=Freq+0.12;;

if filter=='y'
    in_filt=jn_filter(in,5);
else
    in_filt=in;
end
ppmRange=in.ppm((in.ppm>ppmMin)&(in.ppm<ppmMax));

if linbas=='y'
    parsGuess=[0.1  3/123.24    Freq   0    0    180];
else
    parsGuess=[0.1  3/123.24    Freq   0    180];
end
        
        
       

%Okay, Now you have a first estimate of the fit parameters for each peak.
%Now use those estimates to fit the peaks in the individual scans, prior to
%averaging.  

if linbas=='y'
    yGuess=jn_lorentz_linbas(parsGuess,ppmRange);
else
    yGuess=jn_lorentz(parsGuess,ppmRange);
end

for m=1:in.sz(in.dims.subSpecs)
    figure
    specRange=in_filt.specs(((in.ppm>ppmMin)&(in.ppm<ppmMax)),m);
    if linbas=='y'
        parsFit=nlinfit(ppmRange,real(specRange)',@jn_lorentz_linbas,parsGuess);
        yFit=jn_lorentz_linbas(parsFit,ppmRange);
        
    else
        parsFit=nlinfit(ppmRange,real(specRange)',@jn_lorentz,parsGuess);
        yFit=jn_lorentz(parsFit,ppmRange);
    end
    if showplots
        switch showplots
            case 'y'
                plot(ppmRange,specRange,ppmRange,yGuess,ppmRange,yFit);
                legend('Data','Guess','Fit');
            otherwise
        end
    end
    fs(m)=parsFit(3);
    phs(m)=parsFit(end);
    f(m)=fs(m)-fs(1);
    
    %Now you can actually implement the frequency correction on the spectra
    fids(:,m)=in.fids(:,m).*exp(-1i*in.t'*f(m)*123.24*2*pi);
    parsGuess=parsFit;
end
figure

plot([1:in.sz(in.dims.subSpecs)],f,'.');
if in.sz(in.dims.subSpecs)==2
    legend('subspec1','subspec2');
elseif in.sz(in.dims.subSpecs)==4
    legend('subspec1','subspec2','subspec3','subspec4');
elseif in.sz(in.dims.subSpecs)==1
    legend('measured frequency drift');
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

