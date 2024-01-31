cc=addfile("wrfchemi_d03_2021-01-22_00:00:00", "w")
bb=addfile("wrfchemi_d02_2021-01-22_00:00:00", "w")
aa=addfile("wrfchemi_d01_2021-01-22_00:00:00", "w")
cc_lat = cc->XLAT
cc_lon = cc->XLONG
bb_lat = bb->XLAT
bb_lon = bb->XLONG
aa_lat = aa->XLAT
aa_lon = aa->XLONG

myvar = "E_NH3"
cc_var = cc->$myvar$
cc_var = 0
cc->$myvar$ = cc_var
bb_var = bb->$myvar$
aa_var = aa->$myvar$

dims = dimsizes(cc_lat)
cc_lat_unstr = fspan(min(cc_lat),max(cc_lat),dims(1))
cc_lon_unstr = fspan(min(cc_lon),max(cc_lon),dims(0))
grd_unsrt  = rcm2rgrid_Wrap(cc_lat, cc_lon, cc_var, cc_lat_unstr, cc_lon_unstr, 1)

grid_2d_new000 = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, bb_lat, bb_lon, 1)
grid_2d_new = where(ismissing(grid_2d_new000), 1, grid_2d_new000)
newvar = grid_2d_new*bb_var

Agrid_2d_new000 = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, aa_lat, aa_lon, 1)
Agrid_2d_new = where(ismissing(Agrid_2d_new000), 1, Agrid_2d_new000)
Anewvar = Agrid_2d_new*aa_var

copy_VarCoords(bb_var, newvar)
copy_VarAtts(bb_var, newvar)
bb->$myvar$ = newvar
copy_VarCoords(aa_var, Anewvar)
copy_VarAtts(aa_var, Anewvar)
aa->$myvar$ = Anewvar
delete(bb)
delete(aa)
delete(cc)