; Code to tailor WRF outputs by a bounding box
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list
print("================ Modify by list of points ================")
print("----------------------------------------------------------")
number_of_domains = tointeger(getenv("number_of_domains"))
wrfvariable = getenv("wrf_variable")
filename_arr = str_split(getfilepath(file_list[0]), "/")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found in " + filename_arr(dimsizes(filename_arr)-1))
    print("Exiting ..")
    exit()
end if

variable_level = tointeger(getenv("variable_level"))
thevariable = file_list[0]->$wrfvariable$
thevardim   = dimsizes(thevariable)
thevardimname = getvardims(thevariable)
var_is_4d = False
if ( dimsizes(thevardim) .eq. 4) then
  var_is_4d = True
  if ((variable_level .gt. thevardim(1)) .or. (variable_level .lt. 1)) then
  print("Warning: " + "variable_level5 for " + wrfvariable + \
  " (" + thevariable@description + ") in namelist.tailor is " + variable_level + \
  ". It should be between 1 to " + thevardim(1) + " (maximum number of " + thevardimname(1) + ").")
  print("Exiting ..")
  exit()
  end if
  variable_level = variable_level - 1
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
    allvars := getfilevarnames(file_list[ii])
    all_latnames := str_match(allvars, "XLAT")
    all_longnames := str_match(allvars, "XLONG")
    newlat := file_list[ii]->$all_latnames(0)$
    newlong := file_list[ii]->$all_longnames(0)$
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

    kk = 0
    if (var_is_4d .eq. True) then
        do while(kk.lt.lines)
            wrfvar(:, variable_level, nm(kk, 0), nm(kk, 1)) = (/PointList(kk)/)
            kk = kk + 1
        end do
        else
        do while(kk.lt.lines)
            wrfvar(:, nm(kk, 0), nm(kk, 1)) = (/PointList(kk)/)
            kk = kk + 1
        end do
    end if
    filefromlist->$wrfvariable$ = wrfvar
    print("Domain " + (ii+1) + " has been tailord")
end do