file_list = NewList("lifo")

dom111file=getenv("domain_1")
if (fileexists(dom111file)) then
    dom111=addfile(dom111file, "w")
else
    print("Error!")
    print(dom111file + " is not a valid file for domain 1")
    exit()
end if
ListAppend(file_list, dom111)
dom222file = getenv("domain_2")
if (fileexists(dom222file)) then
    dom222=addfile(dom222file, "w")
else
    dom222 = "no_file"
end if
ListAppend(file_list, dom222)
dom333file = getenv("domain_3")
if (fileexists(dom333file)) then
    dom333=addfile(dom333file, "w")
else
    dom333 = "no_file"
end if
ListAppend(file_list, dom333)
dom444file = getenv("domain_4")
if (fileexists(dom444file)) then
    dom444=addfile(dom444file, "w")
else
    dom444 = "no_file"
end if
ListAppend(file_list, dom444)
dom555file = getenv("domain_5")
if (fileexists(dom555file)) then
    dom555=addfile(dom555file, "w")
else
    dom555 = "no_file"
end if
ListAppend(file_list, dom555)

NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)
varlist = NewList("lifo")

ii=0
do while(ii.lt.totvars) ;code aaff
    ListAppend(varlist, wrf_user_getvar(dom333, NCLvarnames(ii), -1))
    ii = ii+1
end do

number_of_domains = getenv("number_of_domains")

dom333lat = dom333->XLAT
dom333long = dom333->XLONG
wrfvariable = getenv("wrf_variable")
cc_var = dom333->$wrfvariable$

;;;shell script
E_SO2 = varlist[1]  ;;;added_new_line_by_sed
E_NH3 = varlist[0]  ;;;added_new_line_by_sed

;;;equation from namelist.wrf
tc2 = (E_NH3*3)+E_SO2/2  ;;;added_new_line_by_sed

copy_VarAtts(cc_var, tc2)
copy_VarCoords(cc_var, tc2)
printVarSummary(tc2)
dom333->$wrfvariable$ = tc2




exit()




dom222lat = dom222->XLAT
dom222long = dom222->XLONG
dom111lat = dom111->XLAT
dom111lon = dom111->XLONG

bb_var = dom222->$wrfvariable$
aa_var = dom111->$wrfvariable$

dims = dimsizes(dom333lat)
cc_lat_unstr = fspan(min(dom333lat),max(dom333lat),dims(1))
cc_lon_unstr = fspan(min(dom333long),max(dom333long),dims(0))
grd_unsrt  = rcm2rgrid_Wrap(dom333lat, dom333long, cc_var, cc_lat_unstr, cc_lon_unstr, 1)

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
delete(dom333)
print("End of NCL code")