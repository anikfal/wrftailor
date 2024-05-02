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
  print("Warning: " + "substitute_var_levels4 for " + wrfvariable + \
  " (" + thevariable@description + ") in namelist.tailor is " + variable_level + \
  ". It should be between 1 to " + thevardim(1) + " (maximum number of " + thevardimname(1) + ").")
  print("Exiting ..")
  exit()
  end if
  variable_level = variable_level - 1
end if

subnums = dimsizes(sublevels)
if (totvars .ne. subnums) then
    print("Warning: substitute_variable4 has " + totvars + \
    " variables. But substitute_var_levels4 has " + subnums + \ 
    " values. They should be equal.")
    print("Exiting ..")
    exit()
end if

jj=0
do while(jj.lt.totvars) ;code aaff
    if (.not. isfilevar(file_list[0], NCLvarnames(jj))) then
        print("Warning: " + NCLvarnames(jj) + " in substitute_variable4 is not available in input files.")
        print("Exiting ..")
        exit()
    end if
    jj = jj+1
end do

;;;shell script
          LANDUSEF := varlist[0]  ;;;added_new_line_by_sed 
          vardim := dimsizes(LANDUSEF) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(LANDUSEF) ;;;added_new_line_by_sed 
            if ((sublevels(0) .gt. (vardim(1)-1)) .or. (sublevels(0) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(0)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + LANDUSEF@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            LANDUSEF := LANDUSEF(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed

;;;equation from namelist.wrf
polynomial := LANDUSEF*0+33  ;;;added_new_line_by_sed

polynomial_init := polynomial
allvars := getfilevarnames(file_list[number_of_domains-1])
all_latnames := str_match(allvars, "XLAT")
all_longnames := str_match(allvars, "XLONG")
lat_small := file_list[number_of_domains-1]->$all_latnames(0)$
long_small := file_list[number_of_domains-1]->$all_longnames(0)$
filefromlist := file_list[number_of_domains-1]
var_original := filefromlist->$wrfvariable$
if (var_is_4d .eq. True) then
  copy_VarCoords(var_original(:, variable_level, :, :), polynomial)
  copy_VarAtts(var_original(:, variable_level, :, :), polynomial)
  var_original(:, variable_level, :, :) = polynomial
  tailored_file = file_list[number_of_domains-1]
  tailored_file->$wrfvariable$ = var_original
  delete(tailored_file)
  else
  copy_VarCoords(var_original, polynomial)
  copy_VarAtts(var_original, polynomial)
  var_original = polynomial
  filefromlist->$wrfvariable$ = var_original
  delete(filefromlist)
end if
print("Smallest domain has been tailored")
;;;==============================================================
;;;==============================================================

dims = dimsizes(lat_small)
dimdims = dimsizes(dims)
lats_unstr = fspan(min(lat_small), max(lat_small), dims(dimdims-1))
lons_unstr = fspan(min(long_small), max(long_small), dims(dimdims-2))
if (dimdims .gt. 2) then
  lat_small := lat_small(0, :, :)
  long_small := long_small(0, :, :)
end if
grd_unsrt  = rcm2rgrid_Wrap(lat_small, long_small, file_list[number_of_domains-1]->$wrfvariable$, lats_unstr, lons_unstr, 1)

ii = number_of_domains - 1
do while(ii .gt. 0)
    ii = ii - 1

    allvars := getfilevarnames(file_list[number_of_domains-1])
    all_latnames := str_match(allvars, "XLAT")
    all_longnames := str_match(allvars, "XLONG")
    newlat := file_list[ii]->$all_latnames(0)$
    newlong := file_list[ii]->$all_longnames(0)$
    if (dimdims .gt. 2) then
      newlat := newlat(0, :, :)
      newlong := newlong(0, :, :)
    end if
    varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do
    ;;;shell script
          LANDUSEF := varlist[0]  ;;;added_new_line_by_sed 
          vardim := dimsizes(LANDUSEF) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(LANDUSEF) ;;;added_new_line_by_sed 
            if ((sublevels(0) .gt. (vardim(1)-1)) .or. (sublevels(0) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(0)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "substitute_var_levels2 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + LANDUSEF@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            LANDUSEF := LANDUSEF(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
    ;;;equation from namelist.wrf
polynomial := LANDUSEF*0+33  ;;;added_new_line_by_sed

    small2next := rgrid2rcm_Wrap(lats_unstr, lons_unstr, grd_unsrt, newlat, newlong, 1)
    filefromlist := file_list[ii]
    var_original := filefromlist->$wrfvariable$
    if (var_is_4d .eq. True) then
      small2next := small2next(:,variable_level,:,:)
      small2next000 := where(ismissing(small2next), 1, 0)
      small2next111 := where(ismissing(small2next), 0, 1)
      var_central := polynomial * small2next111
      copy_VarCoords(var_original(:, variable_level, :, :), polynomial)
      copy_VarAtts(var_original(:, variable_level, :, :), polynomial)
      tailored_file = file_list[ii]
      tailored_file->$wrfvariable$(:,variable_level,:,:) = (var_original(:,variable_level,:,:) * small2next000) + var_central;var_original
      delete(tailored_file)
      else
      copy_VarCoords(var_original, polynomial)
      copy_VarAtts(var_original, polynomial)
      var_original = polynomial
      filefromlist->$wrfvariable$ = var_original
      delete(filefromlist)
    end if
    print("Domain " + (ii+1) + " has been tailord")
end do