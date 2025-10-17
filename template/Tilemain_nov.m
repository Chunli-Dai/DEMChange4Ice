
% main program for getting coastline for each ArcticDEM tile
% Requirements: gdal software
% %%%% inputs needed
macdir='/Users/chunlidai/surge/';
macdir=[];
constant

currentdir=pwd;
%addpath(genpath(currentdir));
addpath(genpath(['~/workpfe/greenland/code1/']));

shpname='./GSHHS/GSHHS_f_L1.shp';% a priori coastline shapefile

%General directory that contains the tile DEM files, such as /elev/dem/setsm/ArcticDEM/mosaic/v2.0/
tiledir=[macdir,'/fs/byo/howat-data3/ArcticDEMmosaics/'];

stripdir='~/workpfe/greenland/ArcticDEM/';
%stripdir=currentdir;

% %%%% control parameters
width=2e3; %buffer width of the a priori coastline, e.g., 2km.

if ~exist('mat0.mat','file') %readding boundary; time 1 hour for 90751 strip files and 10130 mono xml files

% %%% Preparation: get the list of strip files and boundries
filename='boundaries_regall_strip.dat'; %'boundaries_reg31.dat';
filename='striplist.dat';
if ~exist(filename,'file')
   %str=sprintf('find  %s -name ''*mdf.txt'' > %s',deblank(stripdir),filename);
   str=sprintf('find  %s -name ''*meta.txt'' > %s',deblank(stripdir),filename);
  [status, cmdout]=system(str);
end
fprintf ('\n Step 0: geting the boundary for all files in the region.\n')
%READ INPUT PARAMETERS; getting the boundaries for all files
% filename='boundaries_reg31.dat';
fid = fopen(filename);
n = linecount(fid);
fid = fopen(filename);
range=zeros(n,4);XYbg=cell(n,1);
for i=1:n
   ifile=[macdir,fgetl(fid)];
   [demdir,name,ext] =fileparts([strtrim(ifile)]);
   f{i}=[name,ext];
   fdir{i}=[demdir,'/'];%working on two regions 
   satname=f{i}(1:4);

   % get the boundary from xml file
   [XYbi,rangei]=imagebd(ifile);
   range(i,1:4)=rangei;XYbg{i}=XYbi;
end

save mat0.mat -v7.3

else 
load mat0.mat
end

%% calculate NOV 

    if strcmp(projgdal(1:7),'epsg:32') %earthdem tiles epsg:32606 
        %lat lon
	x0=-180; y0=-70;
	xe=180; ye=70;
	resrc=0.02; % 0.01 degree =1km;
    elseif strcmp(projgdal,'epsg:3413')  % arcticdem tiles, e.g., 51_08_2_2_01_02

       dx=100e3;x0=-4000e3;y0=-4000e3;%xe=3400e3;ye=4000e3; %ArcticDEM Mosaic tiles coordinate reference;
       xe=3400e3;ye=4000e3; %ArcticDEM Mosaic tiles coordinate reference;
       resrc=400;
    elseif strcmp(projgdal,'epsg:3031')  %Antarctica
        %   dx=100e3; x0=-4000e3;y0=-4000e3; %1000e3 larger than REMA tiles, e.g., 40_09_1_1
            dx=100e3; x0=-4000e3+1000e3;y0=-4000e3+1000e3;
	    xe=4000e3;ye=4000e3; 
            resrc=400;
    end

ofile='greenland_nov.tif';
if exist(ofile,'file')
nov=readGeotiff(ofile);
nx=length(nov.x);ny=length(nov.y);
else %40m resolution
% integer type, 0 for nan.
%resrc=400;
nov.x=x0:resrc:xe;
nov.y=ye:(-resrc):y0;
nx=length(nov.x);ny=length(nov.y);
nov.z=uint16(zeros(ny,nx));
end

resrc=mean(diff(nov.x));
%M=logical(size(nov.z));

novt=nov; % for this region
novt.z=uint16(zeros(ny,nx));

for i=1:n
        XYbi=XYbg{i};
        Xb=XYbi(:,1);Yb=XYbi(:,2);

	if length(Xb)<=2|length(Xb(~isnan(Xb)))<=2|length(Yb(~isnan(Yb)))<=2
		fprintf(['\n Xb Yb bad for:',f{i},'\n'])
		continue;
	end

	if strcmp(projgdal(1:7),'epsg:32')
		%xy to lat lon
		projgdalj=projgdalg{i};
		xj=Xb;yj=Yb;
           	[latj,lonj]=xy2latlon(xj,yj,projgdalj);
		Xb=lonj;Yb=latj;
	end

        idx=round((Xb-nov.x(1))/resrc)+1;
        idy=round((Yb-nov.y(1))/(-resrc))+1;
        Mb = poly2mask(idx,idy, ny,nx); % build polygon mask       
        novt.z=novt.z + uint16(Mb);
end

%update nov with the new novt when nov is zero and novt is larger.
M=novt.z>nov.z;
nov.z(M)=novt.z(M);

%projstr='polar stereo north';
projstr=projstrin;
writeGeotiff(ofile,nov.x,nov.y,uint16(nov.z),12,255,projstr)

