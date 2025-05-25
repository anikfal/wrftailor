; Code to tailor WRF outputs by a geotiff file
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list
print("============== Replacement by GeoTIFF data ===============")
print("----------------------------------------------------------")

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
tiflat = tiffile->lat
tiflong = tiffile->lon
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

pi    = 3.141593
R     = 6371.22   ; km
areaG = 4*pi*R^2  ; total surface area of the globe
areaG@units = "km^2"
tiflatsize = dimsizes(tiflat) - 1
tiflongsize = dimsizes(tiflong) - 1
allCells_tif = new((/tiflatsize, tiflongsize/), float)

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    allvars := getfilevarnames(file_list[ii])
    all_latnames := str_match(allvars, "XLAT")
    all_longnames := str_match(allvars, "XLONG")
    wrflat := file_list[ii]->$all_latnames(0)$
    wrflong := file_list[ii]->$all_longnames(0)$
    coorddim = dimsizes(dimsizes(wrflat))
    if (coorddim .gt. 2) then
        if (coorddim .eq. 3) then
            wrflat := wrflat(0, :, :)
            wrflong := wrflong(0, :, :)
            else
            wrflat := wrflat(0, 0, :, :)
            wrflong := wrflong(0, 0, :, :)
        end if
    end if
    print("Interpolating from the Geotiff file to the WRF file ...")
    tif_lat_conform := conform(tifvar, tiflat, 0)
    tif_long_conform := conform(tifvar, tiflong, 1)
    small2next := rgrid2rcm_Wrap(tiflat, tiflong, tifvar, wrflat, wrflong, 1) ;3dim in all cases
    small2nextlat := rgrid2rcm_Wrap(tiflat, tiflong, tif_lat_conform, wrflat, wrflong, 1) ;3dim in all cases
    small2nextlong := rgrid2rcm_Wrap(tiflat, tiflong, tif_long_conform, wrflat, wrflong, 1) ;3dim in all cases
    wrf2tiflat_withmissing := rcm2rgrid_Wrap(wrflat, wrflong, wrflat, tiflat, tiflong, 1)
    wrf2tiflong_withmissing := rcm2rgrid_Wrap(wrflat, wrflong, wrflong, tiflat, tiflong, 1)
    
    tifvar_withmissing := rcm2rgrid_Wrap(wrflat, wrflong, wrflong, tiflat, tiflong, 1)
    tifvar_withmissing := (tifvar_withmissing * 0) + tifvar
    wrf2tiflat_withmissing := (wrf2tiflat_withmissing * 0) + tif_lat_conform
    wrf2tiflong_withmissing := (wrf2tiflong_withmissing * 0) + tif_long_conform

    jj=0
    do while((jj .lt. tiflatsize))
        iitif=0
        print("------------ " + jj)
        do while((iitif .lt. tiflongsize))
            ; print(iitif)
            ; print(wrf2tiflat_withmissing(jj,iitif) + " " + wrf2tiflat_withmissing(jj,iitif+1) + " " + wrf2tiflat_withmissing(jj+1,iitif+1) + " " + wrf2tiflat_withmissing(jj+1,iitif))
            ; exit()
            ; quadH = gc_qarea( (/wrf2tiflat_withmissing(jj,iitif), wrf2tiflat_withmissing(jj,iitif+1), wrf2tiflat_withmissing(jj+1,iitif+1), wrf2tiflat_withmissing(jj+1,iitif)/), (/wrf2tiflong_withmissing(jj,iitif), wrf2tiflong_withmissing(jj,iitif+1), wrf2tiflong_withmissing(jj+1,iitif+1), wrf2tiflong_withmissing(jj+1,iitif)/) )
            quadH = gc_qarea( (/tif_lat_conform(jj,iitif), tif_lat_conform(jj,iitif+1), tif_lat_conform(jj+1,iitif+1), tif_lat_conform(jj+1,iitif)/), \
            (/tif_long_conform(jj,iitif), tif_long_conform(jj,iitif+1), tif_long_conform(jj+1,iitif+1), tif_long_conform(jj+1,iitif)/) )
            areaH = doubletofloat(quadH*R^2)
            ; print(areaH)
            ; print(tifvar_withmissing(jj,iitif))
            ; printVarSummary(allCells_tif)
            ; pcH   = (areaH/areaG)*100    ; % of hemisphere .. should be 50%
            ; print("areaH="+sprintf("%12.3f", areaH)+" km^2")
            allCells_tif(jj,iitif) = abs(areaH) * tifvar_withmissing(jj,iitif)
            iitif = iitif + 1
        end do
        ; print(allCells_tif(0,:))
        ; exit()
        jj = jj + 1
    end do

printVarSummary(allCells_tif)
print(min(allCells_tif) + " " + max(allCells_tif) + " " + avg(allCells_tif) + " " + sum(allCells_tif))


    exit()


    ; tiflatmin := min(small2nextlat)
    ; tiflatmax := max(small2nextlat)
    ; tiflongmin := min(small2nextlong)
    ; tiflongmax := max(small2nextlong)
    ; tiflatmin_diff := abs(tiflat - tiflatmin)
    ; tiflatmax_diff := abs(tiflat - tiflatmax)
    ; tiflatmin_ind := minind(tiflatmin_diff)
    ; tiflatmax_ind := minind(tiflatmax_diff)
    ; printVarSummary(tifvar)
    ; print(small2nextlong)
    ; print(tiflatmin + " " + tiflatmax)
    ; print(ind(tiflat .eq. tiflatmin))
    ; print(ind(tiflat .eq. tiflatmax))
    ; print(tiflatmin_ind)
    ; print(tiflatmax_ind)
    ; print(wrf2tiflong(:20, :))
    printVarSummary(wrf2tiflong)
    exit()
    small2next_mask = .not.ismissing(small2next)
    printVarSummary(small2next_mask)
    ; iivalid = ind(small2next_mask)
    ; print(ndtooned(small2next_mask))
    exit()


    filefromlist := file_list[ii]
    wrfvar := filefromlist->$wrfvariable$
    if (var_is_4d .eq. True) then
        small2next_conform := conform(wrfvar(:, variable_level, :, :), small2next, (/1,2/))
        copy_VarAtts(wrfvar(:, variable_level, :, :), small2next_conform)
        copy_VarCoords(wrfvar(:, variable_level, :, :), small2next_conform)
        small2next_conform_inside := where(ismissing(small2next_conform), 0, small2next_conform)
        small2next000 := where(ismissing(small2next_conform), 1, 0)
        wrfvar_outside := wrfvar(:, variable_level, :, :) * small2next000
        filefromlist->$wrfvariable$(:, variable_level, :, :) = wrfvar_outside + small2next_conform_inside
        delete(filefromlist)
        else
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