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
LatList = new(lines,"float")
LongList = new(lines,"float")
PointList = new(lines,"float")
i=0
do while(i.le.(lines-1))
    LatList(i) = tofloat(getenv("nclloclats"+i))
    LongList(i) = tofloat(getenv("nclloclons"+i))
    PointList(i) = tofloat(getenv("ncllocpoints"+i))
    i=i+1
end do

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    newlat := file_list[ii]->XLAT
    newlong := file_list[ii]->XLONG
    coorddim := dimsizes(dimsizes(newlat))
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
    nm = getind_latlon2d(newlat, newlong, LatList, LongList)
    filefromlist := file_list[ii]
    wrfvar := filefromlist->$wrfvariable$
    coorddim := dimsizes(dimsizes(wrfvar))
    kk = 0
    do while(kk.lt.lines)
        if (coorddim .eq. 2) then
            wrfvar(nm(kk, 0), nm(kk, 1)) = (/PointList(kk)/)
            else if (coorddim .eq. 3) then
                wrfvar(:, nm(kk, 0), nm(kk, 1)) = (/PointList(kk)/)
            else
                wrfvar(:, :, nm(kk, 0), nm(kk, 1)) = (/PointList(kk)/)
            end if
        end if
    kk = kk + 1
    end do
    filefromlist->$wrfvariable$ = wrfvar
    print("Domain " + (ii+1) + " has been tailord")
end do