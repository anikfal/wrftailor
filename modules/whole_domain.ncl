load "files2list.ncl" ;put domain_1, domain_2, ... into file_list

number_of_domains = tointeger(getenv("number_of_domains"))
NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)
varlist = NewList("lifo")

ii=0
do while(ii.lt.totvars) ;code aaff
    ListAppend(varlist, wrf_user_getvar(file_list[number_of_domains-1], NCLvarnames(ii), -1))
    ii = ii+1
end do

;;;shell script
E_SO2 := varlist[1]  ;;;added_new_line_by_sed
E_NH3 := varlist[0]  ;;;added_new_line_by_sed

;;;equation from namelist.wrf
polynomial := (E_NH3*0)+E_SO2/2*0+7  ;;;added_new_line_by_sed

lat_small = file_list[number_of_domains-1]->XLAT
long_small = file_list[number_of_domains-1]->XLONG
wrfvariable = getenv("wrf_variable")

copy_VarAtts(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
copy_VarCoords(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
filefromlist := file_list[number_of_domains-1]
filefromlist->$wrfvariable$ = polynomial
file_list[number_of_domains-1] = filefromlist

exit()

dims = dimsizes(lat_small)
lats_unstr = fspan(min(lat_small), max(lat_small), dims(1))
lons_unstr = fspan(min(long_small), max(long_small), dims(0))
grd_unsrt  = rcm2rgrid_Wrap(lat_small, long_small, file_list[number_of_domains-1]->$wrfvariable$, lats_unstr, lons_unstr, 1)
ii = number_of_domains - 1
do while(ii .gt. 0)
    ii = ii - 1
    newlat := file_list[ii]->XLAT
    newlong := file_list[ii]->XLONG
    ; newvar := file_list[ii]->$wrfvariable$
    varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
    print("Inside ii jj")
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do
    ;;;shell script
E_SO2 := varlist[1]  ;;;added_new_line_by_sed
E_NH3 := varlist[0]  ;;;added_new_line_by_sed
    ;;;equation from namelist.wrf
polynomial := (E_NH3*0)+E_SO2/2*0+7  ;;;added_new_line_by_sed
printVarSummary(polynomial)
exit()
    small2next = rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, newlat, newlong, 1)
    small2next = 0
    small2next111 = where(ismissing(small2next), 1, small2next)
    small2next = 1
    small2next000 = where(ismissing(small2next), 0, small2next)
    delete(small2next)

    filefromlist := file_list[ii]
    var_default = filefromlist->$wrfvariable$ * small2next000
    filefromlist->$wrfvariable$ := (polynomial * small2next111) + var_default

    file_list[ii] = filefromlist

    ; newvar = grid_2d_new*bb_var
    ; printVarSummary(newvar)
    print("ii: " + ii)
end do


exit()

dom222lat = dom222->XLAT
dom222long = dom222->XLONG
bb_var = dom222->$wrfvariable$

dims = dimsizes(lat_small)
cc_lat_unstr = fspan(min(lat_small), max(lat_small), dims(1))
cc_lon_unstr = fspan(min(long_small), max(long_small), dims(0))
grd_unsrt  = rcm2rgrid_Wrap(lat_small, long_small, file_list[number_of_domains-1]->$wrfvariable$, cc_lat_unstr, cc_lon_unstr, 1)

grid_2d_new000 = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, dom222lat, dom222long, 1)
grid_2d_new = where(ismissing(grid_2d_new000), 1, grid_2d_new000)
newvar = grid_2d_new*bb_var









aa_var = dom111->$wrfvariable$
dom111lat = dom111->XLAT
dom111lon = dom111->XLONG

Agrid_2d_new000 = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, dom111lat, dom111lon, 1)
Agrid_2d_new = where(ismissing(Agrid_2d_new000), 1, Agrid_2d_new000)
Anewvar = Agrid_2d_new*aa_var

copy_VarCoords(bb_var, newvar)
copy_VarAtts(bb_var, newvar)
dom222->$wrfvariable$ = newvar
copy_VarCoords(aa_var, Anewvar)
copy_VarAtts(aa_var, Anewvar)
dom111->$wrfvariable$ = Anewvar
delete(dom222)
delete(dom111)
delete(file_list[number_of_domains-1])
print("End of NCL code")