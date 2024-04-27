; Code to tailor WRF outputs by the whole smallest domain
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list
print("================ Modify by the whole smallest domain ================")
print("---------------------------------------------------------------------")

number_of_domains = tointeger(getenv("number_of_domains"))
wrfvariable = getenv("wrf_variable")
filename_arr = str_split(getfilepath(file_list[0]), "/")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found in " + filename_arr(dimsizes(filename_arr)-1))
    print("Exiting ..")
    exit()
end if
variable_level = tointeger(getenv("variable_level"))
NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)
varlist = NewList("lifo")
ii=0
do while(ii.lt.totvars) ;code aaff
    ListAppend(varlist, wrf_user_getvar(file_list[number_of_domains-1], NCLvarnames(ii), -1))
    ii = ii+1
end do
lines = tointeger(getenv("substitutenumber"))
sublevels = new(lines,"integer")
i=0
do while(i.le.(lines-1))
    sublevels(i) = tointeger(getenv("sublevels"+i)) - 1
    i=i+1
end do

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

;;;shell script
          E_NO := varlist[2]  ;;;added_new_line_by_sed 
          vardim := dimsizes(E_NO) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(E_NO) ;;;added_new_line_by_sed 
            if ((sublevels(2) .gt. (vardim(1)-1)) .or. (sublevels(2) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(2)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(2) + \ ;;;added_new_line_by_sed 
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
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(1) + \ ;;;added_new_line_by_sed 
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
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + E_NH3@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            E_NH3 := E_NH3(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed

;;;equation from namelist.wrf
polynomial := 11  ;;;added_new_line_by_sed

polynomial_init := polynomial
allvars := getfilevarnames(file_list[number_of_domains-1])
all_latnames := str_match(allvars, "XLAT")
all_longnames := str_match(allvars, "XLONG")
lat_small := file_list[number_of_domains-1]->$all_latnames(0)$
long_small := file_list[number_of_domains-1]->$all_longnames(0)$
latdim = dimsizes(dimsizes(lat_small))
; if (latdim .gt. 2) then
;   lat_small := lat_small(0, :, :)
;   long_small := long_small(0, :, :)
; end if
; printVarSummary(polynomial)
; exit()
; lat_small = file_list[number_of_domains-1]->XLAT
; long_small = file_list[number_of_domains-1]->XLONG
coorddim = dimsizes(dimsizes(polynomial))
; if (coorddim .gt. 2) then
;   polynomial := polynomial(0, :, :)
; end if
filefromlist := file_list[number_of_domains-1]
wrfvar_original := filefromlist->$wrfvariable$
if (var_is_4d .eq. True) then
  copy_VarCoords(wrfvar_original(:, variable_level, :, :), polynomial)
  copy_VarAtts(wrfvar_original(:, variable_level, :, :), polynomial)
  ; printMinMax(wrfvar_original(:, variable_level, :, :), 0)
  ; printMinMax(polynomial, 0)
; exit()
  wrfvar_original(:, variable_level, :, :) = polynomial
  tailored_file = file_list[number_of_domains-1]
  tailored_file->$wrfvariable$ = wrfvar_original
  ; filefromlist->$wrfvariable$ = wrfvar_original
  delete(tailored_file)
  else
  wrfvar_original = polynomial
  filefromlist->$wrfvariable$ = wrfvar_original
  delete(filefromlist)
end if
exit()

polynomial = conform(wrfvar_original, polynomial, (/coorddim-2, coorddim-1/))
exit()
copy_VarAtts(wrfvar_original, polynomial)
copy_VarCoords(file_list[number_of_domains-1]->$wrfvariable$, polynomial)
filefromlist := file_list[number_of_domains-1]
filefromlist->$wrfvariable$ = polynomial
file_list[number_of_domains-1] = filefromlist

exit()

dims = dimsizes(lat_small)
dimdims = dimsizes(dims)
lats_unstr = fspan(min(lat_small), max(lat_small), dims(dimdims-1))
lons_unstr = fspan(min(long_small), max(long_small), dims(dimdims-2))
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
          E_NO := varlist[2]  ;;;added_new_line_by_sed 
          vardim := dimsizes(E_NO) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(E_NO) ;;;added_new_line_by_sed 
            if ((sublevels(2) .gt. (vardim(1)-1)) .or. (sublevels(2) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(2)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(2) + \ ;;;added_new_line_by_sed 
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
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(1) + \ ;;;added_new_line_by_sed 
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
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + E_NH3@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            E_NH3 := E_NH3(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
    ;;;equation from namelist.wrf
polynomial := 11  ;;;added_new_line_by_sed

    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, newlat, newlong, 1)
    small2next000 := where(ismissing(small2next), 1, 0)
    small2next111 := where(ismissing(small2next), 0, 1)
    filefromlist := file_list[ii]
    var_default := polynomial * small2next111
    filefromlist->$wrfvariable$ = (filefromlist->$wrfvariable$ * small2next000) + var_default
    print("Domain " + (ii+1) + " has been tailord")
end do