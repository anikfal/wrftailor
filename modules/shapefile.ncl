; Code to tailor WRF outputs by a shapefile
; Contact person: Amirhossein Nikfal <https://github.com/anikfal>

load "files2list.ncl" ;put domain_1, domain_2, ... into file_list
load "shapefile_utils.ncl"

wrfvariable = getenv("wrf_variable")
if (.not. isfilevar(file_list[0], wrfvariable)) then
    print("Warning: Variable " + wrfvariable + " is not found")
    print("Exiting ..")
    exit()
end if

number_of_domains = tointeger(getenv("number_of_domains"))
shape_path = getenv("shape_path")
inverse_mask_on_off = getenv("inverse_mask_on_off")
variable_level = tointeger(getenv("variable_level"))

lines = tointeger(getenv("substitutenumber"))
sublevels = new(lines,"integer")
i=0
do while(i.le.(lines-1))
    sublevels(i) = tointeger(getenv("sublevels"+i)) - 1
    i=i+1
end do

opt             = True
opt@return_mask = True
NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)

thevariable = file_list[0]->$wrfvariable$
thevardim   = dimsizes(thevariable)
thevardimname = getvardims(thevariable)
if ( dimsizes(thevardim) .eq. 4) then
  var_is_4d = True
  if ((variable_level .gt. thevardim(1)) .or. (variable_level .lt. 1)) then
  print("Warning: " + "variable_level1 for " + wrfvariable + \
  " (" + thevariable@description + ") in namelist.tailor is " + variable_level + \
  ". It should be between 1 to " + thevardim(1) + " (maximum number of " + thevardimname(1) + ").")
  exit()
  end if
  variable_level = variable_level - 1
end if

subnums = dimsizes(sublevels)
if (totvars .ne. subnums) then
    print("Warning: variable_substitute_name1 has " + totvars + \
    " variables. But variable_substitute_levels1 has " + subnums + \ 
    " values. They should be equal.")
    print("Exiting ..")
    exit()
end if

jj=0
do while(jj.lt.totvars) ;code aaff
    if (.not. isfilevar(file_list[0], NCLvarnames(jj))) then
        print("Warning: " + NCLvarnames(jj) + " in variable_substitute_name1 is not available in input files.")
        print("Exiting ..")
        exit()
    end if
    jj = jj+1
end do

ii = number_of_domains
do while(ii .gt. 0)
    ii = ii - 1
    print("Masking regarding the shapefile ...")
    varlist = NewList("lifo")
    jj=0
    do while(jj.lt.totvars) ;code aaff
        ListAppend(varlist, wrf_user_getvar(file_list[ii], NCLvarnames(jj), -1))
        jj = jj+1
    end do
    ;;;shell script
          LANDUSEF := varlist[2]  ;;;added_new_line_by_sed 
          vardim := dimsizes(LANDUSEF) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(LANDUSEF) ;;;added_new_line_by_sed 
            if ((sublevels(2) .gt. (vardim(1)-1)) .or. (sublevels(2) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(2)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(2) + \ ;;;added_new_line_by_sed 
              " (" + LANDUSEF@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            LANDUSEF := LANDUSEF(:, sublevels(2), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
          GREENFRAC := varlist[1]  ;;;added_new_line_by_sed 
          vardim := dimsizes(GREENFRAC) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(GREENFRAC) ;;;added_new_line_by_sed 
            if ((sublevels(1) .gt. (vardim(1)-1)) .or. (sublevels(1) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(1)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(1) + \ ;;;added_new_line_by_sed 
              " (" + GREENFRAC@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            GREENFRAC := GREENFRAC(:, sublevels(1), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed
          EROD := varlist[0]  ;;;added_new_line_by_sed 
          vardim := dimsizes(EROD) ;;;added_new_line_by_sed 
          if (dimsizes(vardim) .eq. 4) then ;;;added_new_line_by_sed 
            dimnames = getvardims(EROD) ;;;added_new_line_by_sed 
            if ((sublevels(0) .gt. (vardim(1)-1)) .or. (sublevels(0) .lt. 0)) then ;;;added_new_line_by_sed 
              selected_sublevel = sublevels(0)+1 ;;;added_new_line_by_sed 
              print("Warning: " + "variable_substitute_levels1 for " + NCLvarnames(0) + \ ;;;added_new_line_by_sed 
              " (" + EROD@description + ") in namelist.tailor is " + selected_sublevel + \ ;;;added_new_line_by_sed 
              ". It should be between 1 to " + vardim(1) + " (maximum number of " + dimnames(1) + ").") ;;;added_new_line_by_sed 
              print("Exiting ..") ;;;added_new_line_by_sed 
              exit() ;;;added_new_line_by_sed 
            end if ;;;added_new_line_by_sed 
            EROD := EROD(:, sublevels(0), :, :) ;;;added_new_line_by_sed 
          end if ;;;added_new_line_by_sed

    ;;;equation from namelist.wrf
polynomial := (EROD*1)+GREENFRAC/2+100+LANDUSEF  ;;;added_new_line_by_sed
polynomial_init := polynomial
allvars := getfilevarnames(file_list[ii])
all_latnames := str_match(allvars, "XLAT")
all_longnames := str_match(allvars, "XLONG")
polynomial@lat2d := file_list[ii]->$all_latnames(0)$
polynomial@lon2d := file_list[ii]->$all_longnames(0)$

coorddim = dimsizes(dimsizes(polynomial))
if (coorddim .gt. 2) then
  polynomial := polynomial(0, :, :)
end if

mask_main := shapefile_mask_data(polynomial, shape_path, opt)
mask_main := conform(polynomial_init, mask_main, (/coorddim-2, coorddim-1/))
mask_inverse := where(mask_main.eq.1, 0, 1)
wrfvar_original := file_list[ii]->$wrfvariable$
wrfvar := wrfvar_original
coorddim := dimsizes(dimsizes(wrfvar))
if (coorddim .eq. 4) then
  wrfvar := wrfvar(:, variable_level, :, :)
end if
if (inverse_mask_on_off .eq. 1) then
    mask_main_copy := mask_main
    mask_main := mask_inverse
    mask_inverse := mask_main_copy
    delete(mask_main_copy)
end if

polynomial_final_masked := (wrfvar * mask_inverse) + (polynomial_init * mask_main)
copy_VarCoords(wrfvar, polynomial_final_masked)
filefromlist := file_list[ii]
; filefromlist->$wrfvariable$ = polynomial_final_masked
tempvar = addfile("tempppppp.nc", "c")
tempvar->var = polynomial_final_masked
exit()
if (var_is_4d .eq. True) then
  wrfvar_original(:, variable_level, :, :) = polynomial_final_masked
  else
  wrfvar_original = polynomial_final_masked
end if
print("Domain " + (ii+1) + " has been tailord")
end do