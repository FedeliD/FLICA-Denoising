%fitting

cd ~/Documents/data/studies/mega_special_study/newData2/RobT_4Jul2010/
d=dat2mat2('meas_MID44_jn_mega_special1_FID16099.dat','n',5,5,0,1,'n');
ppm2=d.ppm((d.ppm>2.9)&(d.ppm<3.2));
spec2=d.subspecs(((d.ppm>2.9)&(d.ppm<3.2)),1);
plot(ppm2,spec2);

parsGuess=[0 max(real(spec2)) 10/123.24 3.02 0];
parsFit=nlinfit(ppm2,real(spec2'),@jn_lorentz,parsGuess);
yFit=jn_lorentz(parsFit,ppm2);

plot(ppm2,spec2,ppm2,yFit);
parsFit
parsGuess