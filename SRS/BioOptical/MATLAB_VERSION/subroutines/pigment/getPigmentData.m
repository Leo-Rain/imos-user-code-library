function profileData=getPigmentData(ncFile,variable,profile)
%% getPigmentData
% This function loads the data of one profile number 'profile' from a netcdf file
% 'ncFile' for one variable.
%
% Syntax:  profileData=getPigmentData(ncFile,variable,profile)
%
% Inputs: ncFile   - string of the NetCDF location
%         variable - string of variable name
%         profile  - number of profile to grab data from
%
% Outputs: profileData - structure with values and metadata of the profile
%
%
% Example:
%    profileData=getPigmentData('/this/is/thepath/IMOS_test.nc','ag',1)
%
% Other m-files
% required:
% Other files required:config.txt
% Subfunctions: mkpath
% MAT-files required: none
%
% See also:
%  getPigmentInfo,plotPigment,getPigmentData
%
% Author: Laurent Besnard, IMOS/eMII
% email: laurent.besnard@utas.edu.au
% Website: http://imos.org.au/  http://froggyscripts.blogspot.com
% Aug 2011; Last revision: 28-Nov-2012
%
% Copyright 2012 IMOS
% The script is distributed under the terms of the GNU General Public License

if ~ischar(ncFile),          error('ncFile must be a string');        end
if ~ischar(variable),        error('variable must be a string');        end
if ~isstruct(profile),       error('profile must be a structure');        end


if exist(ncFile,'file') ==2
    nc = netcdf.open(char(ncFile),'NC_NOWRITE');
    
    try
        [allVarnames,~]=listVarNC(nc);
        
        % 8 known variables
        dimidTIME = netcdf.inqVarID(nc,'TIME');
        dimidLAT = netcdf.inqVarID(nc,'LATITUDE');
        dimidLON = netcdf.inqVarID(nc,'LONGITUDE');
        dimidDEPTH= netcdf.inqVarID(nc,'DEPTH');
        dimidstation_name= netcdf.inqVarID(nc,'station_name');
        dimidprofile= netcdf.inqVarID(nc,'profile');
        dimidstation_index= netcdf.inqVarID(nc,'station_index');
        dimidrowSize= netcdf.inqVarID(nc,'rowSize');
        
        [~, numvars, ~, ~] = netcdf.inq(nc);
        tttt=1:numvars;
        ttt=tttt(setdiff(1:length(tttt),[tttt(dimidTIME+1),tttt(dimidLAT+1),...
            tttt(dimidLON+1),tttt(dimidDEPTH+1),...
            tttt(dimidstation_name+1),tttt(dimidprofile+1),tttt(dimidstation_index+1),...
            tttt(dimidrowSize+1)]));
        for ii=1:length(ttt)
            % dimidVAR{ii}= netcdf.inqVarID(nc,allVarnames{ttt(ii)});
            variableList{ii}=allVarnames{ttt(ii)};
        end
        dimidVAR= netcdf.inqVarID(nc,variable.varname);
        
        
        rowSize=getVarNetCDF('rowSize',nc);
        StationIndex=getVarNetCDF('station_index',nc);
        StationNames=getVarNetCDF('station_name',nc);
        
        %% which profile do we plot ?
        strlen=size(StationNames,1);
        nStation=length(unique(StationIndex));
        for iiStation=1:nStation
            stationName{iiStation}=regexprep(StationNames(1:strlen,iiStation)','[^\w'']','');
        end
        
        
        numberObsSation=rowSize( profile);
        startIndexStation=sum(rowSize(1:profile-1));
        
        
        varData=double(netcdf.getVar(nc,dimidVAR,startIndexStation,[numberObsSation]));
        varData(varData==variable.FillValue)=NaN;
        depthData=double(netcdf.getVar(nc,dimidDEPTH,startIndexStation,[numberObsSation]));
        time=getVarNetCDF('TIME',nc);
        timeData=time(profile);
        lon=getVarNetCDF('LONGITUDE',nc);
        lonData=lon(StationIndex(profile));
        lat=getVarNetCDF('LATITUDE',nc);
        latData=lat(StationIndex(profile));
        
        
        
        profileData.mainVarAtt=variable;
        profileData.depth=depthData;
        profileData.mainVar=varData;
        profileData.mainVarname=variable.varname;
        profileData.stationName=char(stationName(StationIndex(profile)));
        profileData.latitude=latData;
        profileData.longitude=lonData;
        profileData.time=timeData;
        
        netcdf.close(nc)
    catch err
        netcdf.close(nc)
        error('MATLAB:NetCDF',  'error while reading NetCDF');
    end
    
end