%[out,out_w,out_noproc,out_w_noproc]=jn_specialproc(filestring,alignss,aaDomain);
function [out,out_w,out_noproc,out_w_noproc]=jn_specialproc(filestring,alignss,aaDomain);


switch alignss
    case 'y'
        %Find the filename of the first MEGA_GABA dataset
        close all
        unixString=['ls ' filestring '/*.dat'];
        [status, filename1]=unix(unixString);
        filename1=filename1(1:end-1);
        
        unixStringw=['ls ' filestring '_w/*.dat'];
        [status,filename2]=unix(unixStringw);
        filename2=filename2(1:end-1);
        
        %read in the data and add the receivers.  Then leftshift by 1.
        out_raw=jn_loadspec(filename1);
        out_ls=jn_leftshift(out_raw,1);
        
        %load water unsuppressed data and find the coil phases:
        if exist(filename2);
            out_w_raw=jn_loadspec(filename2);
            coilcombos=jn_getcoilcombos(out_w_raw,1);
            out_w_ls=jn_leftshift(out_w_raw,1);
        else
            coilcombos=jn_getcoilcombos(jn_combinesubspecs(jn_averaging(out_ls),'diff'),1);
        end
        
        %now combine the coil channels:
        [out_cc,fid_pre,spec_pre,ph,sig]=jn_addrcvrs(out_ls,2,'w',coilcombos);
        if exist(filename2);
            [out_w_cc,fid_w_pre,spec_w_pre,ph_w,sig_w]=jn_addrcvrs(out_w_ls,2,'w',coilcombos);
        end
        
        %make the un-processed spectra:
        out_noproc=jn_addphase(jn_combineSubspecs(jn_averaging(out_cc),'diff'),180);
        if exist(filename2)
            out_w_noproc=jn_addphase(jn_combineSubspecs(jn_averaging(out_w_cc),'diff'),180);
        end
        
        %plot the data before and after coil phasing:
        subplot(2,1,1);
        plot(out_ls.ppm,out_ls.specs(:,:,1,1));xlim([-1 7]);
        subplot(2,1,2);
        plot(out_ls.ppm,spec_pre(:,:,1,1));xlim([-1 7]);
        
        filename2
        if exist(filename2);
            figure
            subplot(2,1,1);
            plot(out_w_ls.ppm,out_w_ls.specs(:,:,1,1));xlim([4 5]);
            subplot(2,1,2);
            plot(out_w_ls.ppm,spec_w_pre(:,:,1,1));xlim([4 5]);
        end
        pause;
        close all;
        
%%%%%%%%OPTIONAL REMOVAL OF BAD AVERAGES%%%%%%%%%%%%%%%%%%%%
        subplot(1,2,1);
        plot(out_cc.ppm,out_cc.specs(:,:,1));
        subplot(1,2,2);
        plot(out_cc.ppm,out_cc.specs(:,:,2));
        
        out_cc2=out_cc;
        nBadAvgTotal=0;
        rmbadav=input('would you like to remove bad averages?  ','s');
        if rmbadav=='n' || rmbadav=='N'
            out_rm=out_cc;
        else
            while rmbadav=='y' || rmbadav=='Y'
                sat='n'
                while sat=='n'||sat=='N'
                    nsd=input('input number of standard deviations: ');
                    [out_rm,metric,badAverages]=jn_rmbadaverages(out_cc2,nsd);
                    badAverages
                    nbadAverages=length(badAverages)*out_raw.sz(out_raw.dims.subSpecs)
                    figure;
                    subplot(1,3,1);
                    plot([1:out_cc2.sz(out_cc2.dims.averages)],metric);
                    subplot(1,3,2);
                    plot(out_rm.ppm,out_rm.specs(:,:,1));
                    subplot(1,3,3);
                    plot(out_rm.ppm,out_rm.specs(:,:,2));
                    pause;
                    close all;
                    
                    sat=input('are you satisfied with the removal of the bad averages? ','s');
                    if sat=='y' || sat=='Y'
                        nBadAvgTotal=nBadAvgTotal+nbadAverages
                    end
                end
                rmbadav=input('would you like to remove more bad averages? ','s');
                if rmbadav=='y' || rmbadav=='Y'
                    out_cc2=out_rm;
                end
            end
        end
        
        %write a readme file to record the number of dropped avgs
        fid=fopen([filestring '/readme.txt'],'w+');
        fprintf('Original number of averages: \t%5.6f',out_raw.sz(out_raw.dims.averages));
        fprintf('\nNumber of bad Averages removed:  \t%5.6f',nBadAvgTotal);
        fprintf('\nNumber of remaining averages in processed dataset:  \t%5.6f',out_rm.sz(out_rm.dims.averages));
        fclose(fid);
        
        
        
        
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%END OF BAD AVERAGES REMOVAL%%%%%%%%%%%%
        
        %now align averages;
        sat=input('Would you like to skip the frequency drift correction?  ','s');
        if sat=='y'|| sat=='Y'
            out_aa=out_rm;
            out_w_aa=out_w_cc;
        end
        
        while sat=='n' || sat=='N'
            close all
            if aaDomain=='t' || aaDomain=='T'
                tmax=input('input tmax for drift correction: ');
                [out_aa,fs,phs]=jn_alignAverages(out_rm,tmax,'n');
            elseif aaDomain=='f' || aaDomain=='F'
                tmax=input('input tmax for drift correction: ');
                fmin=input('input fmin for drift correction: ');
                fmax=input('input fmax for drift correction: ');
                [out_aa,fs,phs]=jn_alignAverages_fd(out_rm,fmin,fmax,tmax,'n');
            end
            if exist(filename2);
                [out_w_aa,fs_w,phs_w]=jn_alignAverages(out_w_cc,5*tmax,'n');
                %[out_w_aa,fs_w,phs_w]=jn_alignAverages(out_w_aa,0.5,'n');
            end
            
            %plot the data before and after aligning Averages:
            subplot(2,2,1);
            plot(out_rm.ppm,out_rm.specs(:,:,1));xlim([-1 7]);
            subplot(2,2,2);
            plot(out_aa.ppm,out_aa.specs(:,:,1));xlim([-1 7]);
            subplot(2,2,3);
            plot(out_rm.ppm,out_rm.specs(:,:,2));xlim([-1 7]);
            subplot(2,2,4);
            plot(out_aa.ppm,out_aa.specs(:,:,2));xlim([-1 7]);
            
            figure
            subplot(2,2,1);
            plot(out_rm.t,out_rm.fids(:,:,1)); xlim([0 2*tmax]);
            subplot(2,2,2);
            plot(out_aa.t,out_aa.fids(:,:,1)); xlim([0 2*tmax]);
            subplot(2,2,3);
            plot(out_rm.t,out_rm.fids(:,:,2)); xlim([0 2*tmax]);
            subplot(2,2,4);
            plot(out_aa.t,out_aa.fids(:,:,2)); xlim([0 2*tmax]);
            
            if exist(filename2)
                figure
                subplot(2,2,1);
                plot(out_w_cc.ppm,out_w_cc.specs(:,:,1));xlim([4 5]);
                subplot(2,2,2);
                plot(out_w_aa.ppm,out_w_aa.specs(:,:,1));xlim([4 5]);
                subplot(2,2,3);
                plot(out_w_cc.ppm,out_w_cc.specs(:,:,2));xlim([4 5]);
                subplot(2,2,4);
                plot(out_w_aa.ppm,out_w_aa.specs(:,:,2));xlim([4 5]);
                
                figure
                subplot(2,2,1);
                plot(out_w_cc.t,out_w_cc.fids(:,:,1)); xlim([0 5*tmax]);
                subplot(2,2,2);
                plot(out_w_aa.t,out_w_aa.fids(:,:,1)); xlim([0 5*tmax]);
                subplot(2,2,3);
                plot(out_w_cc.t,out_w_cc.fids(:,:,2)); xlim([0 5*tmax]);
                subplot(2,2,4);
                plot(out_w_aa.t,out_w_aa.fids(:,:,2)); xlim([0 5*tmax]);
                
                figure
                plot([1:out_aa.sz(out_aa.dims.averages)],fs,[1:out_w_aa.sz(out_w_aa.dims.averages)],fs_w);
                sat=input('are you satisfied with the drift correction? ','s');
            else
                plot([1:out_aa.sz(out_aa.dims.averages)],fs);
            end
        end
        
        
        %now do the averaging:
        out_av=jn_averaging(out_aa);
        
        if exist(filename2)
            out_w_av=jn_averaging(out_w_aa);
        end
        
        %now align the subspecs (if desired);
        
        sat=input('would you like to align subspecs now?  ','s');
        if sat=='n' || sat=='N'
            out_as=out_av;
            if exist(filename2);
                out_w_as=out_w_av;
            end
        else
            while sat=='y' || sat=='Y'
                plot(out_av.ppm,out_av.specs);xlim([-1 7]);
                frq=input('what frequency would you like to use as a referecnce?  ');
                close all;
                out_as=jn_alignSubspecs(out_av,frq,'y','n','y');
                if exist(filename2)
                    out_w_as=jn_alignSubspecs(out_w_av,4.6,'y','n','y');
                end
                sat=input('try again? ','s');
            end
        end
        
        
        %now combine the subspecs:
        out_cs=jn_combineSubspecs(out_as,'diff');
        if exist(filename2)
            out_w_cs=jn_combineSubspecs(out_w_as,'diff');
        end
        
        %addphase
        out=jn_addphase(out_cs,180,0);
        if exist(filename2)
            out_w=jn_addphase(out_w_cs,180,0);
        end
        
        SpecTool(out,0.05,-2,7);
        ph0=input('input 0 order phase correction: ');
        ph1=input('input 1st order phase correction: ');
        
        out=jn_addphase(out,ph0,ph1);
        out_noproc=jn_addphase(out_noproc,ph0,ph1);
        
        if exist(filename2)
            SpecTool(out_w,0.05,-2,7);
            ph0=input('input 0 order phase correction: ');
            ph1=input('input 1st order phase correction: ');
            
            out_w=jn_addphase(out_w,ph0,ph1);
            out_w_noproc=jn_addphase(out_w_noproc,ph0,ph1);
        end
        
        wrt=input('write? ','s');
        if wrt=='y' || wrt=='Y'
            RF=jn_writelcm(out,[filestring '/' filestring '_DriftCorr'],8.5);
            RF=jn_writelcm(out_noproc,[filestring '/' filestring '_noDriftCorr'],8.5);
            if exist(filename2)
                RF=jn_writelcm(out_w,[filestring '_w/' filestring '_w_DriftCorr'],8.5);
                RF=jn_writelcm(out_w_noproc,[filestring '_w/' filestring '_w_noDriftCorr'],8.5);
            end
        end
        
    case 'n'
        
        %Find the filename of the first MEGA_GABA dataset
        close all
        unixString=['ls ' filestring '/*.dat'];
        [status, filename1]=unix(unixString);
        filename1=filename1(1:end-1);
        
        unixStringw=['ls ' filestring '_w/*.dat'];
        [status,filename2]=unix(unixStringw);
        filename2=filename2(1:end-1);
        
        %read in the data and add the receivers.  Then leftshift by 1.
        out_raw=jn_loadspec(filename1);
        out_ls=jn_leftshift(out_raw,1);
        
        %load water unsuppressed data and find the coil phases:
        if exist(filename2)
            out_w_raw=jn_loadspec(filename2);
            coilcombos=jn_getcoilcombos(out_w_raw,5);
            out_w_ls=jn_leftshift(out_w_raw,1);
        else
            coilcombos=jn_getcoilcombos(jn_combinesubspecs(jn_averaging(out_ls),'diff'),1);
        end
        
        %now combine the coil channels:
        [out_cc,fid_pre,spec_pre,ph,sig]=jn_addrcvrs(out_ls,2,'w',coilcombos);
        if exist(filename2)
            [out_w_cc,fid_w_pre,spec_w_pre,ph_w,sig_w]=jn_addrcvrs(out_w_ls,2,'w',coilcombos);
        end
        
        %make the un-processed spectra:
        out_noproc=jn_addphase(jn_combineSubspecs(jn_averaging(out_cc),'diff'),180);
        if exist(filename2)
            out_w_noproc=jn_addphase(jn_combineSubspecs(jn_averaging(out_w_cc),'diff'),180);
        end
        
        %plot the data before and after coil phasing:
        subplot(2,1,1);
        plot(out_ls.ppm,out_ls.specs(:,:,1,1));xlim([-1 7]);
        subplot(2,1,2);
        plot(out_ls.ppm,spec_pre(:,:,1,1));xlim([-1 7]);
        
        if exist(filename2)
            figure
            subplot(2,1,1);
            plot(out_w_ls.ppm,out_w_ls.specs(:,:,1,1));xlim([4 5]);
            subplot(2,1,2);
            plot(out_w_ls.ppm,spec_w_pre(:,:,1,1));xlim([4 5]);
        end
        pause;
        close all;
        
        %Now combine the subspecs
        out_cs=jn_combinesubspecs(out_cc,'diff');
        if exist(filename2)
            out_w_cs=jn_combinesubspecs(out_w_cc,'diff');
        end
        
%%%%%%%%%%%%%%%%%%%%%OPTIONAL REMOVAL OF BAD AVERAGES%%%%%%%%%%%%%%%%
        plot(out_cs.ppm,out_cs.specs);
        
        out_cs2=out_cs;
        nBadAvgTotal=0;
        rmbadav=input('would you like to remove bad averages?  ','s');
        if rmbadav=='n' || rmbadav=='N'
            out_rm=out_cs;
        else
            while rmbadav=='y' || rmbadav=='Y'
                sat='n'
                while sat=='n'||sat=='N'
                    nsd=input('input number of standard deviations.  ');
                    [out_rm,metric,badAverages]=jn_rmbadaverages(out_cs2,nsd);
                    badAverages
                    nbadAverages=length(badAverages)*out_raw.sz(out_raw.dims.subSpecs)
                    figure;
                    subplot(1,2,1);
                    plot([1:out_cs2.sz(out_cs2.dims.averages)],metric,'.');
                    subplot(1,2,2);
                    plot(out_rm.ppm,out_rm.specs);xlim([-1 7]);
                    pause;
                    close all;
                    
                    sat=input('are you satisfied with removal of bad averages? ','s');
                    if sat=='y' || sat=='Y'
                        nBadAvgTotal=nBadAvgTotal+nbadAverages
                    end
                    
                end
                rmbadav=input('would you like to remove more bad averages? ','s');
                if rmbadav=='y' || rmbadav=='Y'
                    out_cs2=out_rm;
                end
            end
        end
        
        %write a readme file to record the number of dropped avgs
        fid=fopen([filestring '/readme.txt'],'w+');
        fprintf(fid,'Original number of averages: \t%5.6f',out_raw.sz(out_raw.dims.averages)*2);
        disp(['Original number of averages:  ' num2str(out_raw.sz(out_raw.dims.averages)*2)]);
        fprintf(fid,'\nNumber of bad Averages removed:  \t%5.6f',nBadAvgTotal);
        disp(['Number of bad averages removed:  ' num2str(nBadAvgTotal)]);
        fprintf(fid,'\nNumber of remaining averages in processed dataset:  \t%5.6f',out_rm.sz(out_rm.dims.averages)*2);
        disp(['Number of remaining averages in processed dataset:  ' num2str(out_rm.sz(out_rm.dims.averages)*2)]);
        fclose(fid);
            
           
        
%%%%%%%%%%%%%%%%%%%%END OF BAD AVERAGES REMOVAL%%%%%%%%%%%%%%%%%%%%
        
        %now align averages;
        sat=input('Would you like to skip the frequency drift correction?  ','s');
        if sat=='y'|| sat=='Y'
            out_aa=out_rm;
            out_w_aa=out_w_cs;
        end
        
        while sat=='n' || sat=='N'
            close all
            if aaDomain=='t' || aaDomain=='T'
                tmax=input('input tmax for drift correction: ');
                [out_aa,fs,phs]=jn_alignAverages(out_rm,tmax,'n');
            elseif aaDomain=='f' || aaDomain=='F'
                tmax=input('input tmax for drift correction: ');
                fmin=input('input fmin for drift correction: ');
                fmax=input('input fmax for drift correction: ');
                [out_aa,fs,phs]=jn_alignAverages_fd(out_rm,fmin,fmax,tmax,'n');
            end
            if exist(filename2)
                [out_w_aa,fs_w,phs_w]=jn_alignAverages(out_w_cs,5*tmax,'n');
                %[out_w_aa,fs_w,phs_w]=jn_alignAverages(out_w_aa,0.5,'n');
            end
            
            %plot the data before and after aligning Averages:
            subplot(2,1,1);
            plot(out_cc.ppm,out_rm.specs(:,:,1));xlim([-1 7]);
            subplot(2,1,2);
            plot(out_aa.ppm,out_aa.specs(:,:,1));xlim([-1 7]);
            
            figure
            subplot(2,1,1);
            plot(out_cc.t,out_rm.fids(:,:,1));xlim([0 2*tmax]);
            subplot(2,1,2);
            plot(out_aa.t,out_aa.fids(:,:,1));xlim([0 2*tmax]);
            
            if exist(filename2)
                figure
                subplot(2,1,1);
                plot(out_w_cc.ppm,out_w_cs.specs(:,:,1));xlim([4 5]);
                subplot(2,1,2);
                plot(out_w_aa.ppm,out_w_aa.specs(:,:,1));xlim([4 5]);
                
                figure
                subplot(2,1,1);
                plot(out_w_cc.t,out_w_cs.fids(:,:,1));xlim([0 5*tmax]);
                subplot(2,1,2);
                plot(out_w_aa.t,out_w_aa.fids(:,:,1));xlim([0 5*tmax]);
                
                figure
                plot([1:out_aa.sz(out_aa.dims.averages)],fs,[1:out_w_aa.sz(out_w_aa.dims.averages)],fs_w);
            else
                plot([1:out_aa.sz(out_aa.dims.averages)],fs);
            end
            sat=input('are you satisfied with the drift correction? ','s');
        end
        
        
        %now do the averaging:
        out_av=jn_averaging(out_aa);
        if exist(filename2)
            out_w_av=jn_averaging(out_w_aa);
        end
        
        %addphase
        out=jn_addphase(out_av,180,0);
        if exist(filename2)
            out_w=jn_addphase(out_w_av,180,0);
        end
        
        SpecTool(out,0.05,-2,7);
        ph0=input('input 0 order phase correction: ');
        ph1=input('input 1st order phase correction: ');
        
        out=jn_addphase(out,ph0,ph1);
        out_noproc=jn_addphase(out_noproc,ph0,ph1);
        
        if exist(filename2)
            SpecTool(out_w,0.05,-2,7);
            ph0=input('input 0 order phase correction: ');
            ph1=input('input 1st order phase correction: ');
            
            out_w=jn_addphase(out_w,ph0,ph1);
            out_w_noproc=jn_addphase(out_w_noproc,ph0,ph1);
        end
        
        wrt=input('write? ','s');
        if wrt=='y' || wrt=='Y'
            RF=jn_writelcm(out,[filestring '/' filestring '_DriftCorr'],8.5);
            RF=jn_writelcm(out_noproc,[filestring '/' filestring '_noDriftCorr'],8.5);
            if exist(filename2)
                RF=jn_writelcm(out_w,[filestring '_w/' filestring '_w_DriftCorr'],8.5);
                RF=jn_writelcm(out_w_noproc,[filestring '_w/' filestring '_w_noDriftCorr'],8.5);
            end
        end
        
    otherwise
end










