; Code to tailor WRF outputs by a geotiff file
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list

number_of_domains = tointeger(getenv("number_of_domains"))
tiffile := addfile(getenv("tiff2nc"), "r")  ;should be the geotiff variable
tifvar = tiffile->Band1
lats_unstr = tiffile->lat
lons_unstr = tiffile->lon
wrfvariable = getenv("wrf_variable")

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
    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, tifvar, newlat, newlong, 1)
    filefromlist := file_list[ii]
    wrfvar := filefromlist->$wrfvariable$
    dims = dimsizes(dimsizes(wrfvar))
    small2next_conform := conform(wrfvar, small2next, (/dims-2,dims-1/))
    copy_VarAtts(wrfvar, small2next_conform)
    copy_VarCoords(wrfvar, small2next_conform)
    small2next_conform_inside := where(ismissing(small2next_conform), 0, small2next_conform)
    small2next000 := where(ismissing(small2next_conform), 1, 0)
    wrfvar_outside := wrfvar * small2next000
    filefromlist->$wrfvariable$ = wrfvar_outside + small2next_conform_inside
    print("Domain " + (ii+1) + " has been tailord")
end do