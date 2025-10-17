
addpath(genpath(['/home/dai.56/arcticdemapp/landslide/code1/']));

z1 ='44R';
[ellipsoid,estr] = utmgeoid(z1);
utmstruct = defaultm('utm'); 
utmstruct.zone = z1; 
utmstruct.geoid = ellipsoid; 
utmstruct = defaultm(utmstruct);

%get rang0
if 0
lon1=[78.6 78.6 79.6 79.6 78.6];lat1=[30.5 31.2 31.2 30.5 30.5];
shp1 = struct('Geometry', 'PolyGon', 'X', lon1, 'Y', lat1);
shapewrite(shp1, 'himalayas.shp');

%z1 = utmzone([lat1(1) lon1(1)]); %6W

% [xq1,yq1]=polarstereo_fwd(lat1,lon1,[],[],70,-45); %wrong
[xq1,yq1]=mfwdtran(utmstruct,lat1,lon1);
figure; hold all; plot(xq1*1e-3,yq1*1e-3,'.-')
rang0=round([min(xq1)-1e3 max(xq1)+1e3 min(yq1)-1e3 max(yq1)+5e3]/1e3)*1e3;
x0=[rang0(1) rang0(2) rang0(2) rang0(1) rang0(1) ];y0=[rang0(4) rang0(4) rang0(3) rang0(3) rang0(4) ];
hold all;plot(x0*1e-3,y0*1e-3,'.-')

rang0=[5738000     5891000     3857000     4020000]; %zone1 %wrong coordinate transformation
rang0=[269000      368000     3374000     3490000]; %zone 1 corrected; use this one
% rang0=[287000 387000 3342000 3546000]; %zone2; too many locations have no measurements < 3
% rang0=[300e3 375e3 3415e3 3490e3]; %zone 3


%get rock mask 
%refer to /fs/project/howat.4/dai.56/chunliScripts/scripts/plotsrtmvs.m

addpath(genpath(['/home/dai.56/arcticdemapp/landslide/code1/']));
tic
[tag]=getrgi(rang0);
toc
%save('BarnesrockRGI.mat','tag','-v7.3')
save('BarnesrockRGI_zone1.mat','tag','-v7.3')

end %if 0

%zone 5 % saurabh's site
latlon=[
30.821158, 79.267569;
30.723327, 79.250066;
30.779960, 79.434993];
[xq1,yq1]=mfwdtran(utmstruct,latlon(:,1),latlon(:,2));

rang0=[331000	351000	3399000	3416000];

[tag]=getrgi(rang0);
