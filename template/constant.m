

% 1 assume event time known; 0 assume time unknown
eqepoch=0;timefix=0;

flagvolc=0; %1 volcano event, a duration of time; 0 landlside, a sudden change.
jumpflagc=1; %1: chose to estimte change no matter it's significant or not.
	      %otherwise: the algorithm decide not to estimate the change if it's not significant.
smlarea=200; %remove clusters smaller than this; square meters 
cloudarea=13e3*30e3/20*8;

mons=7;mone=8; %mon>=5&mon<=10; %mons, start month of snow-free seasons. %mone, end month of snow free months.
mons=1;mone=12; %all season.

algorithmin=1;%fit model for time series. 
	%e.g.  1 linear (ice melting); 2 constant (landslides) ; 3 constant + linear (Okmok volcano)
poolsize=1; %24;
resr=200;  %2; %4;%40.; 200;

flagrock=0; %1 must use rock as control points (for ice melting); 0 it's ok if there are no rock control points (change detection).

flagplot=0;

flagfilter=1; %1 use the bitmask.tif to map out bad DEMs before change detection;
flagfiltercoreg=0;  %Recommend 0 (Not apply the filtering mask). 
		%1 \use the bitmask.tif to map out bad DEMs for setsm coregistration (coregflat=8);
		% Due to the improvement of coregistration, the cloudy image is not filtered out in the offset re-adjustment step.
	         % Check ~/chunliwork/landslide/alaska3c/site1/5kmoffsetErrMax_filter/ 

coregflag=8;% Not used when flagcoregis=1 ; %1 parameter (vertical), 3 parameter (Ian's); 7 parameter (MJ's); 8, MJ's setsm coregistration with 3 parameters.
flagcoregis=1; %0, only bundle adjustment and no coregistration with icesat2; 1, no bundle adjustment and only use icesat2 for z direction ; 2, use bundle adjustment for horizontal and icesat2 for vertical.
flaggpr=1; %1, use Gaussian Process Regression Models; 0 do not use GPR.
t1gpr=datenum('2019/06/01');t2gpr=datenum('2023/06/01');

maxdt=1e9; %0.5; % in days;  filter out cross-track collected more than maxdt;
year_start=0;year_end=9999; % min max year of measurement; year >= years and year <= yeare %default no limit [0, 9999]
maxreduce=1e9; % if number of strips larger than maxreduce, Only keep summer data and In-track data.

flagoutput=0; %if 1 output lots of figures and data for plotting, 0 save space;

maxpxpy=15; maxpz=20; maxsigma=15;% Recommend: maxpxpy=15; maxpz=20;maxsigma=15;ArcticDEM with coregflag=8;
%maxpxpy=15; maxpz=20; maxsigma=10;% Default: maxpxpy=15; maxpz=20;maxsigma=10;ArcticDEM;
% maxpxpy=50;maxpz=50; maxsigma=30; % other dems in coreg3.m adjustOffsets.m coregisterdems.m

flaggreenland=1; %1 use GIMP masks for greenland; 0 otherwise;
flagfilteradj=0;%1 apply filter in adjustOffsets.m, 0 do not apply filter (use all DEMs).
flagmatchtag=1; %Recommend 1. Whether or not to use matchtag as a filter to DEM; 1 apply filter; 0 not apply.

flag_diffdems=0; %Recommend 0. 1 output sequential DEM difference; 0 DO NOT output these.

demext='dem_10m.tif';%'dem.tif';

projgdal='epsg:3413'; % epsg:3031 epsg:32606
projstrin='polar stereo north'; % 'polar stereo south'; 'UTM zone 45 north';

