function out=jn_freqcorr_NAA(in,showplots);

if in.flags.freqcorrected
    error('ERROR:  Frequency Correction has already been performed!  Aborting!');
end
if in.flags.averaged
    error('ERROR:  Frequency correction must be done prior to averaging! ABORTING!');
end
if ~in.flags.addedrcvrs
    error('ERROR:  I think it only makes sense to do this after you have combined the channels using jn_addrcvrs.  ABORTING!!');
end
if in.flags.ismegaspecial
    error('ERROR:  I think it only makes sense to do this on the subspectra using jn_makeSubspectra.m.  ABORTING!!');
end

%First combine the averages and use the combined spectrum to get a first
%estimate of the fit parameters:

if ~in.flags.averaged
    avfids=sum(in.fids,in.dims.averages);
    avfids=squeeze(avfids);
end

%calculate averaged Specs using fft
avspecs=fftshift(ifft(avfids,[],in.dims.t),in.dims.t);

%First, fit NAA:  use range between 1.8-2.3ppm******************************
ppmRangeNAA=in.ppm((in.ppm>1.65)&(in.ppm<2.25));
avspecRangeNAA=avspecs(((in.ppm>1.65)&(in.ppm<2.25)),1);

%Make guess for NAA
%  pars =    [ Amp    lw      freq   y0 phase]
parsGuessNAA=[0.01  8/123.24  2.00   0    0];  %NAA

%make the function resulting from the guessed parameters
yGuessNAA=jn_lorentz(parsGuessNAA,ppmRangeNAA);
        
%Now do the fitting:        
parsFitNAA=nlinfit(ppmRangeNAA,real(avspecRangeNAA)',@jn_lorentz,parsGuessNAA);

%make the function resulting from the fitted parameters
yFitNAA=jn_lorentz(parsFitNAA,ppmRangeNAA);

%now plot the experimental data against the fit:
plot(ppmRangeNAA,avspecRangeNAA,ppmRangeNAA,yGuessNAA,ppmRangeNAA,yFitNAA);
legend('data','Guess','fit');
parsFitNAA
parsGuessNAA
%NAA DONE*******************************************************************
       

ok=input('Are you satisfied with the quality of the fit?  (y or n)  ','s');
if ok=='n'
    edit jn_freqcorr_NAA.m
    error('Change the guess parameters in jn_freqcorr.m and try again!  ABORTING!');
end
%Okay, Now you have a first estimate of the fit parameters for each peak.
%Now use those estimates to fit the peaks in the individual scans, prior to
%averaging.  
parsGuessNAA=parsFitNAA;
parsGuessNAA(1)=parsGuessNAA(1)/in.sz(in.dims.averages); %divide amplitude by Number of averages
parsGuessNAA(4)=parsGuessNAA(4)/in.sz(in.dims.averages); %divide baseline offset by number of averages
yGuessNAA=jn_lorentz(parsGuessNAA,ppmRangeNAA);


for n=1:in.sz(in.dims.averages)
    %first do the odd subspectra, which contain all three:  NAA, Cho and Cr
    specRangeNAA=in.specs(((in.ppm>1.85)&(in.ppm<2.25)),n);
    parsFitNAA=nlinfit(ppmRangeNAA,real(specRangeNAA)',@jn_lorentz,parsGuessNAA);
    yFitNAA=jn_lorentz(parsFitNAA,ppmRangeNAA);
    if showplots
        switch showplots
            case 'NAA'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeNAA,specRangeNAA,ppmRangeNAA,yGuessNAA,ppmRangeNAA,yFitNAA);
            otherwise
        end
    end
    fNAA(n)=parsFitNAA(3);
    phNAA(n)=parsFitNAA(5);
    f=fNAA-mean(fNAA);
    
    %Now you can actually implement the frequency correction on the spectra
    fids(:,n)=in.fids(:,n).*exp(-1i*in.t'*f(n)*123.24*2*pi);
    
end
figure

plot([1:in.sz(in.dims.averages)],f);
legend('NAA Frequency');


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

