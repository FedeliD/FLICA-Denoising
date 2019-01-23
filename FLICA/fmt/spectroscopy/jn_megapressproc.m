function [outDiff,outSum]=jn_megaspressproc(showplots);

%make the filename from the partial string that was given as input

close all
unixString=['ls *MEGA_GABA1*'];
[status, filename]=unix(unixString);
filename1=filename(1:end-1);

out1=jn_loadspec(filename1,'n');
out1=jn_leftshift(out1,3);
out1=jn_addrcvrs(out1,1);
out1=jn_zeropad(out1,4);
out1=jn_freqcorr(out1,showplots);
%pause;
out1=jn_averaging(out1);
outDiff1=jn_combinesubspecs(out1,'diff');
outSum1=jn_combinesubspecs(out1,'summ');


close all
unixString=['ls *MEGA_GABA2*'];
[status, filename]=unix(unixString);
filename2=filename(1:end-1);

out2=jn_loadspec(filename2,'n');
out2=jn_leftshift(out2,3);
out2=jn_addrcvrs(out2,1);
out2=jn_zeropad(out2,4);
out2=jn_freqcorr(out2,showplots);
%pause;
out2=jn_averaging(out2);
outDiff2=jn_combinesubspecs(out2,'diff');
outSum2=jn_combinesubspecs(out2,'summ');

outDiff=jn_addScans(outDiff1,outDiff2);
outSum=jn_addScans(outSum1,outSum2);

RFDiff=jn_writejmrui(outDiff,'MPdiff.txt');
RFSum=jn_writejmrui(outSum,'MPsum.txt');

outDiff=jn_filter(outDiff,5);
outSum=jn_filter(outSum,5);
