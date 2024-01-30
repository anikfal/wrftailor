cc=addfile("wrfchemi_d03_2021-01-22_00:00:00", "r")
bb=addfile("wrfchemi_d02_2021-01-22_00:00:00", "r")
aa=addfile("wrfchemi_d01_2021-01-22_00:00:00", "r")
cc_lat = cc->XLAT
cc_lon = cc->XLONG
bb_lat = bb->XLAT
bb_lon = bb->XLONG
aa_lat = aa->XLAT
aa_lon = aa->XLONG

cc_var = cc->E_NH3
cc_var = 1
bb_var = bb->E_NH3

dims = dimsizes(cc_lat)
cc_lat_unstr = fspan(min(cc_lat),max(cc_lat),dims(1))
cc_lon_unstr = fspan(min(cc_lon),max(cc_lon),dims(0))
grd_unsrt  = rcm2rgrid_Wrap(cc_lat, cc_lon, cc_var, cc_lat_unstr, cc_lon_unstr, 1)

grid_2d_new = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, bb_lat, bb_lon, 1)
newvar = grid_2d_new*bb_var

fout = addfile("temp.nc","c")
fout->myvar = newvar
delete(fout)


;https://www.ncl.ucar.edu/Document/Functions/Built-in/triple2grid2d.shtml