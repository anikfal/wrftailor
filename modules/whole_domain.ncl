file_list = NewList("lifo")
number_of_domains = tointeger(getenv("number_of_domains"))

dom111file=getenv("domain_1")
if (fileexists(dom111file)) then
ListAppend(file_list, addfile(dom111file, "w"))
else
    print("Error!")
    print(dom111file + " is not a valid file for domain 1")
    exit()
end if
dom222file = getenv("domain_2")
if (fileexists(dom222file)) then
    ListAppend(file_list, addfile(dom222file, "w"))
else
    ListAppend(file_list, "no_file")
end if
dom333file = getenv("domain_3")
if (fileexists(dom333file)) then
    ListAppend(file_list, addfile(dom333file, "w"))
else
    ListAppend(file_list, "no_file")
end if
dom444file = getenv("domain_4")
if (fileexists(dom444file)) then
    ListAppend(file_list, addfile(dom444file, "w"))
else
    dom444 = "no_file"
end if
dom555file = getenv("domain_5")
if (fileexists(dom555file)) then
    ListAppend(file_list, addfile(dom555file, "w"))
else
    ListAppend(file_list, "no_file")
end if

NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)
varlist = NewList("lifo")

ii=0
do while(ii.lt.totvars) ;code aaff
    ListAppend(varlist, wrf_user_getvar(file_list[number_of_domains-1], NCLvarnames(ii), -1))
    ii = ii+1
end do

lat_small = file_list[number_of_domains-1]->XLAT
long_small = file_list[number_of_domains-1]->XLONG
wrfvariable = getenv("wrf_variable")

;;;shell script
E_SO2 = varlist[1]  ;;;added_new_line_by_sed
E_NH3 = varlist[0]  ;;;added_new_line_by_sed

;;;equation from namelist.wrf
polynomial = (E_NH3*0)+E_SO2/2*0+5  ;;;added_new_line_by_sed


copy_VarAtts(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
copy_VarCoords(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
filefromlist = file_list[number_of_domains-1]
filefromlist->$wrfvariable$ = polynomial
file_list[number_of_domains-1] = filefromlist

; printVarSummary(file_list[number_of_domains-1]->$wrfvariable$)
; printMinMax(file_list[number_of_domains-1]->$wrfvariable$, 0)


ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    print("ii: " + ii)
end do



exit()




dom222lat = dom222->XLAT
dom222long = dom222->XLONG
dom111lat = dom111->XLAT
dom111lon = dom111->XLONG

bb_var = dom222->$wrfvariable$
aa_var = dom111->$wrfvariable$

dims = dimsizes(lat_small)
cc_lat_unstr = fspan(min(lat_small),max(lat_small),dims(1))
cc_lon_unstr = fspan(min(long_small),max(long_small),dims(0))
grd_unsrt  = rcm2rgrid_Wrap(lat_small, long_small, file_list[number_of_domains-1]->$wrfvariable$, cc_lat_unstr, cc_lon_unstr, 1)

grid_2d_new000 = rgrid2rcm_Wrap(cc_lat_unstr, cc_lon_unstr, grd_unsrt, dom222lat, dom222long, 1)
grid_2d_new = where(ismissing(grid_2d_new000), 1, grid_2d_new000)
newvar = grid_2d_new*bb_var

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