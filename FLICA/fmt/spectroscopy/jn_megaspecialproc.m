function [diffFilt,diff,sumFilt,summ,fs1,fs2,fs3]=jn_megaspecialproc(filestring,avgAlignDomain,alignSS);
%[diffFilt,diff,sumFilt,summ,fs1,fs2,fs3]=jn_megaspecialproc(filestring,avgAlignDomain,alignSS);

%make the filename from the partial string that was given as input
%avgAlignDomain

%Find the filename of the MEGA_SPECIAL dataset
close all
unixString1=['ls ' filestring '1/*.dat'];
[status, filename1]=unix(unixString1);
filename1=filename1(1:end-1);

unixString2=['ls ' filestring '2/*.dat'];
[status, filename2]=unix(unixString2);
filename2=filename2(1:end-1);

unixString3=['ls ' filestring '3/*.dat'];
[status, filename3]=unix(unixString3);
filename3=filename3(1:end-1);

unixStringw=['ls ' filestring '_w/*.dat'];
[status,filenamew]=unix(unixStringw);
filenamew=filenamew(1:end-1);


%read in both datasets:
raw1=jn_loadspec(filename1);
raw2=jn_loadspec(filename2);
raw3=jn_loadspec(filename3);
raww=jn_loadspec(filenamew);


%first step should be to combine coil channels.  To do this find the coil
%phases from the water unsuppressed data.
coilcombos=jn_getcoilcombos(raww,5);

[out1_cc,fid1_pre,spec1_pre,ph1,sig1]=jn_addrcvrs(raw1,5,'w',coilcombos);
[out2_cc,fid2_pre,spec2_pre,ph2,sig2]=jn_addrcvrs(raw2,5,'w',coilcombos);
[out3_cc,fid3_pre,spec3_pre,ph3,sig3]=jn_addrcvrs(raw3,5,'w',coilcombos);
[outw_cc,fidw_pre,specw_pre,phw,sigw]=jn_addrcvrs(raww,5,'w',coilcombos);

%plot coil channels before and after phase alignment
figure
subplot(2,1,1);
plot(raw1.ppm,raw1.specs(:,:,1,1));xlim([-2 8]);
subplot(2,1,2);
plot(raw1.ppm,spec1_pre(:,:,1,1));xlim([-2 8]);

figure
subplot(2,1,1);
plot(raw2.ppm,raw2.specs(:,:,1,1));xlim([-2 8]);
subplot(2,1,2);
plot(raw2.ppm,spec2_pre(:,:,1,1));xlim([-2 8]);

figure
subplot(2,1,1);
plot(raw3.ppm,raw3.specs(:,:,1,1));xlim([-2 8]);
subplot(2,1,2);
plot(raw3.ppm,spec3_pre(:,:,1,1));xlim([-2 8]);

figure
subplot(2,1,1);
plot(raww.ppm,raww.specs(:,:,1,1));xlim([-2 8]);
subplot(2,1,2);
plot(raww.ppm,specw_pre(:,:,1,1));xlim([-2 8]);


pause;


if alignSS~=4
    out1_ms=jn_makesubspecs(out1_cc);
    out2_ms=jn_makesubspecs(out2_cc);
    out3_ms=jn_makesubspecs(out3_cc);
else
    out1_ms=out1_cc;
    out2_ms=out2_cc;
    out3_ms=out3_cc;
end


if avgAlignDomain~='n' && avgAlignDomain~='N'
    %now align averages;
    sat='n';
    while sat=='n' || sat=='N'
        close all
        tmax=input('input tmax for drift correction: ');
        switch avgAlignDomain
            case 't'
                [out1_aa,fs1,phs1]=jn_alignAverages(out1_ms,tmax,'y');
                [out2_aa,fs2,phs2]=jn_alignAverages(out2_ms,tmax,'y');
                [out3_aa,fs3,phs3]=jn_alignAverages(out3_ms,tmax,'y');
            case 'f'
                ppmmin=input('Input minimum ppm: ');
                ppmmax=input('Input maximum ppm: ');
                [out1_aa,fs1,phs1]=jn_alignAverages_fd(out1_ms,ppmmin,ppmmax,tmax,'y');
                [out2_aa,fs2,phs2]=jn_alignAverages_fd(out2_ms,ppmmin,ppmmax,tmax,'y');
                [out3_aa,fs3,phs3]=jn_alignAverages_fd(out3_ms,ppmmin,ppmmax,tmax,'y');
            otherwise
                error('ERROR: avgAlignDomain not recognized!');
        end
        
        x=repmat([1:size(fs1,1)]',1,out1_aa.sz(out1_aa.dims.subSpecs));
        p1=polyfit(x,fs1,1)
        p2=polyfit(x,fs2,1)
        p3=polyfit(x,fs3,1)
        
        switch alignSS
            case 4
                %plot the data before and after aligning Averages:
                subplot(2,4,1);
                plot(out1_ms.ppm,out1_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,4,2);
                plot(out1_aa.ppm,out1_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,4,3);
                plot(out1_ms.ppm,out1_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,4,4);
                plot(out1_aa.ppm,out1_aa.specs(:,:,2));xlim([0 6]);
                subplot(2,4,5);
                plot(out1_ms.ppm,out1_ms.specs(:,:,3));xlim([0 6]);
                subplot(2,4,6);
                plot(out1_aa.ppm,out1_aa.specs(:,:,3));xlim([0 6]);
                subplot(2,4,7);
                plot(out1_ms.ppm,out1_ms.specs(:,:,4));xlim([0 6]);
                subplot(2,4,8);
                plot(out1_aa.ppm,out1_aa.specs(:,:,4));xlim([0 6]);
                
                figure
                subplot(2,4,1);
                plot(out2_ms.ppm,out2_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,4,2);
                plot(out2_aa.ppm,out2_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,4,3);
                plot(out2_ms.ppm,out2_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,4,4);
                plot(out2_aa.ppm,out2_aa.specs(:,:,2));xlim([0 6]);
                subplot(2,4,5);
                plot(out2_ms.ppm,out2_ms.specs(:,:,3));xlim([0 6]);
                subplot(2,4,6);
                plot(out2_aa.ppm,out2_aa.specs(:,:,3));xlim([0 6]);
                subplot(2,4,7);
                plot(out2_ms.ppm,out2_ms.specs(:,:,4));xlim([0 6]);
                subplot(2,4,8);
                plot(out2_aa.ppm,out2_aa.specs(:,:,4));xlim([0 6]);
                
                figure
                subplot(2,4,1);
                plot(out3_ms.ppm,out3_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,4,2);
                plot(out3_aa.ppm,out3_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,4,3);
                plot(out3_ms.ppm,out3_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,4,4);
                plot(out3_aa.ppm,out3_aa.specs(:,:,2));xlim([0 6]);
                subplot(2,4,5);
                plot(out3_ms.ppm,out3_ms.specs(:,:,3));xlim([0 6]);
                subplot(2,4,6);
                plot(out3_aa.ppm,out3_aa.specs(:,:,3));xlim([0 6]);
                subplot(2,4,7);
                plot(out3_ms.ppm,out3_ms.specs(:,:,4));xlim([0 6]);
                subplot(2,4,8);
                plot(out3_aa.ppm,out3_aa.specs(:,:,4));xlim([0 6]);
                
            otherwise
                %plot the data before and after aligning Averages:
                subplot(2,2,1);
                plot(out1_ms.ppm,out1_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,2,2);
                plot(out1_aa.ppm,out1_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,2,3);
                plot(out1_ms.ppm,out1_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,2,4);
                plot(out1_aa.ppm,out1_aa.specs(:,:,2));xlim([0 6]);
                
                figure
                subplot(2,2,1);
                plot(out2_ms.ppm,out2_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,2,2);
                plot(out2_aa.ppm,out2_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,2,3);
                plot(out2_ms.ppm,out2_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,2,4);
                plot(out2_aa.ppm,out2_aa.specs(:,:,2));xlim([0 6]);
                
                figure
                subplot(2,2,1);
                plot(out3_ms.ppm,out3_ms.specs(:,:,1));xlim([0 6]);
                subplot(2,2,2);
                plot(out3_aa.ppm,out3_aa.specs(:,:,1));xlim([0 6]);
                subplot(2,2,3);
                plot(out3_ms.ppm,out3_ms.specs(:,:,2));xlim([0 6]);
                subplot(2,2,4);
                plot(out3_aa.ppm,out3_aa.specs(:,:,2));xlim([0 6]);
        end
                
        figure
        plot([1:out1_aa.sz(out1_aa.dims.averages)],[fs1 fs2 fs3],'.',x,polyval(p1,x),x,polyval(p2,x),x,polyval(p3,x));
        sat=input('are you satisfied with the drift correction? ','s');
    end
    
    close all
    
    %now combine the averages averages
    out1_av=jn_averaging(out1_aa);
    out2_av=jn_averaging(out2_aa);
    out3_av=jn_averaging(out3_aa);
    
else
    
    out1_av=jn_averaging(out1_ms);
    out2_av=jn_averaging(out2_ms);
    out3_av=jn_averaging(out3_ms);
    fs1=0;
    fs2=0;
    fs3=0;
    phs1=0;
    phs2=0;
    phs3=0;
    
end

%now leftshift
out1_ls=jn_leftshift(out1_av,4);
out2_ls=jn_leftshift(out2_av,4);
out3_ls=jn_leftshift(out3_av,4);


switch alignSS
    case 4
        %now align all four subspecs
        sat='n';
        while sat=='n' || sat=='N'
            close all;
            out1_ls
            plot(out1_ls.ppm,out1_ls.specs(:,1),out1_ls.ppm,addphase(out1_ls.specs(:,2),180),out1_ls.ppm,out1_ls.specs(:,3),out1_ls.ppm,addphase(out1_ls.specs(:,4),180));xlim([-1 7]);
            frq=input('what frequency would you like to use as a referecnce?  ');
            close all;
            out1_as=jn_alignSubspecs(out1_ls,frq,'y','n','y');
            out2_as=jn_alignSubspecs(out2_ls,frq,'y','n','y');
            out3_as=jn_alignSubspecs(out3_ls,frq,'y','n','y');
            sat=input('are you satisfied with the subspecs alignment? ','s');
        end
        
        %now make Subspecs
        out1_ms=jn_makesubspecs(out1_as);
        out2_ms=jn_makesubspecs(out2_as);
        out3_ms=jn_makesubspecs(out3_as);
        
        %now combine Subspecs
        out1_diff=jn_combineSubspecs(out1_ms,'diff');
        out1_summ=jn_combineSubspecs(out1_ms,'summ');
        out2_diff=jn_combineSubspecs(out2_ms,'diff');
        out2_summ=jn_combineSubspecs(out2_ms,'summ');
        out3_diff=jn_combineSubspecs(out3_ms,'diff');
        out3_summ=jn_combineSubspecs(out3_ms,'summ');
        
    case 2
        %now align Subspecs
%         sat='n';
%         while sat=='n' || sat=='N'
%             close all;
%             plot(out1_ls.ppm,out1_ls.specs);xlim([-1 7]);
%             frq=input('what frequency would you like to use as a referecnce?  ');
%             close all;
%             out1_as=jn_alignSubspecs(out1_ls,frq,'y','n','y');
%             out2_as=jn_alignSubspecs(out2_ls,frq,'y','n','y');
%             out3_as=jn_alignSubspecs(out3_ls,frq,'y','n','y');
%             sat=input('are you satisfied with the subspecs alignment? ','s');
%         end
%         
%         
    
        %This case uses the frequency drift calculation obained in the
        %averages Alignment step to estimate the drift correction between
        %the subSpecs.
%         sat='n'
%         while sat=='n'||sat=='N'
%             frqshft=input('Input Desired Frequncy Shift (Hz) for first spectrum: ');
%             out1_as=jn_freqShiftSubspec(out1_ls,frqshft);
%             out1_asf=jn_filter(out1_as,2.5);
%             out1_asdf=jn_combinesubspecs(out1_asf,'diff');
%             subplot(1,2,1);
%             plot(out1_as.ppm,out1_as.specs(:,1),out1_as.ppm,addphase(out1_as.specs(:,2),180));xlim([1.2 4.2]);
%             subplot(1,2,2);
%             plot(out1_asdf.ppm,out1_asdf.specs);xlim([1.2 4.2]);
%             sat=input('Are you satisfied with the frequency shift? ','s');
%         end
out1_ls_filt=jn_addphase(jn_filter(out1_ls,5),180);
subSpecTool(out1_ls_filt,0,7);
frqshft=input('Input Desired Frequncy Shift (Hz) for first spectrum: ');
out1_as=jn_freqShiftSubspec(jn_addphase(out1_ls,180),frqshft);
        
%         sat='n'
%         while sat=='n'||sat=='N'
%             frqshft=input('Input Desired Frequncy Shift (Hz) for second spectrum: ');
%             out2_as=jn_freqShiftSubspec(out2_ls,frqshft);
%             out2_asf=jn_filter(out2_as,2.5);
%             out2_asdf=jn_combinesubspecs(out2_asf,'diff');
%             subplot(1,2,1);
%             plot(out2_as.ppm,out2_as.specs(:,1),out2_as.ppm,addphase(out2_as.specs(:,2),180));xlim([1.2 4.2]);
%             subplot(1,2,2);
%             plot(out2_asdf.ppm,out2_asdf.specs);xlim([1.2 4.2]);
%             sat=input('Are you satisfied with the frequency shift? ','s');
%         end
out2_ls_filt=jn_addphase(jn_filter(out2_ls,5),180);
subSpecTool(out2_ls_filt,0,7);
frqshft=input('Input Desired Frequncy Shift (Hz) for first spectrum: ');
out2_as=jn_freqShiftSubspec(jn_addphase(out2_ls,180),frqshft);
        
%         sat='n'
%         while sat=='n'||sat=='N'
%             frqshft=input('Input Desired Frequncy Shift (Hz) for third spectrum: ');
%             out3_as=jn_freqShiftSubspec(out3_ls,frqshft);
%             out3_asf=jn_filter(out3_as,2.5);
%             out3_asdf=jn_combinesubspecs(out3_asf,'diff');
%             subplot(1,2,1);
%             plot(out3_as.ppm,out3_as.specs(:,1),out3_as.ppm,addphase(out3_as.specs(:,2),180));xlim([1.2 4.2]);
%             subplot(1,2,2);
%             plot(out3_asdf.ppm,out3_asdf.specs);xlim([1.2 4.2]);
%             sat=input('Are you satisfied with the frequency shift? ','s');
%         end
out3_ls_filt=jn_addphase(jn_filter(out3_ls,5),180);        
subSpecTool(out3_ls_filt,0,7);
frqshft=input('Input Desired Frequncy Shift (Hz) for first spectrum: ');
out3_as=jn_freqShiftSubspec(jn_addphase(out3_ls,180),frqshft);


       
        %now combine Subspecs
        out1_diff=jn_combineSubspecs(out1_as,'diff');
        out1_summ=jn_combineSubspecs(out1_as,'summ');
        out2_diff=jn_combineSubspecs(out2_as,'diff');
        out2_summ=jn_combineSubspecs(out2_as,'summ');
        out3_diff=jn_combineSubspecs(out3_as,'diff');
        out3_summ=jn_combineSubspecs(out3_as,'summ');
        
                
    case 0
        %now combine Subspecs
        out1_diff=jn_combineSubspecs(out1_ls,'diff');
        out1_summ=jn_combineSubspecs(out1_ls,'summ');
        out2_diff=jn_combineSubspecs(out2_ls,'diff');
        out2_summ=jn_combineSubspecs(out2_ls,'summ');
        out3_diff=jn_combineSubspecs(out3_ls,'diff');
        out3_summ=jn_combineSubspecs(out3_ls,'summ');
        
    otherwise
        error('ERROR: alignSS value not valid! ');
end

%now align the two scans and add them together
sat='n'
while sat=='n' || sat=='N'
    tmax=input('input tmax for scan alignment');
    out2_diffa=jn_alignScans(out2_diff,out1_diff,tmax);
    out2_summa=jn_alignScans(out2_summ,out1_summ,tmax);
    out3_diffa=jn_alignScans(out3_diff,out1_diff,tmax);
    out3_summa=jn_alignScans(out3_summ,out1_summ,tmax);
    plot(out1_diff.ppm,out1_diff.specs,out2_diffa.ppm,out2_diffa.specs,out3_diffa.ppm,out3_diffa.specs);
    figure
    plot(out1_summ.ppm,out1_summ.specs,out2_summa.ppm,out2_summa.specs,out3_summa.ppm,out3_summa.specs);
    sat=input('are you satisfied with the scan alignment?','s');
end

diff=jn_addScans(out1_diff,out2_diffa);
summ=jn_addScans(out2_summ,out2_summa);

diff=jn_addScans(diff,out3_diffa);
summ=jn_addScans(summ,out3_summa);

diffFilt=jn_filter(diff,5);
sumFilt=jn_filter(summ,5);

writ=input('Write? (y or n):  ','s');
if writ=='y' || writ=='Y'
    RF=jn_writejmrui(diff,'MSdiff.txt');
    RF=jn_writejmrui(summ,'MSsumm.txt');
end
