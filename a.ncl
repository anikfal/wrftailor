cc=addfile("wrfchemi_d03_2021-01-22_00:00:00", "r")
bb=addfile("wrfchemi_d02_2021-01-22_00:00:00", "r")
aa=addfile("wrfchemi_d01_2021-01-22_00:00:00", "r")
cc_lat = cc->XLAT
cc_lon = cc->XLONG
bb_lat = bb->XLAT
bb_lon = bb->XLONG
aa_lat = aa->XLAT
aa_lon = aa->XLONG

bb_var = bb->E_NH3
bb_var = 0

dims = dimsizes(cc_lat)
lat_unstr = fspan(min(cc_lat),max(cc_lat),dims(1))
lon_unstr = fspan(min(cc_lon),max(cc_lon),dims(0))
xgrd  = rcm2rgrid(bb_lat, bb_lon, bb_var, lat_unstr, lon_unstr, 1)
print(xgrd)

;print(cc_lat)

;grid = triple2grid2d(xlon,ylat,zVal, lon,lat, False)




;https://www.ncl.ucar.edu/Document/Functions/Built-in/triple2grid2d.shtml