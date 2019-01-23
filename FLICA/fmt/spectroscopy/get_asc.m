function sASC = get_asc(filename)
%%
% function sASC = get_asc(filename)
% read SIEMENS meas.ASC header file
%
%%% Entries
%'SThick'                % SliceThickness [mm]                  
%'FOVph'                 % FOV phase [mm]
%'FOVrd'                 % FOV readout [mm]
%'NSlice'                % # of slice
%'NTimepoint'            % ADC time
%'ResRd',                % desired Image Resolution 
%'NPhase'                % desired # of phase encoding
%'NSample'               % desired # of samples per one phase line
%'NoOfColumns'           % acquired K-space # of columns
%'NoOfLines'             % acquired K-space # of lines
%'Ramup'                 % Rampup time [us]
%'Flat'                  % Flattop time [us]
%'SampleDelay'           % Sample delay time [us]
%'ADCtime'               % ADC time [us]
%'TR'                    % TR [sec]
%'TE'                    % TE [ms]
%'Version'               % IDEA version
%'SeqName'               % Sequence Name
%'fname'                 % ASC/DAT file name including entire path and extension
%'Supported'             % Supported vertion  [True or False]      
%
% EXAMPLE
% 1.get_asc
% 2.sASC = get_asc 
% 3.sASC = get_asc('d:\meas\siemen_meas.asc')
% 4.sASC = get_asc('d:\meas\siemen_meas.dat')
% 5.sASC = get_asc('d:\meas\siemen_meas')
% 
% SIEMENS, Compatible with
% N4_VA25A_LATEST_20040724
% N4_VB12T_LATEST_20050820
% N4_VB13A_LATEST_20060607
%
% Copyright, Jaemin Shin
% jaemins@gatech.edu
% 2006.12.12
% 2006.12.27 : VB13A
% 2007.05.11 : Supported flag


%% file & GUI handling
% Old version Compatability 
% To support get_asc('d:/meas/siemen_meas'), i.e., w/o extension name
cpath = pwd;
if nargin == 0
    filename='';
    if isunix
        rpath = '/data/home/jshin/';
    else
        rpath = 'Y:/';
    end
    cd([rpath])
elseif strcmp(filename(end-2:end),'dat') || strcmp(filename(end-2:end),'asc')
    filename = filename(1:end-4);
end
fnameasc=[filename,'.dat'];
fida=fopen(fnameasc,'r');
if nargout > 0,sASC = []; end
if fida<3
    fnameasc=[filename,'.asc'];
    fida=fopen(fnameasc,'r');
    if fida<3 
        [fname, path]=uigetfile({'*.asc;*.dat'}, 'Choose an ASC or DAT File');
        if isequal(fname,0) || isequal(path,0), return;end
        fnameasc = [path,fname];
        fida=fopen(fnameasc,'r');
    end
end
%% DAT or ASC
if strcmp(fnameasc(end-2:end),'dat')
    header_size=fread(fida,1,'int32');
    header=fread(fida,header_size,'*char')';
    idx=find(header=='#');
    fseek(fida,idx(1)+4,'bof');
end
%% Version Check
% READ "sProtConsistencyInfo.tBaselineString"
% and "tSequenceFileName"
str = fgetl (fida);
[token, value] = strtok(str);
while   (strcmp(token,'sProtConsistencyInfo.tBaselineString')==0)
    str = fgetl (fida);
    if ~ischar(str),   disp('BREAK'),break,   end
    [token, value] = strtok(str);
    value = deblank(value);
    value = deblank(value(end:-1:1));
    value = value(end:-1:1);
    if strcmp(token, 'tSequenceFileName')
        SeqName=value(4:end-1);
    end
end
Version = value(4:end-1);
% sASC structure
sASC = struct(...
  'SThick',0,...                             
  'FOVph',0,...                             
  'FOVrd',0,...                            
  'NSlice',0,...                           
  'NTimepoint',0,...                       
  'ResRd',0,...                            
  'NPhase',0,...                           
  'NSample',0,...                         
  'NoOfColumns',0,...                       
  'NoOfLines',0,...                       
  'Ramup',0,...                          
  'Flat',0,...                             
  'SampleDelay',0,...                       
  'ADCtime',0,...                     
  'TR',0,...                                
  'TE',0,...
  'Version',Version,...
  'SeqName',SeqName,...
  'fname',fnameasc,...
  'Supported',true);                                 

%% Call get_asc function
switch sASC.Version
    case 'N4_VB15B_LATEST_20071110' % danielg@fmrib
        sASC = get_asc_VB15A(fida,sASC);
    case 'N4_VB15A_LATEST_20070519' % danielg@fmrib
        sASC = get_asc_VB15A(fida,sASC);
    case 'N4_VB13A_LATEST_20060607' % Same as 'VB12T'
        sASC = get_asc_VB12T(fida,sASC); 
    case 'N4_VB12T_LATEST_20050820'
        sASC = get_asc_VB12T(fida,sASC);
    case 'N4_VA25A_LATEST_20040724'
        sASC = get_asc_VA25A(fida,sASC);
    otherwise
        sASC.Supported = false;
        disp(sASC.Version)
        disp('This version is NOT supported')
        return
end
cd(cpath)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunctions
% 1. function sASC = get_asc_VB12T(fida,filename)
% 2. function sASC = get_asc_VA25A(fida,filename)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sASC = get_asc_VB15A(fida,sASC)
% sASC = get_asc_VB15A(fida,filename)
% read meas.ASC header file
% See Also "sASC = get_asc"
%%

% total length: 32 * 32 Bit (128 Byte)            128
str = fgetl (fida);
[token, rem] = strtok(str);
while   isempty(strmatch(str, '### ASCCONV END ###'))
    str = fgetl (fida);
    if ~ischar(str),   disp('BREAK'),break,   end
    [token, rem] = strtok(str);
    remtm = deblank(rem);
    remtm = deblank(remtm(end:-1:1));
    rems = remtm(end:-1:1);

    if strcmp(token, 'alTR[0]')
        sASC.TR=str2num(rems(3:end))*1e-6;
    end
    
    if strcmp(token, 'alTE[0]')
        sASC.TE=str2num(rems(3:end))*1e-3;
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dThickness')
        sASC.SThick=str2num(rems(3:end));
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dPhaseFOV')
        sASC.FOVph=str2num(rems(3:end));
    end

    if strcmp(token, 'sSliceArray.asSlice[0].dReadoutFOV')
        sASC.FOVrd=str2num(rems(3:end));       
    end

    if strcmp(token, 'sSliceArray.lSize')
        sASC.NSlice=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lBaseResolution')
        sASC.ResRd=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lPhaseEncodingLines')
        sASC.NPhase=str2num(rems(3:end));
    end

    %% danielg@fmrib: don't know how to find this in VB15!
%     if strcmp(token, 'lRepetitions')  
%         sASC.NTimepoint=str2num(rems(3:end))+1;
%     end

%     if strcmp(token, 'iNoOfFourierColumns')
%         sASC.NoOfColumns=str2num(rems(3:end));
%     end
%     
%     if strcmp(token, 'iNoOfFourierLines')
%         sASC.NoOfLines=str2num(rems(3:end));
%     end

%     if strcmp(token, 'alRegridRampupTime[0]')
%         temp=str2num(rems(3:end));
%         sASC.Ramup = temp(1);
%     end
% 
%     if strcmp(token, 'alRegridFlattopTime[0]')
%         temp=str2num(rems(3:end));
%         sASC.Flat = temp(1);
%     end
% 
%     if strcmp(token, 'alRegridDelaySamplesTime[0]')
%         temp=str2num(rems(3:end));
%         sASC.SampleDelay = temp(1);
%     end
%     
%     if strcmp(token, 'aflRegridADCDuration[0]')
%         temp=str2num(rems(3:end));
%         sASC.ADCtime = temp(1);
%     end
    
    if strcmp(token, 'flReadoutOSFactor')
        OSFactor=str2num(rems(3:end));
        sASC.OSFactor = OSFactor;
    end
    
    if strcmp(token, 'sPat.lAccelFactPE')
        sASC.accelFactPE = str2num(rems(3:end));
    end
    
%     if strcmp(token, 'sWiPMemBlock.alFree[8]')
%        disp('ZSAGACali')
%        disp(str2num(rems(3:end)))
%     end
%     
%     if strcmp(token, 'sWiPMemBlock.alFree[9]')
%        disp(str2num(rems(3:end)))
%     end


end


% danielg@fmrib: borrow some code from read_meas_dat to extract parameters
% in the XML type format
fseek(fida,0,-1);
data_start = fread(fida, 1, 'uint32');

% read header into one string for parsing
header = fscanf(fida, '%c', data_start-4);

param_list = {'NColMeas','iNoOfFourierColumns', 'iNoOfFourierLines', 'alRegridRampupTime', 'alRegridDelaySamplesTime',...
    'alRegridRampdownTime','alRegridFlattopTime','aflRegridADCDuration','flReadoutOSFactor',...
    };

dimensions = cell2struct(cell(length(param_list),1), param_list, 1);
dim = zeros(1,length(param_list));

% scan through header for each of the ICE dimension values
for ind = 1:length(param_list),
    param = param_list{ind};

    % exploit MATLAB regexp machinery to pull out parameter/value pairs
    if strcmp(param(1:2),'al')
        % this is an array, so need to get at least two values
        match = regexp(header, ['(?<param>' param, ').{2}\s*\{\s*(?<value>\d*)\s*(?<dummy>\d*)\s*\}'], 'names');
    elseif strcmp(param(1:2),'af')
        % this has <Precision> 6 specified before the array we are
        % interested in
        match = regexp(header, ['(?<param>' param, ').{2}\s*\{\s*.{11}\s{1}\d*\s*(?<value>\d*\.*\d*)\s*(?<dummy>\d*\.*\d*)\s*\}'], 'names');
    elseif strcmp(param(1:2),'fl')
        match = regexp(header, ['(?<param>' param, ').{2}\s*\{\s*.{11}\s{1}\d*\s*(?<value>\d*\.*\d*)\s*\}'], 'names');
    else
        match = regexp(header, ['(?<param>' param, ').{2}\s*\{\s*(?<value>\d*)\s*\}'], 'names');
    end

    % check if no match is found
    if ( isempty(match) ),
        continue;
    end;

    % consider only last match (there can be as many as three in Config_.evp)
    match = match(end);

    % empty means number of elements in this dimension = 1
    if ( isempty(match.value) ),
        match.value = '1';
    end;

    % save out struct and numerical array
    dim(ind) = str2double(match.value);
    dimensions.(param_list{ind}) = dim(ind);

end;

sASC.NoOfColumns = dimensions.iNoOfFourierColumns;
sASC.NoOfLines = dimensions.iNoOfFourierLines;
sASC.Ramup = dimensions.alRegridRampupTime;
sASC.Flat = dimensions.alRegridFlattopTime;
sASC.SampleDelay = dimensions.alRegridDelaySamplesTime;
sASC.ADCtime = dimensions.aflRegridADCDuration;
sASC.NSample = dimensions.flReadoutOSFactor * sASC.ResRd;
fclose(fida);



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%
function sASC = get_asc_VB12T(fida,sASC)
% sASC = get_asc_VB12T(fida,filename)
% read meas.ASC header file
% See Also "sASC = get_asc"
%%
% jaemins
% 09/26/2005
% 02/28/2006 if error, add ui
% 06/12/2006 : Trio Upgrade (N4_VB12T_LATEST_20050820)
% 09/12/2006 : Partial K-space (NoOfColumns,NoOfLines)
% 12/12/2006 : multi-idea with get_asc
% 12/27/2006 : N4_VB13A_LATEST_20060607 (same)
%%

% total length: 32 * 32 Bit (128 Byte)            128
str = fgetl (fida);
[token, rem] = strtok(str);
while   (strcmp(token, 'lNoOfImagScanPerPhaseStabScan')==0)
    str = fgetl (fida);
    if ~ischar(str),   disp('BREAK'),break,   end
    [token, rem] = strtok(str);
    remtm = deblank(rem);
    remtm = deblank(remtm(end:-1:1));
    rems = remtm(end:-1:1);

    if strcmp(token, 'alTR[0]')
        sASC.TR=str2num(rems(3:end))*1e-6;
    end
    
    if strcmp(token, 'alTE[0]')
        sASC.TE=str2num(rems(3:end))*1e-3;
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dThickness')
        sASC.SThick=str2num(rems(3:end));
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dPhaseFOV')
        sASC.FOVph=str2num(rems(3:end));
    end

    if strcmp(token, 'sSliceArray.asSlice[0].dReadoutFOV')
        sASC.FOVrd=str2num(rems(3:end));       
    end

    if strcmp(token, 'sSliceArray.lSize')
        sASC.NSlice=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lBaseResolution')
        sASC.ResRd=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lPhaseEncodingLines')
        sASC.NPhase=str2num(rems(3:end));
    end

    if strcmp(token, 'lRepetitions')
        sASC.NTimepoint=str2num(rems(3:end))+1;
    end

    if strcmp(token, 'iNoOfFourierColumns')
        sASC.NoOfColumns=str2num(rems(3:end));
    end
    
    if strcmp(token, 'iNoOfFourierLines')
        sASC.NoOfLines=str2num(rems(3:end));
    end

    if strcmp(token, 'alRegridRampupTime[0]')
        temp=str2num(rems(3:end));
        sASC.Ramup = temp(1);
    end

    if strcmp(token, 'alRegridFlattopTime[0]')
        temp=str2num(rems(3:end));
        sASC.Flat = temp(1);
    end

    if strcmp(token, 'alRegridDelaySamplesTime[0]')
        temp=str2num(rems(3:end));
        sASC.SampleDelay = temp(1);
    end
    
    if strcmp(token, 'aflRegridADCDuration[0]')
        temp=str2num(rems(3:end));
        sASC.ADCtime = temp(1);
    end
    
    if strcmp(token, 'flReadoutOSFactor')
        OSFactor=str2num(rems(3:end));
        sASC.OSFactor = OSFactor;
    end
    
    if strcmp(token, 'sPat.lAccelFactPE')
        sASC.accelFactPE = str2num(rems(3:end));
    end
    
%     if strcmp(token, 'sWiPMemBlock.alFree[8]')
%        disp('ZSAGACali')
%        disp(str2num(rems(3:end)))
%     end
%     
%     if strcmp(token, 'sWiPMemBlock.alFree[9]')
%        disp(str2num(rems(3:end)))
%     end


end
if ischar(str)
sASC.NSample = OSFactor * sASC.ResRd;
fclose(fida);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function sASC = get_asc_VA25A(fida,sASC)
% sASC = get_asc(filename)
% read meas.ASC header file
% See Also "sASC = get_asc"
%%%%%%
% N4_VA25A_LATEST_20040724
% jaemins
% 09/26/2005 
% 12/12/2006 : multi-idea with get_asc
%%

str = fgetl (fida);
[token, rem] = strtok(str);
while   (strcmp(token, 'm_lPhaseStabScanPosition')==0)
    str = fgetl (fida);
    if ~ischar(str),   disp('BREAK'),break,   end
    [token, rem] = strtok(str);
    remtm = deblank(rem);
    remtm = deblank(remtm(end:-1:1));
    rems = remtm(end:-1:1);

    if strcmp(token, 'alTR[0]')
        sASC.TR=str2num(rems(3:end))*1e-6;
    end
    
    if strcmp(token, 'alTE[0]')
        sASC.TE=str2num(rems(3:end))*1e-3;
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dThickness')
        sASC.SThick=str2num(rems(3:end));
    end
    
    if strcmp(token, 'sSliceArray.asSlice[0].dPhaseFOV')
        sASC.FOVph=str2num(rems(3:end));
    end

    if strcmp(token, 'sSliceArray.asSlice[0].dReadoutFOV')
        sASC.FOVrd=str2num(rems(3:end));       
    end

    if strcmp(token, 'sSliceArray.lSize')
        sASC.NSlice=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lBaseResolution')
        sASC.ResRd=str2num(rems(3:end));
    end

    if strcmp(token, 'sKSpace.lPhaseEncodingLines')
        sASC.NPhase=str2num(rems(3:end));
    end

    if strcmp(token, 'lRepetitions')
        sASC.NTimepoint=str2num(rems(3:end))+1;
    end
    
     if strcmp(token, 'm_iNoOfFourierColumns')
        sASC.NoOfColumns=str2num(rems(3:end));
    end
    
    if strcmp(token, 'm_iNoOfFourierLines')
        sASC.NoOfLines=str2num(rems(3:end));
    end

    if strcmp(token, 'm_alRegridRampupTime')
        temp=str2num(rems(3:end));
        sASC.Ramup = temp(1);
    end

    if strcmp(token, 'm_alRegridFlattopTime')
        temp=str2num(rems(3:end));
        sASC.Flat = temp(1);
    end

    if strcmp(token, 'm_alRegridDelaySamplesTime')
        temp=str2num(rems(3:end));
        sASC.SampleDelay = temp(1);
    end
    
    if strcmp(token, 'm_aflRegridADCDuration')
        temp=str2num(rems(3:end));
        sASC.ADCtime = temp(1);
    end
    
    if strcmp(token, 'm_flReadoutOSFactor')
        OSFactor=str2num(rems(3:end));
    end
    
end
if ischar(str)
sASC.NSample = OSFactor * sASC.ResRd;
fclose(fida);
end
