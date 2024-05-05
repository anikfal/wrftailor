; Code to tailor WRF outputs by a geotiff file
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list

wrfvariable = getenv("wrf_variable")
filename_arr = str_split(getfilepath(file_list[0]), "/")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found in " + filename_arr(dimsizes(filename_arr)-1))
    print("Exiting ..")
    exit()
end if

number_of_domains = tointeger(getenv("number_of_domains"))
tiffile := addfile(getenv("tiff2nc"), "r")  ;should be the geotiff variable
tifvar = tiffile->Band1
lats_unstr = tiffile->lat
lons_unstr = tiffile->lon
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

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    allvars := getfilevarnames(file_list[ii])
    all_latnames := str_match(allvars, "XLAT")
    all_longnames := str_match(allvars, "XLONG")
    newlat := file_list[ii]->$all_latnames(0)$
    newlong := file_list[ii]->$all_longnames(0)$
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
    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, tifvar, newlat, newlong, 1) ;3dim in all cases
    filefromlist := file_list[ii]
    if (var_is_4d .eq. True) then
        wrfvar := filefromlist->$wrfvariable$
        small2next_conform := conform(wrfvar(:, variable_level, :, :), small2next, (/1,2/))
        copy_VarAtts(wrfvar(:, variable_level, :, :), small2next_conform)
        copy_VarCoords(wrfvar(:, variable_level, :, :), small2next_conform)
        small2next_conform_inside := where(ismissing(small2next_conform), 0, small2next_conform)
        small2next000 := where(ismissing(small2next_conform), 1, 0)
        wrfvar_outside := wrfvar(:, variable_level, :, :) * small2next000
        filefromlist->$wrfvariable$(:, variable_level, :, :) = wrfvar_outside + small2next_conform_inside
        delete(filefromlist)
        else
        wrfvar := filefromlist->$wrfvariable$
        small2next_conform := conform(wrfvar, small2next, (/1,2/))
        copy_VarAtts(wrfvar, small2next_conform)
        copy_VarCoords(wrfvar, small2next_conform)
        small2next_conform_inside := where(ismissing(small2next_conform), 0, small2next_conform)
        small2next000 := where(ismissing(small2next_conform), 1, 0)
        wrfvar_outside := wrfvar * small2next000
        filefromlist->$wrfvariable$ = wrfvar_outside + small2next_conform_inside
        delete(filefromlist)
    end if
    print("Domain " + (ii+1) + " has been tailord")
end do