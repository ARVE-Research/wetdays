program calcwetf

! gfortran -o calcwetf calcwetf.f90 -I/home/public/easybuild/software/netCDF-Fortran/4.6.1-gompi-2023a/include -lnetcdff

use iso_fortran_env
use netcdf

implicit none

integer, parameter :: i2 = int16
integer, parameter :: i4 = int32
integer, parameter :: i8 = int64
integer, parameter :: sp = real32
integer, parameter :: dp = real64

character(200) :: precfile
character(200) :: wetffile
character(200) :: statsfile

integer :: status
integer :: ncid
integer :: dimid
integer :: varid
integer :: xlen
integer :: ylen
integer :: tlen

integer :: m

real(dp), allocatable, dimension(:)     :: lon
real(dp), allocatable, dimension(:)     :: lat
real(sp), allocatable, dimension(:,:)   :: slope
real(sp), allocatable, dimension(:,:)   :: intercept
real(sp), allocatable, dimension(:,:,:) :: prec
real(sp), allocatable, dimension(:,:,:) :: wetf

real(sp), dimension(2) :: actual_range

! -------------------------------------------------------

statsfile='/home/terraces/datasets/climate/CHELSA/wetVpre-linear-annual_filled.nc'

status = nf90_open(statsfile,nf90_nowrite,ncid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_dimid(ncid,'lon',dimid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inquire_dimension(ncid,dimid,len=xlen)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_dimid(ncid,'lat',dimid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inquire_dimension(ncid,dimid,len=ylen)
if (status /= nf90_noerr) call handle_err(status)

allocate(slope(xlen,ylen))
allocate(intercept(xlen,ylen))

status = nf90_inq_varid(ncid,'slope',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_get_var(ncid,varid,slope)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_varid(ncid,'intercept',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_get_var(ncid,varid,intercept)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_close(ncid)
if (status /= nf90_noerr) call handle_err(status)

! ----
! NB the coefficients expect input in the form of monthly mean of daily precipitation rate

call getarg(1,precfile)

status = nf90_open(precfile,nf90_nowrite,ncid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_dimid(ncid,'time',dimid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inquire_dimension(ncid,dimid,len=tlen)
if (status /= nf90_noerr) call handle_err(status)

allocate(prec(xlen,ylen,tlen))
allocate(wetf(xlen,ylen,tlen))

status = nf90_inq_varid(ncid,'pr',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_get_var(ncid,varid,prec)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_close(ncid)
if (status /= nf90_noerr) call handle_err(status)

! ----

wetf = 0.

do m = 1,tlen
  where (prec(:,:,m) > 0.) wetf(:,:,m) = slope * log(prec(:,:,m)) + intercept
end do

wetf = min(wetf,1.)
wetf = max(wetf,0.)

! ----

call getarg(2,wetffile)

status = nf90_open(wetffile,nf90_write,ncid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_varid(ncid,'prec',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_put_var(ncid,varid,prec)
if (status /= nf90_noerr) call handle_err(status)

actual_range = [minval(prec),maxval(prec)]

status = nf90_put_att(ncid,varid,'actual_range',actual_range)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_inq_varid(ncid,'wetf',varid)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_put_var(ncid,varid,wetf)
if (status /= nf90_noerr) call handle_err(status)

actual_range = [minval(prec),maxval(prec)]

status = nf90_put_att(ncid,varid,'actual_range',actual_range)
if (status /= nf90_noerr) call handle_err(status)

status = nf90_close(ncid)
if (status /= nf90_noerr) call handle_err(status)

! ---------------------

contains

subroutine handle_err(status)

implicit none

! Internal subroutine - checks error status after each netcdf call,
! prints out text message each time an error code is returned. 

integer, intent (in) :: status

if(status /= nf90_noerr) then 
  write(0,*)'NetCDF error: ',trim(nf90_strerror(status))
  stop
end if

end subroutine handle_err

! ---------------------

end program calcwetf