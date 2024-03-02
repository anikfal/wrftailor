; Code to tailor WRF outputs by the whole smallest domain
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

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
polynomial := (E_NH3*3)+E_SO2/2  ;;;added_new_line_by_sed

lat_small = file_list[number_of_domains-1]->XLAT
long_small = file_list[number_of_domains-1]->XLONG
wrfvariable = getenv("wrf_variable")

copy_VarAtts(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
copy_VarCoords(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
filefromlist := file_list[number_of_domains-1]
filefromlist->$wrfvariable$ = polynomial
file_list[number_of_domains-1] = filefromlist

dims = dimsizes(lat_small)
lats_unstr = fspan(min(lat_small), max(lat_small), dims(1))
lons_unstr = fspan(min(long_small), max(long_small), dims(0))
grd_unsrt  = rcm2rgrid_Wrap(lat_small, long_small, file_list[number_of_domains-1]->$wrfvariable$, lats_unstr, lons_unstr, 1)
print("Smallest domain has been tailored")

ii = number_of_domains - 1
do while(ii .gt. 0)
    ii = ii - 1
    newlat := file_list[ii]->XLAT
    newlong := file_list[ii]->XLONG
    ; newvar := file_list[ii]->$wrfvariable$
    varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do
    ;;;shell script
E_SO2 := varlist[1]  ;;;added_new_line_by_sed
E_NH3 := varlist[0]  ;;;added_new_line_by_sed
    ;;;equation from namelist.wrf
polynomial := (E_NH3*3)+E_SO2/2  ;;;added_new_line_by_sed

    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, newlat, newlong, 1)
    small2next000 := where(ismissing(small2next), 1, 0)
    small2next111 := where(ismissing(small2next), 0, 1)
    filefromlist := file_list[ii]
    var_default := polynomial * small2next111
    filefromlist->$wrfvariable$ = (filefromlist->$wrfvariable$ * small2next000) + var_default
    print("Domain " + (ii+1) + " has been tailord")
end do