function out=jn_freqcorr(in,showplots);

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
ppmRangeNAA=in.ppm((in.ppm>1.85)&(in.ppm<2.25));
avspecRangeNAA=avspecs(((in.ppm>1.85)&(in.ppm<2.25)),1);

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
        
%Now, fit Cr:  use range between 2.9-3.1ppm******************************
ppmRangeCr=in.ppm((in.ppm>2.9)&(in.ppm<3.1));
avspecRangeCr=avspecs(((in.ppm>2.9)&(in.ppm<3.1)),1);

%Make guess for Cr
%  pars = [  Amp    lw      freq  y0  phase]
parsGuessCr=[0.01  8/123.24  3.02  0  0];  %Cr

%make the function resulting from the guessed parameters
yGuessCr=jn_lorentz(parsGuessCr,ppmRangeCr);
        
%Now do the fitting:        
parsFitCr=nlinfit(ppmRangeCr,real(avspecRangeCr)',@jn_lorentz,parsGuessCr);

%make the function resulting from the fitted parameters
yFitCr=jn_lorentz(parsFitCr,ppmRangeCr);

%now plot the experimental data against the fit:
figure
plot(ppmRangeCr,avspecRangeCr,ppmRangeCr,yGuessCr,ppmRangeCr,yFitCr);
legend('data','Guess','fit');
parsFitCr
parsGuessCr
%NAA
%DONE*******************************************************************

%Finally, fit Ch:  use range between 3.1-3.3ppm******************************
ppmRangeCh=in.ppm((in.ppm>3.1)&(in.ppm<3.3));
avspecRangeCh=avspecs(((in.ppm>3.1)&(in.ppm<3.3)),1);

%Make guess for Ch
%  pars = [ Amp    lw      freq   y0  phase]
parsGuessCh=[0.01  8/123.24  3.2  0   0];  %Ch

%make the function resulting from the guessed parameters
yGuessCh=jn_lorentz(parsGuessCh,ppmRangeCh);
        
%Now do the fitting:        
parsFitCh=nlinfit(ppmRangeCh,real(avspecRangeCh)',@jn_lorentz,parsGuessCh);

%make the function resulting from the fitted parameters
yFitCh=jn_lorentz(parsFitCh,ppmRangeCh);

%now plot the experimental data against the fit:
figure
plot(ppmRangeCh,avspecRangeCh,ppmRangeCh,yGuessCh,ppmRangeCh,yFitCh);
legend('data','Guess','fit');
parsFitCh
parsGuessCh
%NAA
%DONE*******************************************************************
% figure
% plot([parsFitNAA(4) parsFitCr(4) parsFitCh(4)],[parsFitNAA(5) parsFitCr(5) parsFitCh(5)]);

ok=input('Are you satisfied with the quality of those fits?  (y or n)  ','s');
if ok=='n'
    edit jn_freqcorr.m
    error('Change the guess parameters in jn_freqcorr.m and try again!  ABORTING!');
end
%Okay, Now you have a first estimate of the fit parameters for each peak.
%Now use those estimates to fit the peaks in the individual scans, prior to
%averaging.  
parsGuessNAA=parsFitNAA;
parsGuessNAA(1)=parsGuessNAA(1)/in.sz(in.dims.averages); %divide amplitude by Number of averages
parsGuessNAA(4)=parsGuessNAA(4)/in.sz(in.dims.averages); %divide baseline offset by number of averages
yGuessNAA=jn_lorentz(parsGuessNAA,ppmRangeNAA);
parsGuessCr=parsFitCr;
parsGuessCr(1)=parsGuessCr(1)/in.sz(in.dims.averages);  %divide amplitude by number of averages
parsGuessCr(4)=parsGuessCr(4)/in.sz(in.dims.averages);  %divide baseline offset by number of averages
yGuessCr=jn_lorentz(parsGuessCr,ppmRangeCr);
parsGuessCh=parsFitCh;
parsGuessCh(1)=parsGuessCh(1)/in.sz(in.dims.averages);  %divide amplitude by number of averages
parsGuessCh(4)=parsGuessCh(4)/in.sz(in.dims.averages);  %divide baseline offset by number of averages
yGuessCh=jn_lorentz(parsGuessCh,ppmRangeCh);

%Make a separate set of guess parameters for choline and creatine in the
%even spectra by adding pi (180 degrees) phase:
parsGuessCrEven=parsGuessCr;
parsGuessCrEven(5)=parsGuessCrEven(5)+180;
yGuessCrEven=jn_lorentz(parsGuessCrEven,ppmRangeCr);
parsGuessChEven=parsGuessCh;
parsGuessChEven(5)=parsGuessChEven(5)+180;
yGuessChEven=jn_lorentz(parsGuessChEven,ppmRangeCh);


for n=1:in.sz(in.dims.averages)
    %first do the odd subspectra, which contain all three:  NAA, Cho and Cr
    specRangeNAA=in.specs(((in.ppm>1.85)&(in.ppm<2.25)),n,1);
    specRangeCr=in.specs(((in.ppm>2.9)&(in.ppm<3.1)),n,1);
    specRangeCh=in.specs(((in.ppm>3.1)&(in.ppm<3.3)),n,1);
    parsFitNAA=nlinfit(ppmRangeNAA,real(specRangeNAA)',@jn_lorentz,parsGuessNAA);
    parsFitCr=nlinfit(ppmRangeCr,real(specRangeCr)',@jn_lorentz,parsGuessCr);
    parsFitCh=nlinfit(ppmRangeCh,real(specRangeCh)',@jn_lorentz,parsGuessCh);
    yFitNAA=jn_lorentz(parsFitNAA,ppmRangeNAA);
    yFitCr=jn_lorentz(parsFitCr,ppmRangeCr);
    yFitCh=jn_lorentz(parsFitCh,ppmRangeCh);
    if showplots
        switch showplots
            case 'NAA'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeNAA,specRangeNAA,ppmRangeNAA,yGuessNAA,ppmRangeNAA,yFitNAA);
            case 'Cre'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeCr,specRangeCr,ppmRangeCr,yGuessCr,ppmRangeCr,yFitCr);
            case 'Cho'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeCh,specRangeCh,ppmRangeCh,yGuessCh,ppmRangeCh,yFitCh);
            otherwise
        end
    end
    fNAAOdd(n)=parsFitNAA(3);
    phNAAOdd(n)=parsFitNAA(5);
    fCrOdd(n)=parsFitCr(3);
    phCrOdd(n)=parsFitCr(5);
    fChOdd(n)=parsFitCh(3);
    phChOdd(n)=parsFitCh(5);
    fOdd=(1/3)*((fNAAOdd-mean(fNAAOdd))+(fCrOdd-mean(fCrOdd))+(fChOdd-mean(fChOdd)));
    
    %Now do the Even subspectra, which contain only Cho and Cr
    specRangeCr=in.specs(((in.ppm>2.9)&(in.ppm<3.1)),n,2);
    specRangeCh=in.specs(((in.ppm>3.1)&(in.ppm<3.3)),n,2);
    parsFitCr=nlinfit(ppmRangeCr,real(specRangeCr)',@jn_lorentz,parsGuessCrEven);
    parsFitCh=nlinfit(ppmRangeCh,real(specRangeCh)',@jn_lorentz,parsGuessChEven);
    yFitCr=jn_lorentz(parsFitCr,ppmRangeCr);
    yFitCh=jn_lorentz(parsFitCh,ppmRangeCh);
    if showplots
        switch showplots
            case 'Cre'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeCr,specRangeCr,ppmRangeCr,yGuessCrEven,ppmRangeCr,yFitCr);
            case 'Cho'
                subplot(in.sz(in.dims.averages)/4,in.sz(in.dims.averages)/(in.sz(in.dims.averages)/4),n);
                plot(ppmRangeCh,specRangeCh,ppmRangeCh,yGuessChEven,ppmRangeCh,yFitCh);
            otherwise
        end
    end
    fCrEven(n)=parsFitCr(3);
    phCrEven(n)=parsFitCr(5);
    fChEven(n)=parsFitCh(3);
    phChEven(n)=parsFitCh(5);
    fEven=(1/2)*((fCrEven-mean(fCrEven))+(fChEven-mean(fChEven)));
    
    %Now you can actually implement the frequency correction on the spectra
    fids(:,n,1)=in.fids(:,n,1).*exp(-1i*in.t'*fOdd(n)*123.24*2*pi);
    fids(:,n,2)=in.fids(:,n,2).*exp(-1i*in.t'*fOdd(n)*123.24*2*pi);
end
figure

plot([1:in.sz(in.dims.averages)],fOdd,[1:in.sz(in.dims.averages)],fEven);
legend('Odd Scans','Even Scans');


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

