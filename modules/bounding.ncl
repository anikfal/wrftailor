; Code to tailor WRF-NetCDF input data by a bounding box
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list
print("================ Modify by bounding box ================")
print("--------------------------------------------------------")

number_of_domains = tointeger(getenv("number_of_domains"))
wrfvariable = getenv("wrf_variable")
filename_arr = str_split(getfilepath(file_list[0]), "/")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found in " + filename_arr(dimsizes(filename_arr)-1))
    print("Exiting ..")
    exit()
end if

variable_level = tointeger(getenv("variable_level"))
north_lat = tofloat(getenv("north_lat"))
south_lat = tofloat(getenv("south_lat"))
west_long = tofloat(getenv("west_long"))
east_long = tofloat(getenv("east_long"))
lines = tointeger(getenv("substitutenumber"))
sublevels = new(lines,"integer")
i=0
do while(i.le.(lines-1))
    sublevels(i) = tointeger(getenv("sublevels"+i)) - 1
    i=i+1
end do

NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)

thevariable = file_list[0]->$wrfvariable$
thevardim   = dimsizes(thevariable)
thevardimname = getvardims(thevariable)
var_is_4d = False
if ( dimsizes(thevardim) .eq. 4) then
  var_is_4d = True
  if ((variable_level .gt. thevardim(1)) .or. (variable_level .lt. 1)) then
  print("Warning: " + "variable_level2 for " + wrfvariable + \
  " (" + thevariable@description + ") in namelist.tailor is " + variable_level + \
  ". It should be between 1 to " + thevardim(1) + " (maximum number of " + thevardimname(1) + ").")
  print("Exiting ..")
  exit()
  end if
  variable_level = variable_level - 1
end if

subnums = dimsizes(sublevels)
if (totvars .ne. subnums) then
    print("Warning: variable_substitute_name2 has " + totvars + \
    " variables. But variable_substitute_levels2 has " + subnums + \ 
    " values. They should be equal.")
    print("Exiting ..")
    exit()
end if

jj=0
do while(jj.lt.totvars) ;code aaff
    if (.not. isfilevar(file_list[0], NCLvarnames(jj))) then
        print("Warning: " + NCLvarnames(jj) + " in variable_substitute_name2 is not available in input files.")
        print("Exiting ..")
        exit()
    end if
    jj = jj+1
end do

theVariable2 = file_list[number_of_domains-1]->$wrfvariable$
dims = dimsizes(theVariable2)
dimdims = dimsizes(dims)
lats_unstr = fspan(south_lat, north_lat, dims(dimdims-2))
lons_unstr = fspan(west_long, east_long, dims(dimdims-1))

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1

    varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do

    ;;;shell script
          E_NO := varlist[2]  ;;;added_new_line_by_sed 
          vardim := dimsizes(E_NO) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(E_NO) ;;;added_new_line_by_sed 
            if ((sublevels(2) .gt. (vardim(1)-1)) .or. (sublevels(2) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(2)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(2) + \ ;;;added_new_line_by_sed 
              " (" + E_NO@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            E_NO := E_NO(:, sublevels(2), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
          E_SO2 := varlist[1]  ;;;added_new_line_by_sed 
          vardim := dimsizes(E_SO2) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(E_SO2) ;;;added_new_line_by_sed 
            if ((sublevels(1) .gt. (vardim(1)-1)) .or. (sublevels(1) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(1)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(1) + \ ;;;added_new_line_by_sed 
              " (" + E_SO2@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            E_SO2 := E_SO2(:, sublevels(1), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
          E_NH3 := varlist[0]  ;;;added_new_line_by_sed 
          vardim := dimsizes(E_NH3) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(E_NH3) ;;;added_new_line_by_sed 
            if ((sublevels(0) .gt. (vardim(1)-1)) .or. (sublevels(0) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(0)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + E_NH3@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            E_NH3 := E_NH3(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed

    ;;;equation from namelist.wrf
polynomial := (E_NH3*1)+E_SO2/2+100+E_NO  ;;;added_new_line_by_sed
polynomial_init := polynomial
allvars := getfilevarnames(file_list[ii])
all_latnames := str_match(allvars, "XLAT")
all_longnames := str_match(allvars, "XLONG")
mylat := file_list[ii]->$all_latnames(0)$
mylong := file_list[ii]->$all_longnames(0)$
latdim = dimsizes(dimsizes(mylat))
if (latdim .gt. 2) then
  mylat := mylat(0, :, :)
  mylong := mylong(0, :, :)
end if
polynomial@lat2d := mylat ;file_list[ii]->$all_latnames(0)$
polynomial@lon2d := mylong ;file_list[ii]->$all_longnames(0)$


filefromlist := file_list[ii]
wrfvar_original := filefromlist->$wrfvariable$
wrfvar := wrfvar_original
if (var_is_4d .eq. True) then
  wrfvar := wrfvar(:, variable_level, :, :)
end if
copy_VarCoords(wrfvar, polynomial)

; copy_VarCoords(file_list[ii]->$wrfvariable$, polynomial)
grd_unsrt  = rcm2rgrid_Wrap(mylat, mylong, polynomial, lats_unstr, lons_unstr, 1)
small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, mylat, mylong, 1)

;     wrfvar := filefromlist->$wrfvariable$
;     dims = dimsizes(dimsizes(wrfvar))


    small2next_conform_inside := where(ismissing(small2next), 0, small2next)
    small2next000 := where(ismissing(small2next), 1, 0)
    wrfvar_outside := wrfvar * small2next000

    ; filefromlist->$wrfvariable$ = wrfvar_outside + small2next_conform_inside
    if (var_is_4d .eq. True) then
      wrfvar_original(:, variable_level, :, :) = wrfvar_outside + small2next_conform_inside
      filefromlist->$wrfvariable$ = wrfvar_original
      delete(filefromlist)
      else
      wrfvar_original = wrfvar_outside + small2next_conform_inside
      filefromlist->$wrfvariable$ = wrfvar_original
      delete(filefromlist)
    end if
    print("Domain " + (ii+1) + " has been tailord")
    end do