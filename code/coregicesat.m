function [npts,p,dzstd]=coregicesat(pn,metafile)
% coregicesat.m
% pn: given pz, px, py if known, pz will be reset to 0, and recalculate using icesat2.
% npts: selected good points, 
% p: pz, px, py

constant
flagplot=0;

% demfile='/Users/chunlidai/greenland/testicesat/WV03_20231013_104001008B99B200_104001008C81BF00_2m_v040315/SETSM_s2s041_WV03_20231013_104001008B99B200_104001008C81BF00_2m_seg2_dem_10m.tif';
%demfile='/Users/chunlidai/greenland/testicesat/W1W1_20200621_1020010099747500_102001009CA18B00_2m_v040314/SETSM_s2s041_W1W1_20200621_1020010099747500_102001009CA18B00_2m_seg1_dem_10m.tif';
% demfile='/Users/chunlidai/greenland/testicesat/WV01_20190829_102001008BD03400_102001008B8CF500_2m_lsf_v040101/SETSM_s2s041_WV01_20190829_102001008BD03400_102001008B8CF500_2m_lsf_seg1_dem_10m.tif';
demfile=strrep(metafile,'meta.txt',demext);
data=readGeotiff(demfile); %target
bitmask=strrep(metafile,'meta.txt','bitmask.tif');
bit=readGeotiff(bitmask);

bit10m=interp2(bit.x,bit.y,bit.z,data.x,data.y','*nearest');

% % Filter out ocean points; coastline masks.
rang0=[min(data.x) max(data.x) min(data.y) max(data.y)];
infile='mask/GimpOceanMask_90m.tif';
Mocean=readGeotiff(infile,'map_subset',rang0); %1 ocean; 0 non ocean;
Moceani= interp2(Mocean.x,Mocean.y,Mocean.z,data.x,data.y','*nearest');

data.z=double(data.z); data.z(data.z<-100|bit10m~=0|Moceani==1)=nan;

% ICESAT-2 matfiles, good quality
%icesat=load('/Users/chunlidai/greenland/testicesat/W1W1_20200621_1020010099747500_102001009CA18B00_2m_v040314.mat');
% icesat=load('/Users/chunlidai/greenland/testicesat/WV01_20190829_102001008BD03400_102001008B8CF500_2m_lsf_v040101/WV01_20190829_102001008BD03400_102001008B8CF500_2m_lsf_v040101.mat');
% Extracting directory path and filename
[filepath, filename, ~] = fileparts(metafile);
% Replace 'strips_v4.1/2m' with 'is2' in the directory path
newDirectoryPath = strrep(filepath, 'strips_v4.1/2m', 'is2');
% Creating new file path
if newDirectoryPath(end) == '/'
    % Remove the last character
    newDirectoryPath= newDirectoryPath(1:end-1);
end
isfile= [strtrim(newDirectoryPath),'.mat'];

icesat=load(isfile);
x2=[];y2=[];z2=[];z2std=[];
for j=1:length(icesat)
            x2=[x2(:);icesat(j).x(:)];
            y2=[y2(:);icesat(j).y(:)];
            z2=[z2(:);double(icesat(j).h_li(:))];
            z2std=[z2std(:);double(icesat(j).h_li_sigma(:))];
end

% %Original h5 files, noisy
if 0
[demdir,name,ext] =fileparts(demfile);
str=sprintf('find  %s -name ''*.h5''',deblank(demdir));
[status, cmdout]=system(str);
% is2file='/Users/chunlidai/greenland/testicesat/processed_ATL06_20231019142049_04672105_006_01.h5'; %reference
is2file= split(deblank(cmdout));%deblank(cmdout);
x2=[];y2=[];z2=[];z2std=[];
for k=1:length(is2file)
    try
        icesat=readAtl06(is2file{k});
        for j=1:6
            x2=[x2(:);icesat(j).x(:)];
            y2=[y2(:);icesat(j).y(:)];
            z2=[z2(:);double(icesat(j).z(:))];
            z2std=[z2std(:);double(icesat(j).zstd(:))];
        end
    catch e
        fprintf(['\n coregicesat.m There was an error! The message was:',e.message,'; ICESat file:',is2file{k}]);
    end
end %for k
end

grayColor = [.7 .7 .7];

if flagplot==1
figure;imagesc(data.x*1e-3,data.y*1e-3,data.z);colorbar
xlabel('Polar stereographic coordinate x (km)')
ylabel('y (km)')
hold on;plot(x2*1e-3,y2*1e-3,'.-','color',grayColor)
% title('ArcticDEM WV03 2023/10/13 elevation (m)')
set(gcf,'Color','white')
end

%Just vertical offsets
% pn = [0;0;0];
pn(1)=0; %reset to zero for z;
 z2n = interp2(data.x - pn(2),data.y - pn(3),data.z - pn(1),...
            x2,y2,'*linear');
 dz = z2n - z2;
 n =  abs(dz - nanmedian(dz(:))) <= nanstd(dz(:));
 npts=sum(n(:));

 if flagplot==1
 hold on;plot(x2(n)*1e-3,y2(n)*1e-3,'ko')
 end

 fprintf(['\n Number of points: ',num2str(npts),'. \n'])

 meddz=median(dz(n)); 
 dzstd=nanstd(dz(n));
%  p=[meddz;0;0];
p=[meddz;pn(2);pn(3)];

fprintf(['\n dz +- dzstd :',num2str([meddz,dzstd]),'. \n'])

if flagplot==1
figure;errorbar(y2*1e-3,z2,z2std,'.','color',grayColor);xlabel('Polar stereographic coordinate y (km)');ylabel('Elevation (m)')
hold all; errorbar(y2(n)*1e-3,z2(n),z2std(n),'k.');xlabel('Polar stereographic coordinate y (km)');ylabel('Elevation (m)')
hold on; plot(y2(n)*1e-3,z2n(n),'r.')
set(gcf,'Color','white')
% hold on; plot(y2(n&Mocean)*1e-3,z2n(n&Mocean),'bo')
% legend('ICESat-2 ATL06 2023/10/19','ArcticDEM WV03 2023/10/13')
end

%  d1 = sqrt(mean(dz(n).^2));
% figure;plot(x2*1e-3,z2,'k.-',x2*1e-3,z2n,'r.-',x2*1e-3,z2n-p(1),'b.-')


% [z2out,p,d0] = coregisterdems1D(x2,y2,z2,data.x,data.y,data.z); %equation is not figured out.

return
end
