#!/usr/bin/bash

# module load CDO

historical=/home/terraces/datasets/CMIP5/historical/Amon

paleo=/home/terraces/datasets/CMIP5/midHolocene/Amon

# ----
# paleo - using 6ka

# for infile in `ls $paleo/pr/*.nc`
# do
# 
#   output=${infile##*/}
# 
#   echo $output
#     
#   # convert to mm mon-1 and interpolate to 30min 
#   
#   cdo -s -P 32 -f nc4 -z zip_1 -remapbic,global_0.5 -mulc,86400 -ymonmean $infile paleo/precip/$output
#   
#   # estimate wetdays
#   
#   ncgen -4 -o paleo/wetf/$output wetf.cdl
#   
#   ./calcwetf paleo/precip/$output paleo/wetf/$output
# 
# done
# 
# # ----
# # historical - use 1971-2000
# 
# for infile in `ls $historical/pr/*.nc`
# do
# 
#   output=${infile##*/}
# 
#   echo $output
#     
#   # convert to mm mon-1 and interpolate to 30min 
#   
#   cdo -s -P 32 -f nc4 -z zip_1 -remapbic,global_0.5 -mulc,86400 -ymonmean -seldate,1971-01-01,2000-12-31 $infile historical/precip/$output
#   
#   # estimate wetdays
#   
#   ncgen -4 -o  historical/wetf/$output wetf.cdl
#   
#   ./calcwetf historical/precip/$output historical/wetf/$output
# 
# done

hist=historical/wetf
paleo=paleo/wetf

for model in CNRM-CM5 GISS-E2-R HadGEM2-ES IPSL-CM5A-L MIROC-ESM MPI-ESM-P MRI-CGCM3
do

  cdo sub $paleo/pr_Amon_$model*.nc $hist/pr_Amon_$model*.nc anomalies/$model"_"wetf_anom.nc

done