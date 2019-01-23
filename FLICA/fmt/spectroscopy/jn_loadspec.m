function out=jn_loadspec(filename);

%read in the data using read_meas_dat
dOut=jn_read_meas_dat2(filename);

%find out if the data was acquired using the rm_special sequence.  Make
%changes accordingly.
fid=fopen(filename);
line=fgets(fid);
index=findstr(line,'tSequenceFileName');
equals_index=findstr(line,'= ');
while isempty(index) || isempty(equals_index)
    line=fgets(fid);
    index=findstr(line,'tSequenceFileName');
    equals_index=findstr(line,'= ');
end
sequence=line(equals_index+1:end);
isSpecial=~isempty(findstr(sequence,'rm_special'));
fclose(fid);
if isSpecial 
    data=zeros(length(dOut.data(:,1,1,1)),length(dOut.data(1,1,:,1)),length(dOut.data(1,1,1,:))/2,2);
    data(:,:,:,1)=dOut.data(:,1,:,[1:2:end]);
    data(:,:,:,2)=dOut.data(:,1,:,[2:2:end]);
else
    data=dOut.data;
end


fids=squeeze(data);
sz=size(fids);


%Find the magnetic field strength:
fid=fopen(filename);
line=fgets(fid);
index=findstr(line,'sProtConsistencyInfo.flNominalB0');
equals_index=findstr(line,'= ');
while isempty(index) || isempty(equals_index)
    line=fgets(fid);
    index=findstr(line,'sProtConsistencyInfo.flNominalB0');
    equals_index=findstr(line,'= ');
end
Bo=line(equals_index+1:end);
Bo=str2double(Bo);
fclose(fid);



%Now create a record of the dimensions of the data array.  

if ndims(fids)==4  %Default config when 4 dims are acquired
    dims.t=1;
    dims.coils=2;
    dims.averages=3;
    dims.subSpecs=4;
elseif ndims(fids)<4  %To many permutations...ask user for dims.
    dims.t=1;
    dims.coils=input('Enter the coils Dimension (0 for none):  ');
    dims.averages=input('Enter the averages Dimension (0 for none):  ');
    dims.subSpecs=input('Enter the subSpecs Dimension (0 for none);  ');
end

specs=fftshift(ifft(fids,[],dims.t),dims.t);


    

%Now get relevant scan parameters:*****************************

%Get Spectral width and Dwell Time
fid=fopen(filename);
line=fgets(fid);
index=findstr(line,'sRXSPEC.alDwellTime[0]');
equals_index=findstr(line,'= ');
while isempty(index) || isempty(equals_index)
    line=fgets(fid);
    index=findstr(line,'sRXSPEC.alDwellTime[0]');
    equals_index=findstr(line,'= ');
end
dwelltime=line(equals_index+1:end);
dwelltime=str2double(dwelltime)*1e-9;
spectralwidth=1/dwelltime;
fclose(fid);
    
%Get TxFrq
fid=fopen(filename);
line=fgets(fid);
index=findstr(line,'sTXSPEC.asNucleusInfo[0].lFrequency');
equals_index=findstr(line,'= ');
while isempty(index) || isempty(equals_index)
    line=fgets(fid);
    index=findstr(line,'sTXSPEC.asNucleusInfo[0].lFrequency');
    equals_index=findstr(line,'= ');
end
txfrq=line(equals_index+1:end);
txfrq=str2double(txfrq);
fclose(fid);

%Get Date
fid=fopen(filename);
line=fgets(fid);
index=findstr(line,'ParamString."atTXCalibDate">');
%quotes_index=findstr(line,'  "');
while isempty(index) %|| isempty(equals_index)
    line=fgets(fid);
    index=findstr(line,'ParamString."atTXCalibDate">');
    if ~isempty(index)
        line=fgets(fid);
        line=fgets(fid);
        quote_index=findstr(line,'  "');
    end
end
date=line(quote_index+3:quote_index+10);
date=str2double(date);
fclose(fid);

%****************************************************************


%Calculate t and ppm arrays using the calculated parameters:
f=[(-spectralwidth/2)+(spectralwidth/(2*sz(1))):spectralwidth/(sz(1)):(spectralwidth/2)-(spectralwidth/(2*sz(1)))];
ppm=-f/(Bo*42.577);
ppm=ppm+4.6082;

t=[0:dwelltime:(sz(1)-1)*dwelltime];


%FILLING IN DATA STRUCTURE
out.fids=fids;
out.specs=specs;
out.sz=sz;
out.ppm=ppm;  
out.t=t;    
out.spectralwidth=spectralwidth;
out.dwelltime=dwelltime;
out.txfrq=txfrq;
out.date=date;
out.dims=dims;
out.Bo=Bo;

%FILLING IN THE FLAGS
out.flags.writtentostruct=1;
out.flags.gotparams=1;
out.flags.leftshifted=0;
out.flags.filtered=0;
out.flags.zeropadded=0;
out.flags.freqcorrected=0;
out.flags.phasecorrected=0;
out.flags.averaged=0;
out.flags.addedrcvrs=0;
out.flags.subtracted=0;
out.flags.writtentotext=0;
out.flags.downsampled=0;
if out.dims.subSpecs==0
    out.flags.ismegaspecial=0;
else
    out.flags.ismegaspecial=(out.sz(out.dims.subSpecs)==4);
end



%DONE
