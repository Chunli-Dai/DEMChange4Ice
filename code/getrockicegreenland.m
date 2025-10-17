%addpath(genpath(['/home/dai.56/arcticdemapp/landslide/code1/']));

%get mask from mask mask/GimpIceMask_90m.tif;
%rang0=[-268840  -228840 -2772800 -2732800];

%[tag]=getrgi(rang0);
function tag = getrockicegreenland(rang0);
infile='mask/GimpIceMask_90m.tif';
tag=readGeotiff(infile,'map_subset',rang0);
infile='mask/GimpOceanMask_90m.tif';
ocean=readGeotiff(infile,'map_subset',rang0);

tag.z=~(tag.z)&~(ocean.z); %1 rock; 0 non-rock
%save('BarnesrockRGI_sw.mat','tag','-v7.3')
save('rockmask.mat','tag','-v7.3')

%% write output
projstr='polar stereo north';
OutName=['rockmask.tif']; % %1 is good (landslide); 0 is bad
writeGeotiff(OutName,tag.x,tag.y,int32(tag.z),3,0,projstr)

return
end
