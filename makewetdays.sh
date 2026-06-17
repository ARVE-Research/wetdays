#!/usr/bin/env bash

module load CDO netCDF-Fortran

srcdir=/home/terraces/datasets/CMIP6/historical/climatology

if [ ! -e $srcdir/wetf ]
then
  mkdir -p $srcdir/wetf
fi

for infile in `ls $srcdir/pr/pr*.nc`   # file containing precipitation is the input file
do

  output=$srcdir/wetf/wetf${infile##*pr}
  
  echo $infile
  echo $output

  # create output file with the same dimensions as input
  
  ncdump -cs $infile | ncgen -4 -o tmp.nc
  
  cdo -f nc4 setpartabn,wetfrac.namelist tmp.nc $output
  
  rm tmp.nc
  
  # remap stats file to size of input
  
  cdo -f nc4 -P 40 remapmean,$infile wetVpre-linear-annual_filled.nc stats.nc
  
  # convert input precip to mm day-1
  
  cdo -f nc4 mulc,86400 $infile input.nc
  
  # calculate wet day fraction
  
  ./calcwetf input.nc stats.nc $output

  # clean up

  rm input.nc stats.nc

done
