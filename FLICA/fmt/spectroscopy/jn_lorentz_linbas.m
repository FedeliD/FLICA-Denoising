%y=jn_lorentz_linbas(pars,ppm);
%pars=[Amplitude, FWHM, Centre Freq, baseline slope, baseline offset, Phase shift];
%ppm=frequency axis vector;
function [y]=jn_lorentz_linbas(pars,ppm)

A=pars(:,1);     %Amplitude  (Use only positive Numbers)
w=pars(:,2);     %full width at half max
ppm0=pars(:,3);  %centre frequency of peak

if size(pars,2)==6
    m=pars(:,4);    %baseline slope
    y0=pars(:,5);    %baseline offset
    theta=pars(:,6); %Phase shift of peak
    gam=w/pi;      %gamma parameter
    %Define a complex lorentzian for each set of
    y=zeros(length(A),length(ppm));
    for n=1:length(A)
        y(n,:) = sqrt(2/pi) *(gam(n)-i*(ppm-ppm0(n))) ./ (gam(n)^2 + (ppm-ppm0(n)).^2);
        %now scale it, add baseline, phase it by theta, and take the real part
        bas=y0(n)+(m(n)*ppm);
        y(n,:)=real(addphase(y(n,:)/max(abs(y(n,:)))*A(n)+bas,theta(n)));
    end
    y=sum(y,1);
elseif size(pars,2)==5
    m=pars(:,4);    %baseline slope
    y0=pars(:,5);    %baseline offset
    gam=w/pi;      %gamma parameter
    %assume zero phase:
    theta=zeros(size(pars,1),1);
    %Define a complex lorentzian for each set of
    y=zeros(length(A),length(ppm));
    for n=1:length(A)
        y(n,:) = sqrt(2/pi) *(gam(n)-i*(ppm-ppm0(n))) ./ (gam(n)^2 + (ppm-ppm0(n)).^2);
        %now scale it, add baseline, phase it by theta, and take the real part
        bas=y0(n)+(m(n)*ppm);
        y(n,:)=real(addphase(y(n,:)/max(abs(y(n,:)))*A(n)+bas,theta(n)));
    end
    y=sum(y,1);
elseif size(pars,2)==3
    gam=w/pi;      %gamma parameter
    %assume zero phase:
    theta=zeros(size(pars,1),1);
    %assume zero baseline offset:
    y0=zeros(size(pars,1),1);
    %Define a complex lorentzian for each set of
    y=zeros(length(A),length(ppm));
    for n=1:length(A)
        y(n,:) = sqrt(2/pi) *(gam(n)-i*(ppm-ppm0(n))) ./ (gam(n)^2 + (ppm-ppm0(n)).^2);
        %now scale it, add baseline, phase it by theta, and take the real part
        bas=0;
        y(n,:)=real(addphase(y(n,:)/max(abs(y(n,:)))*A(n)+bas,theta(n)));
    end
    y=sum(y,1);
end



