%coilcombos=jn_getcoilcombos(file_or_struct,point);
function coilcombos=jn_getcoilcombos(file_or_struct,point);

%this function will accept either a string filename or the name of a
%structure.  If the input is a string, the program will read in the data
%corresponding to that filename.  If the input is a structure, it will
%operate on that structure.
if isstr(file_or_struct)
    in=jn_loadspec(file_or_struct);
else
    in=file_or_struct;
end

if in.flags.addedrcvrs
    error('ERROR:  must provide data prior to coil combination!!  ABORTING!!');
end

coilcombos.ph=zeros(in.sz(in.dims.coils),1);
coilcombos.sig=zeros(in.sz(in.dims.coils),1);

for n=1:in.sz(in.dims.coils);
    coilcombos.ph(n)=phase(in.fids(point,n,1,1));
    coilcombos.sig(n)=abs(in.fids(point,n,1,1));
end

