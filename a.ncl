aa=addfile(getenv("domain_1"), "w")
bbfile = getenv("domain_2")
if (fileexists(bbfile)) then
    bb=addfile(bbfile, "w")
end if
ccfile = getenv("domain_3")
if (fileexists(ccfile)) then
    cc=addfile(ccfile, "w")
end if
ddfile = getenv("domain_4")
if (fileexists(ddfile)) then
    dd=addfile(ddfile, "w")
end if
eefile = getenv("domain_5")
if (fileexists(eefile)) then
    ee=addfile(eefile, "w")
end if

number_of_domains = getenv("number_of_domains")

cc_lat = cc->XLAT
cc_lon = cc->XLONG
bb_lat = bb->XLAT
bb_lon = bb->XLONG
aa_lat = aa->XLAT
aa_lon = aa->XLONG

myvar = getenv("wrf_variable")
cc_var = cc->$myvar$
cc_var = tofloat(getenv("new_value"))
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
print("End of NCL code")