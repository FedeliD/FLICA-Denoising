function out=jn_makesubspecs(in);

if ~in.flags.ismegaspecial
    error('ERROR:  requires a MEGA-SPECIAL dataset as input!  Aborting!');
end
if in.sz(end)~=4
    error('ERROR: final matrix dim must have length 4!!  Aborting!');
end


%now make subspecs and subfids (This doesn't do anything to MEGA-PRESS
%data, but it combines the SPECIAL iterations in MEGA-SPECIAL).
sz=in.sz;
fids=in.fids;
reshapedFids=reshape(fids,prod(sz(1:end-1)),sz(end));
ind1=[1 2];
ind2=[3 4];
sz(end)=sz(end)-2;
reshapedFids(:,1)=sum(reshapedFids(:,ind1),2);
reshapedFids(:,2)=sum(reshapedFids(:,ind2),2);
fids=reshape(reshapedFids(:,ind1),sz);


%re-calculate Specs using fft
specs=fftshift(ifft(fids,[],in.dims.t),in.dims.t);


%FILLING IN DATA STRUCTURE
out=in;
out.fids=fids;
out.specs=specs;
out.sz=sz;

%FILLING IN THE FLAGS
out.flags=in.flags;
out.flags.writtentostruct=1;
out.flags.ismegaspecial=0;

