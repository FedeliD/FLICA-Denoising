function out=jn_megaspressproc(filename);

out=jn_loadspec(filename);
out=jn_leftshift(out,5);
out=jn_addrcvrs(out,1);
out=jn_zeropad(out,4);
out=jn_filter(out,5);
out=jn_freqcorr(out);
out=jn_averaging(out);
out=jn_combinesubspecs(out);
