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
opt             = True
opt@return_mask = True
NCLvarnames = asciiread("variables.txt", -1, "string")
totvars = dimsizes(NCLvarnames)

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
E_SO2 := varlist[1]  ;;;added_new_line_by_sed
E_NH3 := varlist[0]  ;;;added_new_line_by_sed

    ;;;equation from namelist.wrf
polynomial := (E_NH3*1)+E_SO2/2+100  ;;;added_new_line_by_sed
polynomial_init := polynomial
polynomial@lat2d := file_list[ii]->XLAT
polynomial@lon2d := file_list[ii]->XLONG

coorddim = dimsizes(dimsizes(polynomial))
if (coorddim .gt. 2) then
    if (coorddim .eq. 3) then
        polynomial := polynomial(0, :, :)
        else
        polynomial := polynomial(0, 0, :, :)
    end if
end if

mask_main := shapefile_mask_data(polynomial, shape_path, opt)
mask_main := conform(polynomial_init, mask_main, (/coorddim-2, coorddim-1/))
mask_inverse := where(mask_main.eq.1, 0, 1)
wrfvar := file_list[ii]->$wrfvariable$
if (inverse_mask_on_off .eq. 1) then
    mask_main_copy := mask_main
    mask_main := mask_inverse
    mask_inverse := mask_main_copy
    delete(mask_main_copy)
end if

polynomial_final_masked := (wrfvar * mask_inverse) + (polynomial_init * mask_main)
copy_VarCoords(wrfvar, polynomial_final_masked)
filefromlist := file_list[ii]
filefromlist->$wrfvariable$ = polynomial_final_masked
print("Domain " + (ii+1) + " has been tailord")
end do