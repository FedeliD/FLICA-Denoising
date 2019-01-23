function out=jn_megapress2lcm(showplots);

%make the filename from the partial string that was given as input

close all
unixString=['ls *MEGA_GABA1*'];
[status, filename]=unix(unixString);
filename1=filename(1:end-1);

out1=jn_loadspec(filename1,'n');
out1=jn_leftshift(out1,4);
out1=jn_addrcvrs(out1,1);
out1=jn_zeropad(out1,4);
out1=jn_freqcorr(out1,showplots);
out1=jn_averaging(out1);



close all
unixString=['ls *MEGA_GABA2*'];
[status, filename]=unix(unixString);
filename2=filename(1:end-1);

out2=jn_loadspec(filename2,'n');
out2=jn_leftshift(out2,4);
out2=jn_addrcvrs(out2,1);
out2=jn_zeropad(out2,4);
out2=jn_freqcorr(out2,showplots);
out2=jn_averaging(out2);

out=jn_addScans(out1,out2);
out=jn_zerotrim(out,4);

plot(out.ppm,out.specs);


RF=jn_writelcm(out,'press69',69);
