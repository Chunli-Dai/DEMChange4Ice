#!/bin/sh

echo running compile.sh
echo Start compiling files
rm -f run_Tilemain.sh mccExcludedFiles.log Tilemain

module unload matlab
#module load matlab/2022b # projcrs, only works for matlab Since R2020b

#which mcc

#mcc -m CoastTileMonoMain.m -a ~/codec2/ -a constant.m 
#/home4/cdai/workpfe/software/matlab2020bbin/bin/mcc -m CoastTileMonoMain.m -a ~/codec2/ -a constant.m

# Error:Cannot find CTF archive : /nobackupp27/cdai/greenland/pfework/Tilemain.ctf
#/swbuild/cdai/software/matlab2017bbin/R2017b/bin/mcc -m Tilemain.m -a ~/workpfe/greenland/code1/ -a constant.m -C

/swbuild/cdai/software/matlab2017bbin/R2017b/bin/mcc -C -m Tilemain.m -a /nobackupp27/cdai/greenland/code1/ -a constant.m 

cp ~/template/run_Tilemain.sh .

echo Compiling files end.
