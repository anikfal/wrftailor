; Code to tailor WRF outputs by a bounding box
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list

number_of_domains = tointeger(getenv("number_of_domains"))
wrfvariable = getenv("wrf_variable")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found")
    print("Exiting ..")
    exit()
end if

lines = tointeger(getenv("ncllats"))
LatList = new(lines,"string")
LongList = new(lines,"string")
i=0
do while(i.le.(lines-1))
LatList(i) = getenv("nclloclats"+i)
LongList(i) = getenv("nclloclons"+i)
i=i+1
end do
delete(lines)

exit()



theVariable = file_list[number_of_domains-1]->$wrfvariable$
dims = dimsizes(theVariable)
dimdims = dimsizes(dims)
lats_unstr = fspan(south_lat, north_lat, dims(dimdims-2))
lons_unstr = fspan(west_long, east_long, dims(dimdims-1))

NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    newlat := file_list[ii]->XLAT
    newlong := file_list[ii]->XLONG
    coorddim = dimsizes(dimsizes(newlat))
    if (coorddim .gt. 2) then
        if (coorddim .eq. 3) then
            newlat := newlat(0, :, :)
            newlong := newlong(0, :, :)
            else
            newlat := newlat(0, 0, :, :)
            newlong := newlong(0, 0, :, :)
        end if
    end if
    print("Interpolating from the Geotiff file to the WRF file ...")
        varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do

    ;;;shell script
E_NO := varlist[1]  ;;;added_new_line_by_sed
E_NH3 := varlist[0]  ;;;added_new_line_by_sed

    ;;;equation from namelist.wrf
polynomial := (E_NH3*1)+E_NO/2+100  ;;;added_new_line_by_sed
    copy_VarCoords(file_list[ii]->$wrfvariable$, polynomial)

    grd_unsrt  := rcm2rgrid_Wrap(newlat, newlong, polynomial, lats_unstr, lons_unstr, 1)
    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, newlat, newlong, 1)

    filefromlist := file_list[ii]

    wrfvar := filefromlist->$wrfvariable$
    dims = dimsizes(dimsizes(wrfvar))

    small2next_conform_inside := where(ismissing(small2next), 0, small2next)
    small2next000 := where(ismissing(small2next), 1, 0)
    wrfvar_outside := wrfvar * small2next000
    filefromlist->$wrfvariable$ = wrfvar_outside + small2next_conform_inside
    print("Domain " + (ii+1) + " has been tailord")
end do