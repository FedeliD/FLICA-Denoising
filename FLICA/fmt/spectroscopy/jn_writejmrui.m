function RF=jn_writejmrui(in,outfile);
%function RF=writejmrui(data_struct,outfile);
%data_struct is the name of the data structure that you would like to use
%outfile is the name of the file that you would like to create (use .txt)
%type:  'y' for difference or addition spectra, 'n' for non-difference spectra
%index:  when type=='n', choose index number of spectrum to create

datsets=1;
zop=0;
t0=0;
Bo=in.Bo;
Nuc=0;
PatName='No Name';
scanner='TrioTim';
addinfo='jnear';

%type=input('Is this a difference spectrum (MEGA etc.)  y or n:  ','s');


%index=input('Enter Fid Index to use:  ');
RF=zeros(length(in.fids),4);
RF(:,1)=real(in.fids);
RF(:,2)=imag(in.fids);
RF(:,3)=real(in.specs);
RF(:,4)=imag(in.specs);




%write to txt file for jmrui
fid=fopen(outfile,'w+');
fprintf(fid,'jMRUI Data Textfile');
fprintf(fid,'\n\nFilename: %s' ,outfile);
fprintf(fid,'\n\nPointsInDataset: %i',length(RF(:,1)));
fprintf(fid,'\nDatasetsInFile: %i',datsets);
fprintf(fid,'\nSamplingInterval: %4.6E',in.dwelltime*1000);
fprintf(fid,'\nZeroOrderPhase: %1.0E',zop);
fprintf(fid,'\nBeginTime: %1.0E',t0);
fprintf(fid,'\nTransmitterFrequency: %4.6E',in.txfrq);
fprintf(fid,'\nMagneticField: %4.6E',Bo);
fprintf(fid,'\nTypeOfNucleus: %1.0E',Nuc);
fprintf(fid,'\nNameOfPatient: %s',PatName);
fprintf(fid,'\nDateOfExperiment: %i',in.date);
fprintf(fid,'\nSpectrometer: %s',scanner);
fprintf(fid,'\nAdditionalInfo: %s\n\n\n',addinfo);
fprintf(fid,'Signal and FFT\n');
fprintf(fid,'sig(real)\tsig(imag)\tfft(real)\tfft(imag)\n');
fprintf(fid,'Signal 1 out of %i in file\n',datsets);
fprintf(fid,'%1.8f\t%1.8f\t%1.8f\t%1.8f\n',RF');
fclose(fid);