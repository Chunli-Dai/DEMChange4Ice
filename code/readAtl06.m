function data=readAtl06(filename)
% read ICESat-2 ATL06 data 
% refers to /Users/chunlidai/Library/CloudStorage/OneDrive-UniversityofFlorida/NASACryo20172020/rundata/helheim.m

RefDate = datenum(2018,01,01,0,00,00);

gtxg={'gt1l','gt1r','gt2l','gt2r','gt3l','gt3r'};%'gt1l';

data(6)=struct();

for j=1:6 % data type
        gtx=gtxg{j}; %'gt3r';%'gt1l';
        data(j).lat = h5read(filename,['/',gtx,'/land_ice_segments/latitude']);
        data(j).lon = h5read(filename,['/',gtx,'/land_ice_segments/longitude']);
        data(j).z = h5read(filename,['/',gtx,'/land_ice_segments/h_li']);
        data(j).zstd = h5read(filename,['/',gtx,'/land_ice_segments/h_li_sigma']);
        data(j).dhdx = h5read(filename,['/',gtx,'/land_ice_segments/fit_statistics/dh_fit_dx']); %along track slope, meter/meter
        data(j).dhdxstd = h5read(filename,['/',gtx,'/land_ice_segments/fit_statistics/dh_fit_dx_sigma']);
        data(j).dhdy = h5read(filename,['/',gtx,'/land_ice_segments/fit_statistics/dh_fit_dy']); %along track slope, meter/meter
        [data(j).x, data(j).y] = polarstereo_fwd(data(j).lat,data(j).lon,[],[],70,-45);
        data(j).dt = h5read(filename,['/',gtx,'/land_ice_segments/delta_time']);
        time_s = data(j).dt/60/60/24;
        data(j).time = RefDate+time_s;
        data(j).date=datestr(data(j).time(1),26);
        M=data(j).z>1e6;data(j).z(M)=nan;
        M=data(j).dhdx>1e6|data(j).dhdy>1e6;data(j).dhdx(M)=nan;data(j).dhdy(M)=nan;
        data(j).zaddc=data(j).z;
        %remove repeat points;
        df=abs(diff(data(j).x))+abs(diff(data(j).y));
        id=find(df==0);
        if ~isempty(id)
            data(j).lat(id)=[];data(j).lon(id)=[];data(j).z(id)=[];data(j).zstd(id)=[];
            data(j).dhdx(id)=[];data(j).dhdxstd(id)=[];data(j).dhdy(id)=[];
            data(j).x(id)=[];data(j).y(id)=[];
            data(j).dt(id)=[];data(j).time(id)=[];
            data(j).zaddc(id)=[];
        end
        
%         hold on;plot(data(j).x*1e-3,data(j).y*1e-3,'.-')
%          hold on;plot(data(j).lon,data(j).lat,'.')
%         lonlat=[lonlat;[data(j).lon,data(j).lat];[nan nan]];

end %j

        return
end
