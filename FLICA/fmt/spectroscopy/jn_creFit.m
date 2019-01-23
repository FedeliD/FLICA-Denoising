function parsFit=jn_creFit(in,ph0,ph1);

if in.flags.ismegaspecial
    error('ERROR:  must have combined subspecs in order to do this!  ABORTING');
end

if ~in.flags.averaged
    error('ERROR:  must have averaged in order to do this!  ABORTING');
end

if ~in.flags.addedrcvrs
    error('ERROR:  must have added receivers in order to do this!  ABORTING');
end
specs=addphase(addphase1(in.specs,ph1),ph0);

ppm=in.ppm((in.ppm>2.8)&(in.ppm<3.12));
spec=specs(((in.ppm>2.8)&(in.ppm<3.12)));

plot(ppm,spec);

components=input('number of components?  ');
parsGuess=zeros(components,4);
parsGuess(:,1)=max(real(spec));
parsGuess(:,2)=10/123.24;
%parsGuess(:,4)=0;
parsGuess(:,4)=(real(spec(1))-real(spec(end)))/(ppm(1)-ppm(end));
parsGuess(:,5)=real(spec(1))-(parsGuess(:,4)*ppm(1));
for n=1:components
    parsGuess(n,3)=input(['Input frequency in PPM of ' num2str(n) 'th component:  ']);
end
yGuess=jn_lorentz_linbas(parsGuess,ppm);
parsFit=nlinfit(ppm,real(spec'),@jn_lorentz_linbas,parsGuess);
yFit=jn_lorentz_linbas(parsFit,ppm);

plot(ppm,spec,ppm,yGuess,':',ppm,yFit);
legend('data','guess','fit');
parsFit
parsGuess

area=parsFit(:,1).*parsFit(:,2);
for n=1:size(area,1)
    disp(['Area under the ' num2str(n) 'th fitted curve is: ' num2str(area(n))]);
end
area=sum(area);
disp(['Area under the fitted curve is: ' num2str(area)]);


