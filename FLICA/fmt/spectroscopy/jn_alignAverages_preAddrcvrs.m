function [out,fs,phs,driftPoly]=jn_alignAverages_preAddrcvrs(in,tmax,avg,fit);

parsFit=[0 0];

avgIndex=[1:in.sz(in.dims.averages)];

if in.dims.subSpecs==0
    B=1;
else
    B=in.sz(in.dims.subSpecs);
end

if in.dims.coils==0
    C=1;
else
    C=in.sz(in.dims.coils);
end

avgIndex_mat=repmat(avgIndex,[C 1 B]);
avgIndex_vec=reshape(avgIndex_mat,numel(avgIndex_mat),1);


fs=zeros(C,in.sz(in.dims.averages),B);
phs=zeros(C,in.sz(in.dims.averages),B);

if in.dims.coils==0
    for m=1:B
        if avg=='y' || avg=='Y'
            base=jn_averaging(in);
            base=real(base.fids( in.t>=0 & in.t<tmax ,m))/in.sz(in.dims.averages);
            begin=1;
        else
            base=real(in.fids(in.t>=0 & in.t<tmax,1,m));
            begin=2;
            fids(:,1,m)=in.fids(:,1,m);
        end
        for n=begin:in.sz(in.dims.averages)
            if n==begin
                parsGuess=[0 0];
            else
                parsGuess=parsFit;
            end
            %disp(['fitting subspec number ' num2str(m) ' and average number ' num2str(n)]);
            parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax,n,m),base,@jn_freqPhaseShiftRealNest,parsGuess);
            if fit=='n' || fit=='N'
                fids(:,n,m)=jn_freqPhaseShiftNest(parsFit,in.fids(:,n,m));
            end
            fs(n,m)=parsFit(1);
            phs(n,m)=parsFit(2);
            %plot(in.ppm,fftshift(ifft(fids(:,1,m))),in.ppm,fftshift(ifft(fids(:,n,m))));
        end
    end
else
    for k=1:C
        for m=1:B
            if avg=='y' || avg=='Y'
                base=jn_averaging(in);
                base=real(base.fids(in.t>=0 & in.t<tmax,k,m))/in.sz(in.dims.averages);
                begin=1;
            else
                base=real(in.fids(in.t>=0 & in.t<tmax,k,1,m));
                begin=2;
                fids(:,k,1,m)=in.fids(:,k,1,m);
            end
            for n=begin:in.sz(in.dims.averages)
                if n==begin
                    parsGuess=[0 0];
                else
                    parsGuess=parsFit;
                end
                opts.Robust='on';
                %disp(['fitting subspec number ' num2str(m) ' and average number ' num2str(n)]);
                parsFit=nlinfit(in.fids(in.t>=0 & in.t<tmax,k,n,m),base,@jn_freqPhaseShiftRealNest,parsGuess);
                if fit=='n' || fit=='N'
                    fids(:,k,n,m)=jn_freqPhaseShiftNest(parsFit,in.fids(:,k,n,m));
                end
                fs(k,n,m)=parsFit(1);
                phs(k,n,m)=parsFit(2);
                %plot(in.ppm,fftshift(ifft(fids(:,1,m))),in.ppm,fftshift(ifft(fids(:,n,m))));
            end
            PP{k,m}=polyfit(squeeze(avgIndex_mat(k,:,m)),squeeze(fs(k,:,m)),1);
            plot(avgIndex_mat(k,:,m),polyval(PP{k,m},squeeze(avgIndex_mat(k,:,m))));
            ssresid(k,m)=sqrt(sum((squeeze(fs(k,:,m))-polyval(PP{k,m},squeeze(avgIndex_mat(k,:,m)))).^2));
        end
    end
end

[I1,I2]=ind2sub(size(ssresid),find(ssresid==min(min(ssresid))));
driftPoly=PP{I1,I2};


fs_vec=reshape(fs,numel(fs),1);
PPP=polyfit(avgIndex_vec,fs_vec,1);
plot(avgIndex_vec,fs_vec,'.',[1 in.sz(in.dims.averages)],[polyval(PPP,1) polyval(PPP,64)],[1 in.sz(in.dims.averages)],[polyval(driftPoly,1) polyval(driftPoly,64)]);
pause;

if fit=='y' || fit=='Y'
    if in.dims.coils==0
        for m=1:B
            for n=1:in.sz(in.dims.averages)
                
                pars=[polyval(driftPoly,n+((m-1)*1/B)) phs(n,m)]
                fids(:,n,m)=jn_freqPhaseShiftNest(pars,in.fids(:,n,m));
            end
        end
    else
        for k=1:C
            for m=1:B
                for n=begin:in.sz(in.dims.averages)
                    pars=[polyval(driftPoly,n+((m-1)*1/B)) phs(k,n,m)];
                    fids(:,k,n,m)=jn_freqPhaseShiftNest(pars,in.fids(:,k,n,m));
                end
            end
        end
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
        %y=(fid.*exp(-1i*t'*f*2*pi));
        
    end

end
