
This code can estimate ice surface elevation change rates from time-stamped ArcticDEM data, coregistered with ICESat-2 data.

Step 1: update settings in constant.m; make sure tilelist contains the list of tiles to run; 
	prepare striplist.dat file (example provided) to include all available DEM strip files in your study area.
	update code directory in compile.sh
	copy folder SETSM basics glims_2019 GSHHS from https://github.com/Chunli-Dai/DEMChangeDetection/tree/main/code to the directory code/

Step 2: run Tilemain_nov.m to update the arcticdem_nov.tif and get mat0.mat.

Step 3: ./compile.sh #to compile all matlab codes. 

Step 4: nohup ./run_change_group_pgc_par.sh > outrun1 &


Output files: Elevation change data for an area size of 2 km by 2km.
It is suggested to run two scenarios. One is using summer (July August) data only, the other is using data from all seasons.

The result includes:
26_44_2_1_listused.txt: a list of ArcticDEM strip file names used for change estimation.
26_44_2_1_rate.tif: elevation change rate in m/yr;
26_44_2_1_ratestd.tif: elevation change rate uncertainty in meter per year;
26_44_2_1_eventtimeT1.tif: date of the earliest measurement. The date format is YYYYMMDD.
26_44_2_1_eventtimeT2.tif: date of the latest measurement.
26_44_2_1_nov.tif: The number of overlapping DEMs. 

They are Geotiff files, which can be visualized in QGIS (open software). You can also read the files using Matlab code (https://github.com/ihowat/setsm_postprocessing/blob/master/readGeotiff.m).
